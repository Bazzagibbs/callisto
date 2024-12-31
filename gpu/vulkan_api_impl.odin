#+ private

package callisto_gpu

import dd "vendor:vulkan" // Only used for autocomplete, then replace with `d.<proc>`

import "base:runtime"
import "core:dynlib"
import "core:sync"
import "core:log"
import "core:strings"
import "core:os/os2"
import "core:path/filepath"
import "core:mem"
import vk "vulkan"
import "vma"
import "../common"
import "../config"

// when RHI == "vulkan" {

LAYERS :: []cstring {
        "VK_LAYER_KHRONOS_shader_object",
}

INSTANCE_EXTENSIONS :: []cstring {
        vk.KHR_SURFACE_EXTENSION_NAME,
}

DEVICE_EXTENSIONS :: []cstring {
        vk.KHR_SWAPCHAIN_EXTENSION_NAME,
        vk.EXT_SHADER_OBJECT_EXTENSION_NAME,
}

MAX_DESCRIPTORS :: 4096


@(private)
VK_VALIDATION_LAYER :: ODIN_DEBUG && true

@(private)
VK_ENABLE_INSTANCE_DEBUGGING :: true



_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Device")

        validate_info(location,
                Valid_Not_Nil{".runner", init_info.runner},
        ) or_return


        _vk_loader(d)
        _vk_instance_init(d, init_info) or_return
        _vk_physical_device_select(d, init_info) or_return
        _vk_device_init(d, init_info) or_return
        _vk_descriptors_init(d) or_return
        _vk_vma_init(d) or_return
        _vk_immediate_command_buffer_init(d) or_return

        return .Ok
}


_device_destroy :: proc(d: ^Device) {
        log.info("Destroying Device")

        // Sampler library
        for info, sampler in d.samplers {
                d.DestroySampler(d.device, sampler, nil)
        }
        delete(d.samplers)

        _vk_immediate_command_buffer_destroy(d)
        _vk_descriptors_destroy(d)
        _vk_vma_destroy(d)
        _vk_device_destroy(d)
        _vk_instance_destroy(d)
}

_device_wait_for_idle :: proc(d: ^Device) {
        d.DeviceWaitIdle(d.device)
}

_immediate_command_buffer_get :: proc(d: ^Device, cb: ^^Command_Buffer) -> Result {
        cb^ = &d.immediate_cb
        return .Ok
}


// Blocks until command buffer is complete
_immediate_command_buffer_submit :: proc(d: ^Device, cb:  ^Command_Buffer) -> Result {
        _command_buffer_submit(d, cb) or_return

        vkres := d.WaitForFences(d.device, 1, &d.immediate_cb_fence.fence, true, max(u64))
        check_result(vkres) or_return
        vkres = d.ResetFences(d.device, 1, &d.immediate_cb_fence.fence)
        check_result(vkres) or_return
        return .Ok
}



_swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Swapchain")

        validate_info(location, 
                Valid_Not_Nil{".window", init_info.window}
        ) or_return

        _vk_surface_init(d, sc, init_info) or_return
        _vk_swapchain_init(d, sc, init_info) or_return
        _vk_swapchain_images_init(d, sc) or_return
        _vk_swapchain_sync_init(d, sc) or_return
        _vk_swapchain_command_buffers_init(d, sc) or_return

        return .Ok
}


_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        log.info("Destroying Swapchain")
       
        _vk_swapchain_command_buffers_destroy(d, sc)
        _vk_swapchain_sync_destroy(d, sc)
        _vk_swapchain_images_destroy(d, sc)
        _vk_swapchain_destroy(d, sc)
        _vk_surface_destroy(d, sc)
}

_swapchain_get_frame_in_flight_index :: proc(d: ^Device, sc: ^Swapchain) -> int {
        return int(sc.frame_counter)
}

_swapchain_get_extent :: proc(d: ^Device, sc: ^Swapchain) -> [2]u32 {
        return { sc.extent.width, sc.extent.height }
}

// swapchain_set_vsync           :: proc(d: ^Device, sc: ^Swapchain, vsync: Vsync_Mode) -> (res: Result)
// swapchain_get_vsync           :: proc(d: ^Device, sc: ^Swapchain) -> (vsync: Vsync_Mode)
// swapchain_get_available_vsync :: proc(d: ^Device, sc: ^Swapchain) -> (vsyncs: Vsync_Modes)

_swapchain_wait_for_next_frame :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        vkres := d.WaitForFences(d.device, 1, &sc.in_flight_fence[sc.frame_counter], false, max(u64))
        check_result(vkres) or_return
        vkres = d.ResetFences(d.device, 1, &sc.in_flight_fence[sc.frame_counter])
        check_result(vkres) or_return
        return .Ok
}

_swapchain_acquire_texture :: proc(d: ^Device, sc: ^Swapchain, texture: ^^Texture) -> (res: Result) {
        res = .Ok

        if sc.needs_recreate {
                _vk_swapchain_recreate(d, sc) or_return
                sc.needs_recreate = false
                res = .Swapchain_Rebuilt
        }

        vkres := d.AcquireNextImageKHR(d.device, sc.swapchain, max(u64), sc.image_available_sema[sc.frame_counter], {}, &sc.image_index)

        if vkres != .SUCCESS && vkres != .SUBOPTIMAL_KHR {
                log.warn("Invalid swapchain, attempting to recreate.", vkres)
                // attempt to recreate invalid swapchain
                _vk_swapchain_recreate(d, sc) or_return
                res = .Swapchain_Rebuilt
        }

        texture^ = &sc.textures[sc.image_index]

        return 
}

_swapchain_acquire_command_buffer :: proc(d: ^Device, sc: ^Swapchain, cb: ^^Command_Buffer) -> (res: Result) {
        cb^ = &sc.command_buffers[sc.frame_counter]

        vkres := d.ResetCommandPool(d.device, cb^.pool, {})
        check_result(vkres) or_return

        return .Ok
}

_swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        present_info := vk.PresentInfoKHR {
                sType              = .PRESENT_INFO_KHR,
                waitSemaphoreCount = 1,
                pWaitSemaphores    = &sc.render_finished_sema[sc.frame_counter],
                swapchainCount     = 1,
                pSwapchains        = &sc.swapchain,
                pImageIndices      = &sc.image_index
        }

        sc.frame_counter = (sc.frame_counter + 1) % FRAMES_IN_FLIGHT

        vkres := d.QueuePresentKHR(sc.present_queue, &present_info)
        if vkres == .SUBOPTIMAL_KHR || vkres == .ERROR_OUT_OF_DATE_KHR {
                sc.needs_recreate = true
                return .Ok
        }

        check_result(vkres) or_return

        return .Ok
}


// Descriptor Allocator is a free-list of handles
_vk_descriptor_allocator_init :: proc(da: ^_Descriptor_Allocator) {
        da.next = 0

        for i in 0..<MAX_DESCRIPTORS {
                da.free_list[i] = u32(i)
        }
}

// Acquire the next available descriptor reference
_vk_descriptor_reference_alloc :: proc(da: ^_Descriptor_Allocator) -> (reference: Texture_Reference) {
        reference = Texture_Reference{ da.free_list[da.next] }
        da.next += 1
        return
}

// Release a descriptor reference to be reused
_vk_descriptor_reference_free :: proc(da: ^_Descriptor_Allocator, reference: Texture_Reference) {
        da.next -= 1
        da.free_list[da.next] = reference.handle
}

_Texture_Dimensions_To_Vk := [Texture_Dimensions]vk.ImageType {
        ._1D        = .D1,
        ._2D        = .D2,
        ._3D        = .D3,
        .Cube       = .D2,
        ._1D_Array  = .D1,
        ._2D_Array  = .D2,
        .Cube_Array = .D2,
}

_Texture_Dimensions_To_Vk_View := [Texture_Dimensions]vk.ImageViewType {
        ._1D        = .D1,
        ._2D        = .D2,
        ._3D        = .D3,
        .Cube       = .CUBE,
        ._1D_Array  = .D1_ARRAY,
        ._2D_Array  = .D2_ARRAY,
        .Cube_Array = .CUBE_ARRAY,
}

_Texture_Format_To_Vk := [Texture_Format]vk.Format {
        .Undefined           = .UNDEFINED,
        .R8G8B8A8_UNORM      = .R8G8B8A8_UNORM,
        .R16G16B16A16_SFLOAT = .R16G16B16A16_SFLOAT,
}

_Texture_Usage_To_Vk := [Texture_Usage_Flag]vk.ImageUsageFlag {
        .Transfer_Src         = .TRANSFER_SRC,
        .Transfer_Dst         = .TRANSFER_DST,
        .Sampled              = .SAMPLED,
        .Storage              = .STORAGE,
        .Color_Target         = .COLOR_ATTACHMENT,
        .Depth_Stencil_Target = .DEPTH_STENCIL_ATTACHMENT,
        .Transient_Target     = .TRANSIENT_ATTACHMENT,
}

_Memory_Access_Type_To_Vma := [Memory_Access_Type]vma.AllocationCreateInfo {
        .Device_Read_Only = {
                usage = .AUTO,
                flags = {},
        },

        .Device_Read_Write = {
                usage = .AUTO,
                flags = {.DEDICATED_MEMORY},
        },

        .Staging = {
                usage = .AUTO,
                flags = {.HOST_ACCESS_SEQUENTIAL_WRITE, .MAPPED},
        },

        .Host_Readback = {
                usage = .AUTO,
                flags = {.HOST_ACCESS_RANDOM, .MAPPED},
        },
}

_Texture_Multisample_To_Vk := [Texture_Multisample]vk.SampleCountFlags {
        .None = {._1},
        ._2   = {._2},
        ._4   = {._4},
        ._8   = {._8},
        ._16  = {._16},
        ._32  = {._32},
        ._64  = {._64},
}


_Filter_To_Vk := [Filter]vk.Filter {
        .Linear  = .LINEAR,
        .Nearest = .NEAREST,
}

_Filter_To_Vk_Mip := [Filter]vk.SamplerMipmapMode {
        .Linear  = .LINEAR,
        .Nearest = .NEAREST,
}

_Wrap_Mode_To_Vk := [Sampler_Wrap_Mode]vk.SamplerAddressMode {
        .Repeat          = .REPEAT,
        .Mirror          = .MIRRORED_REPEAT,
        .Clamp_To_Edge   = .CLAMP_TO_EDGE,
        .Clamp_To_Border = .CLAMP_TO_BORDER
}

_Compare_Op_To_Vk := [Compare_Op]vk.CompareOp {
        .Never            = .NEVER,
        .Less             = .LESS,
        .Equal            = .EQUAL,
        .Less_Or_Equal    = .LESS_OR_EQUAL,
        .Greater          = .GREATER,
        .Not_Equal        = .NOT_EQUAL,
        .Greater_Or_Equal = .GREATER_OR_EQUAL,
        .Always           = .ALWAYS,
}

_Border_Color_To_Vk := [Sampler_Border_Color]vk.BorderColor {
        .Transparent_Black_Float = .FLOAT_TRANSPARENT_BLACK,
        .Transparent_Black_Int   = .INT_TRANSPARENT_BLACK,
        .Opaque_Black_Float      = .FLOAT_OPAQUE_BLACK,
        .Opaque_Black_Int        = .INT_OPAQUE_BLACK,
        .Opaque_White_Float      = .FLOAT_OPAQUE_WHITE,
        .Opaque_White_Int        = .INT_OPAQUE_WHITE,
}

_Aniso_To_Vk := [Anisotropy]f32 {
        .None = 1,
        ._1   = 1,
        ._2   = 2,
        ._4   = 4,
        ._8   = 8,
        ._16  = 16,
}

_fence_init :: proc(d: ^Device, fence: ^Fence, init_info: ^Fence_Init_Info) -> Result {
        create_info := vk.FenceCreateInfo {
                sType = .FENCE_CREATE_INFO,
                flags = {},
        }

        if init_info.begin_signaled {
                create_info.flags += {.SIGNALED}
        }

        vkres := d.CreateFence(d.device, &create_info, nil, &fence.fence)
        check_result(vkres) or_return

        return .Ok
}

_fence_destroy :: proc(d: ^Device, fence: ^Fence) {
        d.DestroyFence(d.device, fence.fence, nil)
}

_semaphore_init :: proc(d: ^Device, sema: ^Semaphore, init_info: ^Semaphore_Init_Info) -> Result {
        create_info := vk.SemaphoreCreateInfo {
                sType = .SEMAPHORE_CREATE_INFO,
        }

        vkres := d.CreateSemaphore(d.device, &create_info, nil, &sema.sema)
        check_result(vkres) or_return

        return .Ok
}

_semaphore_destroy :: proc(d: ^Device, sema: ^Semaphore) {
        d.DestroySemaphore(d.device, sema.sema, nil)
}


_texture_init :: proc(d: ^Device, tex: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result) {
        unique_families := make(map[u32]struct{}, context.temp_allocator)

        for flag in init_info.queue_usage {
                switch flag {
                case .Graphics: unique_families[d.graphics_family] = {}
                case .Compute_Async: unique_families[d.async_compute_family] = {}
                }
        }

        families := make([dynamic]u32, len(unique_families), context.temp_allocator)
        for key, _ in unique_families {
                append(&families, key)
        }

        usage := vk.ImageUsageFlags {}
        for flag in init_info.usage {
                if flag == .Storage {
                        tex.is_storage = true
                }
                if flag == .Sampled {
                        tex.is_sampled = true
                }

                usage += {_Texture_Usage_To_Vk[flag]}
        }
        
        extent := init_info.extent

        image_type := _Texture_Dimensions_To_Vk[init_info.dimensions]

        create_info := vk.ImageCreateInfo {
                sType                 = .IMAGE_CREATE_INFO,
                imageType             = _Texture_Dimensions_To_Vk[init_info.dimensions],
                format                = _Texture_Format_To_Vk[init_info.format],
                extent                = {init_info.extent.x, init_info.extent.y, init_info.extent.z},
                mipLevels             = init_info.mip_count,
                arrayLayers           = init_info.layer_count,
                samples               = _Texture_Multisample_To_Vk[init_info.multisample],
                tiling                = .OPTIMAL,
                usage                 = usage,
                sharingMode           = .EXCLUSIVE, // requires ownership transfer using image memory barrier
                queueFamilyIndexCount = len32(families),
                pQueueFamilyIndices   = raw_data(families),
                // initialLayout      = _Texture_Layout_To_Vk[init_info.initial_layout],
                initialLayout         = .UNDEFINED,
        }
        
        tex.extent      = create_info.extent
        tex.layer_count = create_info.arrayLayers
        tex.mip_count   = create_info.mipLevels

        allocation_info := _Memory_Access_Type_To_Vma[init_info.memory_access_type]

        vkres := vma.CreateImage(d.allocator, &create_info, &allocation_info, &tex.image, &tex.allocation, nil)
        check_result(vkres) or_return

        range := _vk_subresource_range({.Color})

        view_info := vk.ImageViewCreateInfo {
                sType            = .IMAGE_VIEW_CREATE_INFO,
                image            = tex.image,
                viewType         = _Texture_Dimensions_To_Vk_View[init_info.dimensions],
                format           = create_info.format,
                components       = {},
                subresourceRange = range,
        }

        vkres = d.CreateImageView(d.device, &view_info, nil, &tex.full_view.view)
        check_result(vkres) or_return

        sampler, sampler_exists := d.samplers[init_info.sampler_info]
        if !sampler_exists {
                init_sampler_info := init_info.sampler_info


                sampler_info := vk.SamplerCreateInfo {
                        sType                   = .SAMPLER_CREATE_INFO,
                        magFilter               = _Filter_To_Vk[init_sampler_info.magnify_filter],
                        minFilter               = _Filter_To_Vk[init_sampler_info.minify_filter],
                        mipmapMode              = _Filter_To_Vk_Mip[init_sampler_info.mip_filter],
                        addressModeU            = _Wrap_Mode_To_Vk[init_sampler_info.wrap_mode],
                        addressModeV            = _Wrap_Mode_To_Vk[init_sampler_info.wrap_mode],
                        addressModeW            = _Wrap_Mode_To_Vk[init_sampler_info.wrap_mode],
                        mipLodBias              = init_sampler_info.mip_lod_bias,
                        anisotropyEnable        = b32(init_sampler_info.anisotropy != .None),
                        maxAnisotropy           = _Aniso_To_Vk[init_sampler_info.anisotropy],
                        compareEnable           = false,
                        compareOp               = .ALWAYS,
                        minLod                  = init_sampler_info.min_lod,
                        maxLod                  = init_sampler_info.max_lod,
                        borderColor             = _Border_Color_To_Vk[init_sampler_info.border_color],
                        unnormalizedCoordinates = b32(init_sampler_info.sample_by_pixel_index),
                }

                vkres = d.CreateSampler(d.device, &sampler_info, nil, &sampler)
                check_result(vkres) or_return

                d.samplers[init_info.sampler_info] = sampler 
        }

        tex.sampler = sampler

        // Create descriptors for access
        if tex.is_sampled {
                tex.sampled_reference = _vk_descriptor_reference_alloc(&d.descriptor_allocator_sampled_tex)

                image_info := vk.DescriptorImageInfo {
                        sampler     = sampler,
                        imageLayout = .READ_ONLY_OPTIMAL,
                        imageView   = tex.full_view.view,
                }

                write_info := vk.WriteDescriptorSet {
                        sType           = .WRITE_DESCRIPTOR_SET,
                        dstSet          = d.bindless_set,
                        dstBinding      = 1, // 1=sampled, 2=storage
                        dstArrayElement = tex.sampled_reference.handle,
                        descriptorCount = 1,
                        descriptorType  = .COMBINED_IMAGE_SAMPLER,
                        pImageInfo      = &image_info,
                }
                d.UpdateDescriptorSets(d.device, 1, &write_info, 0, nil)
        }

        if tex.is_storage {
                tex.storage_reference = _vk_descriptor_reference_alloc(&d.descriptor_allocator_storage_tex)
                
                image_info := vk.DescriptorImageInfo {
                        sampler     = sampler,
                        imageLayout = .GENERAL,
                        imageView   = tex.full_view.view,
                }

                write_info := vk.WriteDescriptorSet {
                        sType           = .WRITE_DESCRIPTOR_SET,
                        dstSet          = d.bindless_set,
                        dstBinding      = 2, // 1=sampled, 2=storage
                        dstArrayElement = tex.sampled_reference.handle,
                        descriptorCount = 1,
                        descriptorType  = .STORAGE_IMAGE,
                        pImageInfo      = &image_info,
                }
                d.UpdateDescriptorSets(d.device, 1, &write_info, 0, nil)
        }


        return .Ok
}

_texture_destroy :: proc(d: ^Device, tex: ^Texture) {
        d.DestroyImageView(d.device, tex.full_view.view, nil)
        vma.DestroyImage(d.allocator, tex.image, tex.allocation)

        if tex.is_sampled {
                _vk_descriptor_reference_free(&d.descriptor_allocator_sampled_tex, tex.sampled_reference)
        }
        if tex.is_storage {
                _vk_descriptor_reference_free(&d.descriptor_allocator_storage_tex, tex.storage_reference)
        }
}

_texture_get_extent :: proc(d: ^Device, tex: ^Texture) -> [3]u32 {
        return {tex.extent.width, tex.extent.height, tex.extent.depth}
}

_texture_get_reference_storage :: proc(d: ^Device, tex: ^Texture) -> Texture_Reference {
        return tex.storage_reference
}

_texture_get_reference_sampled :: proc(d: ^Device, tex: ^Texture) -> Texture_Reference {
        return tex.sampled_reference
}


_get_unique_queue_indices :: proc(d: ^Device, flags: Queue_Flags) -> (indices: [8]u32, count: u32) {
        count = 0

        per_flag:
        for flag in flags {
                family: u32
                switch flag {
                case .Graphics      : family = d.graphics_family
                case .Compute_Async : family = d.async_compute_family
                // case .Transfer   : family = d.transfer_family
                case                : family = d.graphics_family
                }

                for i in 0..<count {
                        if indices[i] == family {
                                continue per_flag
                        }
                }

                indices[count] = family
                count += 1
        }

        return
}

_Buffer_Usage_To_Vk := [Buffer_Usage_Flag]vk.BufferUsageFlag {
        .Transfer_Src   = .TRANSFER_SRC,
        .Transfer_Dst   = .TRANSFER_DST,
        .Storage        = .STORAGE_BUFFER,
        .Index          = .INDEX_BUFFER,
        .Vertex         = .VERTEX_BUFFER,
        .Addressable    = .SHADER_DEVICE_ADDRESS,
}

_buffer_usage_to_vk :: proc(usage: Buffer_Usage_Flags) -> vk.BufferUsageFlags {
        vk_usage := vk.BufferUsageFlags{}
        for flag in usage {
                vk_usage += {_Buffer_Usage_To_Vk[flag]}
        }
        
        return vk_usage
}

_buffer_init :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> Result {
        families, family_count := _get_unique_queue_indices(d, init_info.queue_usage)

        create_info := vk.BufferCreateInfo {
                sType                 = .BUFFER_CREATE_INFO,
                // flags              = {.SPARSE_BINDING},
                flags                 = {},
                size                  = vk.DeviceSize(init_info.size),
                usage                 = _buffer_usage_to_vk(init_info.usage),
                sharingMode           = .EXCLUSIVE,
                queueFamilyIndexCount = family_count,
                pQueueFamilyIndices   = raw_data(&families),
        }

        alloc_create_info := _Memory_Access_Type_To_Vma[init_info.memory_access_type]

        vkres := vma.CreateBuffer(d.allocator, &create_info, &alloc_create_info, &b.buffer, &b.allocation, &b.alloc_info)
        check_result(vkres) or_return

        b.size      = init_info.size
        b.available = init_info.size

        if .Addressable in init_info.usage {
                bda_info := vk.BufferDeviceAddressInfo {
                        sType  = .BUFFER_DEVICE_ADDRESS_INFO,
                        buffer = b.buffer,
                }

                b.address = d.GetBufferDeviceAddress(d.device, &bda_info)
        }

        if init_info.memory_access_type == .Staging {
                vkres = vma.MapMemory(d.allocator, b.allocation, &b.mapped_mem)
                check_result(vkres) or_return
        }

        return .Ok
}

_buffer_destroy :: proc(d: ^Device, b: ^Buffer) {
        if b.mapped_mem != nil {
                vma.UnmapMemory(d.allocator, b.allocation)
                b.mapped_mem = nil
        }

        vma.DestroyBuffer(d.allocator, b.buffer, b.allocation)
}


_buffer_get_reference :: proc(d: ^Device, b: ^Buffer, stride, index: int) -> Buffer_Reference {
        return Buffer_Reference {b.address + vk.DeviceAddress(stride) * vk.DeviceAddress(index)}
}


_command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Creating Command Buffer")
        // validate_info()

        cb.queue = init_info.queue

        family : u32
        switch cb.queue {
        case .Graphics: 
                family = d.graphics_family
        case .Compute_Async:
                family = d.async_compute_family
        }
        
        pool_info := vk.CommandPoolCreateInfo {
                sType            = .COMMAND_POOL_CREATE_INFO,
                flags            = {}, // Might need .RESET here but probably not, just reset the pool
                queueFamilyIndex = family,
        }

        vkres: vk.Result

        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.pool)
        check_result(vkres) or_return
   

        buffer_info := vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.pool,
                commandBufferCount = 1,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, &cb.buffer)
        check_result(vkres) or_return

        if init_info.wait_semaphore != nil {
                cb.wait_sema = init_info.wait_semaphore.sema
        }
        if init_info.signal_semaphore != nil {
                cb.signal_sema = init_info.signal_semaphore.sema
        }
        if init_info.signal_fence != nil {
                cb.signal_fence = init_info.signal_fence.fence
        }

        // Create a per-cb staging buffer
        grow_info := Buffer_Init_Info {
                size               = 2 * runtime.Megabyte,
                usage              = {.Transfer_Src},
                queue_usage        = {.Graphics, .Compute_Sync},
                memory_access_type = .Staging,
        }
        _ = _buffer_init(d, &cb.staging_buffer, &grow_info)
        
        return .Ok
}

_command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        log.info("Destroying Command Buffer")
        
        for &buf in cb.staging_old {
                _buffer_destroy(d, &buf)
        }
        delete(cb.staging_old)
        
        _buffer_destroy(d, &cb.staging_buffer)

        d.DestroyCommandPool(d.device, cb.pool, nil)

}

_command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        // Reset staging buffer
        if len(cb.staging_old) > 0 {
                for &buf in cb.staging_old {
                        _buffer_destroy(d, &buf)
                }

                clear(&cb.staging_old)
        }
        cb.staging_buffer.available = cb.staging_buffer.size

        // Reset push constant state
        cb.push_constant_state = {}
        cb.push_constants_dirty = true

        begin_info := vk.CommandBufferBeginInfo {
                sType = .COMMAND_BUFFER_BEGIN_INFO,
                flags = {.ONE_TIME_SUBMIT}
        }
        vkres := d.BeginCommandBuffer(cb.buffer, &begin_info)
        check_result(vkres) or_return

        _cmd_bind_all(d, cb, .Compute)
        _cmd_bind_all(d, cb, .Graphics)
        return .Ok
}

_command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        vkres := d.EndCommandBuffer(cb.buffer)
        return check_result(vkres)
}

_command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        queue: vk.Queue

        switch cb.queue {
        case .Graphics      : queue = d.graphics_queue
        case .Compute_Async : queue = d.async_compute_queue
        case                : queue = d.graphics_queue
        }

        cb_info := vk.CommandBufferSubmitInfo {
                sType         = .COMMAND_BUFFER_SUBMIT_INFO,
                commandBuffer = cb.buffer,
                deviceMask    = 0,
        }

        wait_sema_info := vk.SemaphoreSubmitInfo {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = cb.wait_sema,
                stageMask   = {.COLOR_ATTACHMENT_OUTPUT},
                deviceIndex = 0,
                value       = 1,
        }
        
        signal_sema_info := vk.SemaphoreSubmitInfo {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = cb.signal_sema,
                stageMask   = {.ALL_GRAPHICS},
                deviceIndex = 0,
                value       = 1,
        }

        submit_info := vk.SubmitInfo2 {
                sType                    = .SUBMIT_INFO_2,
                waitSemaphoreInfoCount   = 0 if cb.wait_sema == {} else 1,
                pWaitSemaphoreInfos      = &wait_sema_info,
                signalSemaphoreInfoCount = 0 if cb.signal_sema == {} else 1,
                pSignalSemaphoreInfos    = &signal_sema_info,
                commandBufferInfoCount   = 1,
                pCommandBufferInfos      = &cb_info,
        }

        sync.lock(&d.submit_mutex)
        vkres := d.QueueSubmit2(queue, 1, &submit_info, cb.signal_fence)
        sync.unlock(&d.submit_mutex)
        return check_result(vkres)
}


_Shader_Stage_To_Vk := [Shader_Stage]vk.ShaderStageFlag {
        .Vertex                  = .VERTEX,
        .Tessellation_Control    = .TESSELLATION_CONTROL,
        .Tessellation_Evaluation = .TESSELLATION_EVALUATION,
        .Geometry                = .GEOMETRY,
        .Fragment                = .FRAGMENT,
        .Compute                 = .COMPUTE,
        // // FEATURE(Ray tracing)
        // .Ray_Generation          = .RAYGEN_KHR,
        // .Any_Hit                 = .ANY_HIT_KHR,
        // .Closest_Hit             = .CLOSEST_HIT_KHR,
        // .Miss                    = .MISS_KHR,
        // .Intersection            = .INTERSECTION_KHR,
        // .Callable                = .CALLABLE_KHR,
        // // FEATURE(Mesh shaders)
        // .Task                    = .TASK_EXT,
        // .Mesh                    = .MESH_EXT,
}


_shader_stages_to_vk :: proc(stages: Shader_Stages) -> vk.ShaderStageFlags {
        flags := vk.ShaderStageFlags {}

        for stage in stages {
                flags += {_Shader_Stage_To_Vk[stage]}
        }

        return flags
}

_Resource_Type_To_Vk := [Resource_Type]vk.DescriptorType {
.Buffer          = .STORAGE_BUFFER,
        .Sampled_Texture = .SAMPLED_IMAGE,
        .Storage_Texture = .STORAGE_IMAGE,
        // .Acceleration_Structure = .ACCELERATION_STRUCTURE_KHR, // FEATURE(Ray tracing)
}

_Shader_Next_Stages := [Shader_Stage]vk.ShaderStageFlags {
        .Vertex                  = {.TESSELLATION_CONTROL, .TESSELLATION_EVALUATION, .GEOMETRY, .FRAGMENT},
        .Tessellation_Control    = {.TESSELLATION_EVALUATION},
        .Tessellation_Evaluation = {.GEOMETRY, .FRAGMENT},
        .Geometry                = {.FRAGMENT},
        .Fragment                = {},
        .Compute                 = {},
        // // FEATURE(Ray tracing)
        // .Ray_Generation          = {.ANY_HIT_KHR, .CLOSEST_HIT_KHR, .MISS_KHR, .INTERSECTION_KHR, .CALLABLE_KHR},
        // .Any_Hit                 = {},
        // .Closest_Hit             = {},
        // .Miss                    = {},
        // .Intersection            = {},
        // .Callable                = {},
        // // FEATURE(Mesh shading)
        // .Task                    = {.MESH_EXT},
        // .Mesh                    = {.FRAGMENT},
}


_shader_init :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result) {
        s.stages = {_Shader_Stage_To_Vk[init_info.stage]}

        push_constant_ranges := []vk.PushConstantRange {
                {vk.ShaderStageFlags_ALL, 0, size_of([4]vk.DeviceAddress)}
        }

        create_info := vk.ShaderCreateInfoEXT {
                sType                  = .SHADER_CREATE_INFO_EXT,
                flags                  = {},
                stage                  = s.stages,
                nextStage              = _Shader_Next_Stages[init_info.stage],
                codeType               = .SPIRV,
                codeSize               = len(init_info.code),
                pCode                  = raw_data(init_info.code),
                pName                  = "main",
                setLayoutCount         = 1,
                pSetLayouts            = &d.bindless_layout,
                pushConstantRangeCount = len32(push_constant_ranges),
                pPushConstantRanges    = raw_data(push_constant_ranges),
                pSpecializationInfo    = nil,
        }

        vkres := d.CreateShadersEXT(d.device, 1, &create_info, nil, &s.shader)
        check_result(vkres) or_return

        return .Ok
}


_shader_destroy :: proc(d: ^Device, s: ^Shader) {

        d.DestroyShaderEXT(d.device, s.shader, nil)
}



_cmd_transition_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, transition_info: ^Texture_Transition_Info) {
        range := _vk_subresource_range(transition_info.texture_aspect)

        barrier := vk.ImageMemoryBarrier2 {
                sType            = .IMAGE_MEMORY_BARRIER_2,
                srcStageMask     = _vk_pipeline_stages(transition_info.after_src_stages),
                dstStageMask     = _vk_pipeline_stages(transition_info.before_dst_stages),
                srcAccessMask    = _vk_access(transition_info.src_access),
                dstAccessMask    = _vk_access(transition_info.dst_access),
                oldLayout        = _Texture_Layout_To_Vk[transition_info.src_layout],
                newLayout        = _Texture_Layout_To_Vk[transition_info.dst_layout],
                image            = tex.image,
                subresourceRange = range,
        }

        dep_info := vk.DependencyInfo {
                sType                   = .DEPENDENCY_INFO,
                imageMemoryBarrierCount = 1,
                pImageMemoryBarriers    = &barrier,
        }

        d.CmdPipelineBarrier2(cb.buffer, &dep_info)
}


_cmd_clear_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, color: [4]f32) { 
        val := vk.ClearColorValue{float32 = color}
        range := _vk_subresource_range({.Color})
        d.CmdClearColorImage(cb.buffer, tex.image, .GENERAL, &val, 1, &range)
}


_cmd_blit_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, src, dst: ^Texture) {
        subresource := vk.ImageSubresourceLayers {
                aspectMask     = {.COLOR},
                mipLevel       = 0,
                baseArrayLayer = 0,
                layerCount     = 1,
        }

        region := vk.ImageBlit2 {
                sType          = .IMAGE_BLIT_2,
                srcSubresource = subresource,
                srcOffsets     = {{}, {i32(src.extent.width), i32(src.extent.height), i32(src.extent.depth)}},
                dstSubresource = subresource,
                dstOffsets     = {{}, {i32(dst.extent.width), i32(dst.extent.height), i32(dst.extent.depth)}},
        }

        blit_info := vk.BlitImageInfo2 {
                sType          = .BLIT_IMAGE_INFO_2,
                srcImage       = src.image,
                srcImageLayout = .TRANSFER_SRC_OPTIMAL,
                dstImage       = dst.image,
                dstImageLayout = .TRANSFER_DST_OPTIMAL,
                filter         = .LINEAR,
                regionCount    = 1,
                pRegions       = &region,
        }
        d.CmdBlitImage2(cb.buffer, &blit_info)
}

// _cmd_update_texture // using cb internal staging?

_cmd_upload_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, staging: ^Buffer, dst: ^Texture, upload_info: ^Texture_Upload_Info) {
        transfer_info := Texture_Transfer_Info {
                size           = upload_info.size,
                src_offset     = staging.size - staging.available,
                texture_aspect = .Color,
        }

        staging.available -= staging.size
        
        // memcpy to mapped memory
        offset_mem := rawptr(uintptr(staging.mapped_mem) + uintptr(transfer_info.src_offset))
        mem.copy(offset_mem, upload_info.data, int(upload_info.size))
        _cmd_transfer_buffer_to_texture(d, cb, staging, dst, &transfer_info)
}

_cmd_transfer_buffer_to_texture :: proc(d: ^Device, cb: ^Command_Buffer, src: ^Buffer, dst: ^Texture, transfer_info: ^Texture_Transfer_Info) {

        subresource := vk.ImageSubresourceLayers {
                aspectMask     = {_Aspect_Flag_To_Vk[transfer_info.texture_aspect]},
                mipLevel       = 0,
                baseArrayLayer = 0,
                layerCount     = 1,
        }

        region := vk.BufferImageCopy {
                bufferOffset      = vk.DeviceSize(transfer_info.src_offset),
                bufferRowLength   = 0,
                bufferImageHeight = 0,
                imageOffset       = {},
                imageSubresource  = subresource,
                imageExtent       = dst.extent,
        }

        d.CmdCopyBufferToImage(cb.buffer, src.buffer, dst.image, .TRANSFER_DST_OPTIMAL, 1, &region)
}


// This might be a bad idea, maybe just handle the staging buffer in the engine layer
_cmd_update_buffer :: proc(d: ^Device, cb: ^Command_Buffer, b: ^Buffer, upload_info: ^Buffer_Upload_Info) {
        sb := &cb.staging_buffer

        if upload_info.size > sb.available {
                _vk_buffer_grow(d, sb, &cb.staging_old)
        }

        _cmd_upload_buffer(d, cb, sb, b, upload_info)
}


_cmd_upload_buffer :: proc(d: ^Device, cb: ^Command_Buffer, staging: ^Buffer, dst: ^Buffer, upload_info: ^Buffer_Upload_Info) {
        // Bounds check? Might be caught by vulkan, but also it's a cmd so no return val.

        transfer_info := Buffer_Transfer_Info {
                size       = upload_info.size,
                src_offset = staging.size - staging.available,
                dst_offset = upload_info.dst_offset,
        }

        staging.available -= staging.size
        
        // memcpy to mapped memory
        offset_mem := rawptr(uintptr(staging.mapped_mem) + uintptr(transfer_info.src_offset))
        mem.copy(offset_mem, upload_info.data, int(upload_info.size))

        _cmd_transfer_buffer(d, cb, staging, dst, &transfer_info)
}

_cmd_transfer_buffer :: proc(d: ^Device, cb: ^Command_Buffer, src: ^Buffer, dst: ^Buffer, transfer_info: ^Buffer_Transfer_Info) {
        region := vk.BufferCopy {
                size      = vk.DeviceSize(transfer_info.size),
                srcOffset = vk.DeviceSize(transfer_info.src_offset),
                dstOffset = vk.DeviceSize(transfer_info.dst_offset),
        }

        d.CmdCopyBuffer(cb.buffer, src.buffer, dst.buffer, 1, &region)
}

// `old_buffers` must be destroyed only after they have finished being used
_vk_buffer_grow :: proc(d: ^Device, buffer: ^Buffer, old_buffers: ^[dynamic]Buffer) {
        append(old_buffers, buffer^)

        new_size := 2 * buffer.size

        buffer^ = {}

        grow_info := Buffer_Init_Info {
                size               = new_size,
                usage              = {.Transfer_Src},
                queue_usage        = {.Graphics, .Compute_Sync},
                memory_access_type = .Staging,
        }
        _ = _buffer_init(d, buffer, &grow_info)
}

_Bind_Point_To_Vk := [Bind_Point]vk.PipelineBindPoint {
        .Graphics    = .GRAPHICS,
        .Compute     = .COMPUTE,
        // .Ray_Tracing = .RAY_TRACING_EXT, // FEATURE(Ray tracing)
}

_cmd_bind_all :: proc(d: ^Device, cb: ^Command_Buffer, bind_point: Bind_Point) {
        // log.debugf("Binding descriptor set %x at bind point %v",  d.bindless_set, bind_point)
        d.CmdBindDescriptorSets(
                commandBuffer      = cb.buffer,
                pipelineBindPoint  = _Bind_Point_To_Vk[bind_point],
                layout             = d.bindless_pipeline_layout,
                firstSet           = 0,
                descriptorSetCount = 1,
                pDescriptorSets    = &d.bindless_set,
                dynamicOffsetCount = 0,
                pDynamicOffsets    = nil
        )
}

_cmd_set_constant_buffer_0 :: proc(d: ^Device, cb: ^Command_Buffer, buffer: ^Buffer_Reference) {
        cb.push_constant_state[0] = buffer.address
        cb.push_constants_dirty = true
}

_cmd_set_constant_buffer_1 :: proc(d: ^Device, cb: ^Command_Buffer, buffer: ^Buffer_Reference) {
        cb.push_constant_state[1] = buffer.address
        cb.push_constants_dirty = true
}

_cmd_set_constant_buffer_2 :: proc(d: ^Device, cb: ^Command_Buffer, buffer: ^Buffer_Reference) {
        cb.push_constant_state[2] = buffer.address
        cb.push_constants_dirty = true
}

_cmd_set_constant_buffer_3 :: proc(d: ^Device, cb: ^Command_Buffer, buffer: ^Buffer_Reference) {
        cb.push_constant_state[3] = buffer.address
        cb.push_constants_dirty = true
}

// Called on every draw/dispatch
_vk_cmd_push_constants_if_dirty :: #force_inline proc(d: ^Device, cb: ^Command_Buffer) {
        if cb.push_constants_dirty {
                d.CmdPushConstants(cb.buffer, 
                        layout     = d.bindless_pipeline_layout,
                        stageFlags = vk.ShaderStageFlags_ALL,
                        offset     = 0,
                        size       = size_of(cb.push_constant_state),
                        pValues    = raw_data(&cb.push_constant_state)
                )

                cb.push_constants_dirty = false
        }
}

_cmd_set_constant_buffers :: proc(d: ^Device, cb: ^Command_Buffer, buffer_infos: []Constant_Buffer_Set_Info) {
        for info in buffer_infos {
                cb.push_constant_state[int(info.slot)] = info.buffer_reference.address
        }

        // TODO: Move this to draw/
        d.CmdPushConstants(cb.buffer, 
                layout     = d.bindless_pipeline_layout,
                stageFlags = vk.ShaderStageFlags_ALL,
                offset     = 0,
                size       = size_of(cb.push_constant_state),
                pValues    = raw_data(&cb.push_constant_state)
        )
}


_cmd_bind_shader :: proc(d: ^Device, cb: ^Command_Buffer, shader: ^Shader) {
        d.CmdBindShadersEXT(cb.buffer, 1, &shader.stages, &shader.shader)
}


_cmd_dispatch :: proc(d: ^Device, cb: ^Command_Buffer, groups: [3]u32) {
        _vk_cmd_push_constants_if_dirty(d, cb)
        d.CmdDispatch(cb.buffer, groups.x, groups.y, groups.z)
}

/*

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

fence_reset              :: proc(d: ^Device, fences:[]^Fence) -> (res: Result)
fence_wait               :: proc(d: ^Device, fences: []^Fence) -> (res: Result)
cmd_fence_signal         :: proc(d: ^Device, fences: []^Fence)
cmd_semaphore_wait       :: proc(d: ^Device, semaphores: []^Semaphore)
cmd_semaphore_signal     :: proc(d: ^Device, semaphores: []^Semaphore)

cmd_set_scissor          :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_set_viewport         :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_clear_texture_color  :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)
cmd_clear_texture_depth_stencil  :: proc(d: ^Device, cb: ^Command_Buffer, depth: f32, stencil: u8)
cmd_transition_texture   :: proc(d: ^Device, cb: ^Command_Buffer, texture: ^Texture, src_layout, dst_layout: Texture_Layout)

cmd_set_shaders :: proc(d: ^Device, cb: ^Command_Buffer, shaders: []^Shader)
cmd_set_render_targets :: proc(d: ^Device, cb: ^Command_Buffer, color_target: ^Texture_View, depth_stencil_target: ^Texture_View)
// cmd_set_uniform_buffer :: proc(d: ^Device, cb: ^Command_Buffer, slot: u32, ub: ^Uniform_Buffer)

cmd_draw                 :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)
*/

// ======================================
// UTILS
// ======================================

// NOTE: positive `vkres` can be status codes, not necessarily errors
check_result :: proc(vkres: vk.Result, loc := #caller_location) -> Result {
        
        if vkres == .SUCCESS {
                return .Ok
        }
        
        log.error("RHI:", vkres, loc)
       
        #partial switch vkres {
        case .ERROR_OUT_OF_HOST_MEMORY: return .Out_Of_Memory_CPU
        case .ERROR_OUT_OF_DEVICE_MEMORY: return .Out_Of_Memory_GPU
        case .ERROR_MEMORY_MAP_FAILED: return .Memory_Map_Failed
        }

        return .Unknown_RHI_Error

}


_vk_prepend_layer_path :: proc() -> (ok: bool) {
        when ODIN_OS == .Windows {
                SEP :: ";"
        } else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
                SEP :: ":"
        }
        
        existing := os2.get_env("VK_LAYER_PATH", context.temp_allocator)

        exe_dir := common.get_exe_directory(context.temp_allocator)
        ours := filepath.join({exe_dir, config.SHIPPING_LIBS_PATH, "vulkan"}, context.temp_allocator)

        if existing != "" {
                err: runtime.Allocator_Error
                ours, err = strings.join({ours, existing}, SEP)
                if err != nil {
                        return false
                }
        }

        return os2.set_env("VK_LAYER_PATH", ours)
}


_Aspect_Flag_To_Vk := [Texture_Aspect_Flag]vk.ImageAspectFlag {
        .Color   = .COLOR,
        .Depth   = .DEPTH,
        .Stencil = .STENCIL,
}

_vk_subresource_range :: #force_inline proc(aspect: Texture_Aspect_Flags) -> vk.ImageSubresourceRange {
        mask := vk.ImageAspectFlags {}

        for flag in aspect {
                mask += {_Aspect_Flag_To_Vk[flag]}
        }

        return vk.ImageSubresourceRange {
                aspectMask     = mask,
                baseMipLevel   = 0,
                levelCount     = vk.REMAINING_MIP_LEVELS,
                baseArrayLayer = 0,
                layerCount     = vk.REMAINING_ARRAY_LAYERS,
        }
}


// ======================================
// DEVICE
// ======================================


_vk_instance_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Creating Vulkan instance")

        app_version := vk.MAKE_VERSION(
                config.APP_VERSION_MAJOR,
config.APP_VERSION_MINOR,
                config.APP_VERSION_PATCH
        )
        engine_version := vk.MAKE_VERSION(
                config.ENGINE_VERSION_MAJOR, 
                config.ENGINE_VERSION_MINOR,
                config.ENGINE_VERSION_PATCH
        )


        app_info := vk.ApplicationInfo {
                sType              = .APPLICATION_INFO,
                pApplicationName   = config.APP_NAME,
                applicationVersion = app_version,
                pEngineName        = "Callisto",
                engineVersion      = engine_version,
                apiVersion         = vk.API_VERSION_1_3,
        }

        // Layers
        layers := make([dynamic]cstring, context.temp_allocator)

        append(&layers, ..LAYERS)
        
        when VK_VALIDATION_LAYER {
                append(&layers, "VK_LAYER_KHRONOS_validation")
        }

        // Instance Extensions
        pNext: rawptr

        instance_extensions := make([dynamic]cstring, context.temp_allocator) 
        append(&instance_extensions, ..INSTANCE_EXTENSIONS)

        when ODIN_OS == .Windows {
                append(&instance_extensions, vk.KHR_WIN32_SURFACE_EXTENSION_NAME)
        }
        
        when VK_VALIDATION_LAYER {
                append(&instance_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)

                severity : vk.DebugUtilsMessageSeverityFlagsEXT = {.INFO, .WARNING, .ERROR}
                if config.VERBOSE {
                        severity += {.VERBOSE}
                }

                debug_create_info := vk.DebugUtilsMessengerCreateInfoEXT {
                        sType           = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
                        messageSeverity = severity,
                        messageType     = {.GENERAL, .VALIDATION, .PERFORMANCE, .DEVICE_ADDRESS_BINDING},
                        pfnUserCallback = init_info.runner.rhi_logger_proc,
pUserData       = init_info.runner,
                }

                when VK_ENABLE_INSTANCE_DEBUGGING {
                        debug_create_info.pNext = pNext
                        pNext = &debug_create_info
                }
        }


        if ok := _vk_prepend_layer_path(); ok == false {
                log.error("Could not prepend the Vulkan Layer environment variable")
        }

        log.debugf(" Layers: %#v", layers)
        log.debugf(" Instance extensions: %#v", instance_extensions)

        create_info := vk.InstanceCreateInfo {
                sType                   = .INSTANCE_CREATE_INFO,
                pNext                   = pNext,
                pApplicationInfo        = &app_info,
                enabledLayerCount       = len32(layers),
                ppEnabledLayerNames     = raw_data(layers),
                enabledExtensionCount   = len32(instance_extensions),
                ppEnabledExtensionNames = raw_data(instance_extensions),
        }

        vkres := d.CreateInstance(&create_info, nil, &d.instance)
        check_result(vkres) or_return
        defer if res != nil {
                d.DestroyInstance(d.instance, nil)
        }

        vk.load_proc_addresses_instance_vtable(d.instance, &d.vtable)


        when VK_VALIDATION_LAYER {
                vkres = d.CreateDebugUtilsMessengerEXT(d.instance, &debug_create_info, nil, &d.debug_messenger)
                check_result(vkres) or_return
        }
        
        return .Ok
}


_vk_physical_device_select :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Selecting physical device")

        phys_dev_count: u32
        vkres := d.EnumeratePhysicalDevices(d.instance, &phys_dev_count, nil)
        check_result(vkres) or_return

        phys_devices := make([]vk.PhysicalDevice, phys_dev_count, context.temp_allocator)
        vkres = d.EnumeratePhysicalDevices(d.instance, &phys_dev_count, raw_data(phys_devices))
        check_result(vkres) or_return


        best_index := -1
        best_score := -1
        for pd, i in phys_devices {
                score := _vk_physical_device_score(d, pd, init_info)
                if score > best_score {
                        best_index = i
                        best_score = score
                }
        }

        if best_index == -1 || best_score == -1 {
                log.error("No suitable GPU found!")
                return .No_Suitable_GPU
        }

        log.debug(" Selected physical device", best_index)
        d.phys_device = phys_devices[best_index]

        return .Ok
}


_vk_physical_device_score :: proc(d: ^Device, pd: vk.PhysicalDevice, init_info: ^Device_Init_Info) -> (score: int) {
        properties: vk.PhysicalDeviceProperties
        d.GetPhysicalDeviceProperties(pd, &properties)

        features: vk.PhysicalDeviceFeatures
        d.GetPhysicalDeviceFeatures(pd, &features)

        defer log.debugf(" - [%v] %s", score, properties.deviceName)


        extension_count: u32
        d.EnumerateDeviceExtensionProperties(pd, nil, &extension_count, nil)

        available_extensions := make([]vk.ExtensionProperties, extension_count, context.temp_allocator)

        d.EnumerateDeviceExtensionProperties(pd, nil, &extension_count, raw_data(available_extensions))

        // required_extensions_by_user := []vk.ExtensionProperties {}

        for req in DEVICE_EXTENSIONS {
                matched := false
                for &avail in available_extensions {
                        if (req == transmute(cstring)(&avail.extensionName)) {
                                matched = true
                                break
                        }
                }

                if matched == false {
                        return -1 // missing extension; not suitable
                }
        }


        score = 0

        if properties.deviceType == .DISCRETE_GPU {
                score += 10_000
        }

        score += int(properties.limits.maxImageDimension2D)

        return 
}


_vk_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Creating Vulkan device")

        count : u32
        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, nil)
        queue_family_props := make([]vk.QueueFamilyProperties, count, context.temp_allocator)

        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, raw_data(queue_family_props))


        unique_queue_families := make(map[u32]struct{}, context.temp_allocator)

        graphics_can_present : bool

        graphics_family      : u32
        compute_family       : u32
        present_family       : u32

        log.debug("  Queue families")

        found_good_queue := false // So we can debug print all the queues
        // Graphics queue
        for props, i in queue_family_props {
                can_present := _vk_query_queue_family_present_support(d, d.phys_device, u32(i)) 
                log.debugf("    - [%v] %v, CanPresent: %v", i, props.queueFlags, can_present)

                if !found_good_queue && props.queueFlags >= {.GRAPHICS, .COMPUTE}  {
                        unique_queue_families[u32(i)] = {}
                        graphics_family = u32(i)
                        compute_family = u32(i)
                        present_family = u32(i)
                        graphics_can_present = can_present 
                        found_good_queue = true
                }
        }

        // Async compute (optional)
        for props, i in queue_family_props {
                if .COMPUTE in props.queueFlags && .GRAPHICS not_in props.queueFlags {
                        unique_queue_families[u32(i)] = {}
                        compute_family = u32(i)
                        break
                }
        }

        // Rare case when graphics queue can't present, just get anything that can
        if !graphics_can_present {
                any_can_present := false
                for props, i in queue_family_props {
                        if _vk_query_queue_family_present_support(d, d.phys_device, u32(i)) {
                                unique_queue_families[u32(i)] = {}
                                present_family = u32(i)
                                break
                        }
                }
                if !any_can_present {
                        log.error("No queue families with Present support!")
                        return .No_Suitable_GPU
                }
        }
        


        log.debug("  Selected queue families")
        log.debug("    - Graphics:     ", graphics_family)
        log.debug("    - Present:      ", present_family)
        log.debug("    - Async compute:", compute_family)

        d.graphics_family      = graphics_family
        d.present_family       = present_family
        d.async_compute_family = compute_family

        queue_priorities : f32 = 1.0
        queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo, context.temp_allocator)

        for idx in unique_queue_families {
                // Create graphics queue
                queue_info := vk.DeviceQueueCreateInfo {
                        sType            = .DEVICE_QUEUE_CREATE_INFO,
                        queueFamilyIndex = idx,
                        queueCount       = 1,
                        pQueuePriorities = &queue_priorities,
                }

                append(&queue_create_infos, queue_info)
        }


        device_extensions := make([dynamic]cstring, context.temp_allocator)

        append(&device_extensions, ..DEVICE_EXTENSIONS)
        // append(&device_extensions, ..USER_DEVICE_EXTENSIONS)

        log.debugf("  Device extensions: %#v", device_extensions)


        pNext: rawptr
        // ADD PNEXT FEATURES HERE

        features := vk.PhysicalDeviceFeatures {
                samplerAnisotropy = true
        }

        vk11_features := vk.PhysicalDeviceVulkan11Features {
                sType                         = .PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
                pNext                         = pNext,
                variablePointers              = true,
                variablePointersStorageBuffer = true,
        }

        pNext = &vk11_features

        sync2_features := vk.PhysicalDeviceSynchronization2Features {
                sType            = .PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES,
                pNext            = pNext,
                synchronization2 = true,
        }

        pNext = &sync2_features


        buffer_device_address_features := vk.PhysicalDeviceBufferDeviceAddressFeatures {
                sType               = .PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES,
                pNext               = pNext,
                bufferDeviceAddress = true,
        }

        pNext = &buffer_device_address_features


        shader_object_features := vk.PhysicalDeviceShaderObjectFeaturesEXT {
                sType        = .PHYSICAL_DEVICE_SHADER_OBJECT_FEATURES_EXT,
                pNext        = pNext,
                shaderObject = true,
        }

        pNext = &shader_object_features


        descriptor_indexing_features := vk.PhysicalDeviceDescriptorIndexingFeatures {
                sType = .PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES,
                pNext = pNext,
                descriptorBindingPartiallyBound               = true,
                runtimeDescriptorArray                        = true,
                // Image Sampled
                shaderSampledImageArrayNonUniformIndexing     = true,
                descriptorBindingSampledImageUpdateAfterBind  = true,
                // Image Storage
                shaderStorageImageArrayNonUniformIndexing     = true,
                descriptorBindingStorageImageUpdateAfterBind  = true,
                // Uniform Buffer
                shaderUniformBufferArrayNonUniformIndexing    = true,
                descriptorBindingUniformBufferUpdateAfterBind = true,
                // Storage Buffer
                shaderStorageBufferArrayNonUniformIndexing    = true,
                descriptorBindingStorageBufferUpdateAfterBind = true,
        }

        pNext = &descriptor_indexing_features


        device_info := vk.DeviceCreateInfo {
                sType                   = .DEVICE_CREATE_INFO,
                pNext                   = pNext,
                queueCreateInfoCount    = len32(queue_create_infos),
                pQueueCreateInfos       = raw_data(queue_create_infos),
                pEnabledFeatures        = &features,
                enabledExtensionCount   = len32(device_extensions),
                ppEnabledExtensionNames = raw_data(device_extensions),
        }

        vkres := d.CreateDevice(d.phys_device, &device_info, nil, &d.device)
        check_result(vkres) or_return

        vk.load_proc_addresses_device_vtable(d.device, &d.vtable)

        // These will sometimes return the same queue, especially queue_present
        d.GetDeviceQueue(d.device, graphics_family, 0, &d.graphics_queue)
        d.GetDeviceQueue(d.device, compute_family, 0, &d.async_compute_queue)
        d.GetDeviceQueue(d.device, present_family, 0, &d.present_queue)



        return .Ok
}

_vk_descriptors_init :: proc(d: ^Device) -> Result {
        phys_props: vk.PhysicalDeviceProperties
        d.GetPhysicalDeviceProperties(d.phys_device, &phys_props)
        
        // DESCRIPTORS
        // Descriptor layout
        descriptor_binding_infos := []vk.DescriptorSetLayoutBinding {
                {
                        binding         = 0,
                        descriptorType  = .STORAGE_BUFFER,
                        // descriptorCount = phys_props.limits.maxDescriptorSetStorageBuffers,
                        descriptorCount = 1,
                        stageFlags      = vk.ShaderStageFlags_ALL,
                },
                {
                        binding         = 1,
                        descriptorType  = .COMBINED_IMAGE_SAMPLER,
                        // descriptorCount = phys_props.limits.maxDescriptorSetSamplers,
                        descriptorCount = 1,
                        stageFlags      = vk.ShaderStageFlags_ALL,
                },
                {
                        binding         = 2,
                        descriptorType  = .STORAGE_IMAGE,
                        // descriptorCount = phys_props.limits.maxDescriptorSetStorageImages,
                        descriptorCount = 1,
                        stageFlags      = vk.ShaderStageFlags_ALL,
                },
                // { // FEATURE(Ray tracing)
                //         binding         = 3,
                //         descriptorType  = .ACCELERATION_STRUCTURE_KHR,
                //         descriptorCount = 1000,
                //         stageFlags      = vk.ShaderStageFlags_ALL,
                // },
        }

        descriptor_binding_flags := []vk.DescriptorBindingFlags {
                {.PARTIALLY_BOUND, .UPDATE_AFTER_BIND},
                {.PARTIALLY_BOUND, .UPDATE_AFTER_BIND},
                {.PARTIALLY_BOUND, .UPDATE_AFTER_BIND},
                // {.PARTIALLY_BOUND, .UPDATE_AFTER_BIND},
        }

        descriptor_binding_flags_info := vk.DescriptorSetLayoutBindingFlagsCreateInfo {
                sType         = .DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO,
                bindingCount  = len32(descriptor_binding_flags),
                pBindingFlags = raw_data(descriptor_binding_flags),
        }


        descriptor_set_layout_info := vk.DescriptorSetLayoutCreateInfo {
                sType        = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
                pNext        = &descriptor_binding_flags_info,
                flags        = {.UPDATE_AFTER_BIND_POOL},
                bindingCount = len32(descriptor_binding_infos),
                pBindings    = raw_data(descriptor_binding_infos),
        }
        vkres := d.CreateDescriptorSetLayout(d.device, &descriptor_set_layout_info, nil, &d.bindless_layout)
        check_result(vkres) or_return


        // Descriptor pool
        descriptor_pool_sizes := []vk.DescriptorPoolSize {
                { .STORAGE_BUFFER, 1 }, // Does this need to be larger?
                { .COMBINED_IMAGE_SAMPLER, MAX_DESCRIPTORS },
                { .STORAGE_IMAGE, MAX_DESCRIPTORS },
                // { .ACCELERATION_STRUCTURE_KHR, 1000 }, // FEATURE(Ray tracing)
        }

        log.debug("Max Storage", phys_props.limits.maxDescriptorSetStorageBuffers)
        log.debug("Max Samplers", phys_props.limits.maxDescriptorSetSamplers)
        log.debug("Max Storage Images", phys_props.limits.maxDescriptorSetStorageImages)

        descriptor_pool_info := vk.DescriptorPoolCreateInfo {
                sType         = .DESCRIPTOR_POOL_CREATE_INFO,
                flags         = {.UPDATE_AFTER_BIND},
                poolSizeCount = len32(descriptor_pool_sizes),
                pPoolSizes    = raw_data(descriptor_pool_sizes),
                maxSets       = 1,
        }

        vkres = d.CreateDescriptorPool(d.device, &descriptor_pool_info, nil, &d.bindless_pool)
        check_result(vkres) or_return


        // Descriptor set
        descriptor_set_info := vk.DescriptorSetAllocateInfo {
                sType              = .DESCRIPTOR_SET_ALLOCATE_INFO,
                descriptorPool     = d.bindless_pool,
                descriptorSetCount = 1,
                pSetLayouts        = &d.bindless_layout,
        }

        vkres = d.AllocateDescriptorSets(d.device, &descriptor_set_info, &d.bindless_set)
        check_result(vkres) or_return

        // Push constant ranges - indices into descriptor buffer
        push_constant_ranges := []vk.PushConstantRange {
                { vk.ShaderStageFlags_ALL, 0, size_of([4]vk.DeviceAddress) },  // all 4 slots
        }

        // Pipeline layout
        pipeline_layout_info := vk.PipelineLayoutCreateInfo {
                sType                  = .PIPELINE_LAYOUT_CREATE_INFO,
                setLayoutCount         = 1,
                pSetLayouts            = &d.bindless_layout,
                pushConstantRangeCount = len32(push_constant_ranges),
                pPushConstantRanges    = raw_data(push_constant_ranges),
        }

        vkres = d.CreatePipelineLayout(d.device, &pipeline_layout_info, nil, &d.bindless_pipeline_layout)
        check_result(vkres) or_return


        _vk_descriptor_allocator_init(&d.descriptor_allocator_storage_tex)
        _vk_descriptor_allocator_init(&d.descriptor_allocator_sampled_tex)

        return .Ok
}

_vk_vma_init :: proc(d: ^Device) -> Result {
        // Is this ok? does vma copy the proc pointers?
        vkfuncs := vma.create_vulkan_functions(&d.vtable)
        create_info := vma.AllocatorCreateInfo {
                flags            = {.BUFFER_DEVICE_ADDRESS},
                physicalDevice   = d.phys_device,
                device           = d.device,
                instance         = d.instance,
                pVulkanFunctions = &vkfuncs,
        }

        vkres := vma.CreateAllocator(&create_info, &d.allocator)
        return check_result(vkres)
}

_vk_immediate_command_buffer_init :: proc(d: ^Device) -> Result {
        immediate_fence_info := Fence_Init_Info {
                begin_signaled = false,
        }
        _fence_init(d, &d.immediate_cb_fence, &immediate_fence_info) or_return


        immediate_cb_info := Command_Buffer_Init_Info {
                queue = .Graphics,
                signal_fence = &d.immediate_cb_fence,
        }
        _command_buffer_init(d, &d.immediate_cb, &immediate_cb_info) or_return

        return .Ok
}

_vk_vma_destroy :: proc(d: ^Device) {
        vma.DestroyAllocator(d.allocator)
}

_vk_instance_destroy :: proc(d: ^Device) {
        log.debug("Destroying Vulkan instance")
        when VK_VALIDATION_LAYER {
                d.DestroyDebugUtilsMessengerEXT(d.instance, d.debug_messenger, nil)
        }
        d.DestroyInstance(d.instance, nil)
}


_vk_device_destroy :: proc(d: ^Device) {
        log.debug("Destroying Vulkan device")
        d.DestroyDevice(d.device, nil)
}

_vk_descriptors_destroy :: proc(d: ^Device) {
        d.DestroyDescriptorPool(d.device, d.bindless_pool, nil)
        d.DestroyPipelineLayout(d.device, d.bindless_pipeline_layout, nil)
        d.DestroyDescriptorSetLayout(d.device, d.bindless_layout, nil)
}

_vk_immediate_command_buffer_destroy :: proc(d: ^Device) {
        _fence_destroy(d, &d.immediate_cb_fence)
        _command_buffer_destroy(d, &d.immediate_cb)
}

// ======================================
// SWAPCHAIN
// ======================================

_vk_swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info, old_swapchain: vk.SwapchainKHR = {}) -> (res: Result) {
        log.debug("Initializing Vulkan Swapchain")

        format: vk.SurfaceFormatKHR
        {
                count: u32
                vkres := d.GetPhysicalDeviceSurfaceFormatsKHR(d.phys_device, sc.surface, &count, nil)
                check_result(vkres) or_return

                avail_formats := make([]vk.SurfaceFormatKHR, int(count), context.temp_allocator)
                vkres = d.GetPhysicalDeviceSurfaceFormatsKHR(d.phys_device, sc.surface, &count, raw_data(avail_formats))
                check_result(vkres) or_return

                // Most common format is r8g8b8a8_srgb
                // HDR goes here!

                format = avail_formats[0] // default to first available
                log.debug("  Available surface formats")
                for f in avail_formats {
                        log.debugf("    - %v %v", f.format, f.colorSpace)
                        if f.format == .R8G8B8A8_SRGB && f.colorSpace == .SRGB_NONLINEAR {
                                format = f
                        }
                }

                log.debugf("  Selected surface format %v %v", format.format, format.colorSpace)
                sc.image_format = format
        }


        present_mode: vk.PresentModeKHR
        {

                requested_present_mode := _vk_vsync_to_present_mode(init_info.vsync)

                count: u32
                vkres := d.GetPhysicalDeviceSurfacePresentModesKHR(d.phys_device, sc.surface, &count, nil)
                check_result(vkres) or_return
                
                avail_present_modes := make([]vk.PresentModeKHR, int(count), context.temp_allocator)
                
                vkres = d.GetPhysicalDeviceSurfacePresentModesKHR(d.phys_device, sc.surface, &count, raw_data(avail_present_modes))
                check_result(vkres) or_return

                present_mode = .FIFO // default to vsync on
                log.debug("  Requested present mode:", requested_present_mode)
                log.debug("  Available present modes")
                for pm in avail_present_modes {
                        log.debugf("    - %v", pm)
                        if pm == requested_present_mode {
                                present_mode = pm
                        }
                }

                log.debugf("  Selected present mode %v", present_mode)
        }


        extent       : vk.Extent2D
        image_count  : u32
        pre_transform : vk.SurfaceTransformFlagsKHR
        {

                capabilities: vk.SurfaceCapabilitiesKHR
                vkres := d.GetPhysicalDeviceSurfaceCapabilitiesKHR(d.phys_device, sc.surface, &capabilities)
                check_result(vkres) or_return
                

                if capabilities.currentExtent.width != max(u32) {
                        extent = capabilities.currentExtent
                } else {
                        // magic number, provide window size
                        window_size := _vk_window_get_size(init_info.window)

                        extent = {
                                width  = clamp(window_size.x, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
                                height = clamp(window_size.y, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
                        }

                }
                        
                log.debugf("  Extent: %v, %v", capabilities.currentExtent.width, capabilities.currentExtent.height)
                sc.extent = extent

                image_count = capabilities.minImageCount + 1

                // 0 means no maximum
                if capabilities.maxImageCount > 0 {
                        image_count = clamp(image_count, capabilities.minImageCount, capabilities.maxImageCount)
                }
                
                log.debug("  Requested image count:", image_count)

                pre_transform = capabilities.currentTransform
        }


        queue_indices := [2]u32 { d.graphics_family, d.present_family }
        graphics_can_present := d.graphics_family == d.present_family

        swapchain_info := vk.SwapchainCreateInfoKHR {
                sType                 = .SWAPCHAIN_CREATE_INFO_KHR,
                surface               = sc.surface,
                minImageCount         = image_count,
                imageFormat           = format.format,
                imageColorSpace       = format.colorSpace,
                imageExtent           = extent,
                imageArrayLayers      = 1, // FEATURE(Stereo rendering)
                imageUsage            = {.COLOR_ATTACHMENT, .TRANSFER_DST},
                imageSharingMode      = .EXCLUSIVE if graphics_can_present else .CONCURRENT,
                queueFamilyIndexCount = 1 if graphics_can_present else 2,
                pQueueFamilyIndices   = raw_data(&queue_indices),
                preTransform          = pre_transform,
                compositeAlpha        = {.OPAQUE},
                presentMode           = present_mode,
                clipped               = !init_info.force_draw_occluded_fragments,
                oldSwapchain          = old_swapchain,
        }

        if d.graphics_queue == d.present_queue {
                swapchain_info.queueFamilyIndexCount = 1
        }


        vkres := d.CreateSwapchainKHR(d.device, &swapchain_info, nil, &sc.swapchain)
        check_result(vkres) or_return


        return .Ok
}

_vk_swapchain_images_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        // Images
        count: u32
        vkres := d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, nil)
        check_result(vkres) or_return
        log.debug("  Provided image count:", count)

        // ALLOCATION
        sc.textures = make([]Texture, count, context.allocator)

        temp_images := make([]vk.Image, count, context.temp_allocator)

        vkres = d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, raw_data(temp_images))
        check_result(vkres) or_return

        // Image views
        for i in 0..<count {
                sc.textures[i].image = temp_images[i]

                subresource_range := vk.ImageSubresourceRange {
                        aspectMask     = {.COLOR},
                        baseMipLevel   = 0,
                        levelCount     = 1,
                        baseArrayLayer = 0,
                        layerCount     = 1, // VR here!
                }

                image_view_info := vk.ImageViewCreateInfo {
                        sType            = .IMAGE_VIEW_CREATE_INFO,
                        image            = sc.textures[i].image,
                        viewType         = .D2,
                        format           = sc.image_format.format,
                        components       = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
                        subresourceRange = subresource_range,
                }

                vkres = d.CreateImageView(d.device, &image_view_info, nil, &sc.textures[i].full_view.view)
                check_result(vkres) or_return

                sc.textures[i].extent = vk.Extent3D {
                        width  = sc.extent.width,
                        height = sc.extent.height,
                        depth  = 1,
                }
        }

        return .Ok
}

_vk_swapchain_sync_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        fence_create_info := vk.FenceCreateInfo {
                sType = .FENCE_CREATE_INFO,
                flags = {.SIGNALED},
        }

        sema_create_info := vk.SemaphoreCreateInfo {
                sType = .SEMAPHORE_CREATE_INFO,
        }

        for i in 0..<FRAMES_IN_FLIGHT {
                vkres := d.CreateFence(d.device, &fence_create_info, nil, &sc.in_flight_fence[i])
                check_result(vkres) or_return

                vkres = d.CreateSemaphore(d.device, &sema_create_info, nil, &sc.image_available_sema[i])
                check_result(vkres) or_return
                vkres = d.CreateSemaphore(d.device, &sema_create_info, nil, &sc.render_finished_sema[i])
                check_result(vkres) or_return
        }

        when VK_VALIDATION_LAYER {

                image_avail_names := [?]cstring {
                        "Image_Available_0",
                        "Image_Available_1",
                        "Image_Available_2",
                }

                render_finished_names := [?]cstring {
                        "Render_Finished_0",
                        "Render_Finished_1",
                        "Render_Finished_2",
                }
                
                in_flight_names := [?]cstring {
                        "In_Flight_0",
                        "In_Flight_1",
                        "In_Flight_2",
                }

                for i in 0..<FRAMES_IN_FLIGHT {
                        ia_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .SEMAPHORE,
                                objectHandle = u64(sc.image_available_sema[i]),
                                pObjectName  = image_avail_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &ia_name_info)
                        
                        rc_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .SEMAPHORE,
                                objectHandle = u64(sc.render_finished_sema[i]),
                                pObjectName  = render_finished_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &rc_name_info)
                        
                        if_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .FENCE,
                                objectHandle = u64(sc.in_flight_fence[i]),
                                pObjectName  = in_flight_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &if_name_info)
                }
        }

        return .Ok
}

_vk_swapchain_command_buffers_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        sc.present_queue = d.present_queue

        for i in 0..<FRAMES_IN_FLIGHT {
                temp_image_available_sema := Semaphore {sc.image_available_sema[i]}
                temp_render_finished_sema := Semaphore {sc.render_finished_sema[i]}
                temp_in_flight_fence      := Fence {sc.in_flight_fence[i]}

                command_buffer_info := Command_Buffer_Init_Info {
                        queue            = .Graphics,
                        wait_semaphore   = &temp_image_available_sema,
                        signal_semaphore = &temp_render_finished_sema,
                        signal_fence     = &temp_in_flight_fence,
                }
                command_buffer_init(d, &sc.command_buffers[i], &command_buffer_info) or_return
        }

        return .Ok
}


_vk_vsync_to_present_mode :: proc(vs: Vsync_Mode) -> (pm: vk.PresentModeKHR) {
        switch vs {
        case .Double_Buffered : return .FIFO
        case .Triple_Buffered : return .MAILBOX
        case .Off             : return .IMMEDIATE,
        }

        return .FIFO
}

_vk_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        d.DestroySwapchainKHR(d.device, sc.swapchain, nil)
}

_vk_swapchain_images_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for tex in sc.textures {
                d.DestroyImageView(d.device, tex.full_view.view, nil)
        }

        delete(sc.textures)
}

_vk_swapchain_sync_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for i in 0..<FRAMES_IN_FLIGHT {
                d.DestroySemaphore(d.device, sc.image_available_sema[i], nil)
                d.DestroySemaphore(d.device, sc.render_finished_sema[i], nil)
                d.DestroyFence(d.device, sc.in_flight_fence[i], nil)
        }
}

_vk_swapchain_command_buffers_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for i in 0..<FRAMES_IN_FLIGHT {
                _command_buffer_destroy(d, &sc.command_buffers[i])
        }
}


_vk_swapchain_recreate :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        log.warn("Recreating Vulkan swapchain")

        // This is a naive implementation - should probably build a new swapchain
        // and wait for the old swapchain's final present before destroying it.
        vkres := d.DeviceWaitIdle(d.device)
        check_result(vkres) or_return

        info := Swapchain_Init_Info {
                window                        = sc.window,
                vsync                         = sc.vsync,
                force_draw_occluded_fragments = sc.force_draw_occluded,
        }

        _vk_swapchain_images_destroy(d, sc)
        _vk_swapchain_destroy(d, sc)

        _vk_swapchain_init(d, sc, &info) or_return
        _vk_swapchain_images_init(d, sc) or_return

        return .Ok
}


// ======================================
// COMMANDS
// ======================================

_Pipeline_Stage_To_Vk := [Pipeline_Stage]vk.PipelineStageFlag2 {
        .Draw_Indirect                  = .DRAW_INDIRECT,
        .Vertex_Input                   = .VERTEX_INPUT,
        .Vertex_Shader                  = .VERTEX_SHADER,
        .Tessellation_Control_Shader    = .TESSELLATION_CONTROL_SHADER,
        .Tessellation_Evaluation_Shader = .TESSELLATION_EVALUATION_SHADER,
        .Geometry_Shader                = .GEOMETRY_SHADER,
        .Fragment_Shader                = .FRAGMENT_SHADER,
        .Fragment_Early_Tests           = .EARLY_FRAGMENT_TESTS,
        .Fragment_Late_Tests            = .LATE_FRAGMENT_TESTS,
        .Color_Target_Output            = .COLOR_ATTACHMENT_OUTPUT,
        .Compute_Shader                 = .COMPUTE_SHADER,
        .Transfer                       = .TRANSFER,
        .Host                           = .HOST,
        .Copy                           = .COPY,
        .Resolve                        = .RESOLVE,
        .Blit                           = .BLIT,
        .Clear                          = .CLEAR,
        .Pre_Rasterization_Shaders      = .PRE_RASTERIZATION_SHADERS,
        .All_Transfer                   = .ALL_TRANSFER,
        .All_Graphics                   = .ALL_GRAPHICS,
        .All_Commands                   = .ALL_COMMANDS,
}

_vk_pipeline_stages :: proc(ps: Pipeline_Stages) -> vk.PipelineStageFlags2 {
        flags := vk.PipelineStageFlags2 {}

        for flag in ps {
                flags += {_Pipeline_Stage_To_Vk[flag]}
        }
        return flags
}

_Access_Flag_To_Vk := [Access_Flag]vk.AccessFlag2 {
        .Indirect_Read              = .INDIRECT_COMMAND_READ,
        .Index_Read                 = .INDEX_READ,
        .Vertex_Attribute_Read      = .VERTEX_ATTRIBUTE_READ,
        .Constant_Read               = .UNIFORM_READ,
        .Texture_Read               = .SHADER_SAMPLED_READ,
        .Texture_Write              = .SHADER_WRITE,
        .Storage_Read               = .SHADER_STORAGE_READ,
        .Storage_Write              = .SHADER_STORAGE_WRITE,
        .Color_Input_Read           = .COLOR_ATTACHMENT_READ,
        .Color_Target_Write         = .COLOR_ATTACHMENT_WRITE,
        .Depth_Stencil_Input_Read   = .DEPTH_STENCIL_ATTACHMENT_READ,
        .Depth_Stencil_Target_Write = .DEPTH_STENCIL_ATTACHMENT_WRITE,
        .Transfer_Read              = .TRANSFER_READ,
        .Transfer_Write             = .TRANSFER_WRITE,
        .Host_Read                  = .HOST_READ,
        .Host_Write                 = .HOST_WRITE,
        
        .Memory_Read                = .MEMORY_READ, // same as setting all `*_Read` bits
        .Memory_Write               = .MEMORY_WRITE, // same as setting all `*_Write` bits

}

_vk_access :: proc(access: Access_Flags) -> vk.AccessFlags2 {
        access := access
        flags := vk.AccessFlags2 {}

        for flag in access {
                flags += {_Access_Flag_To_Vk[flag]}
        }
        return flags
}

_Texture_Layout_To_Vk := [Texture_Layout]vk.ImageLayout {
        .Undefined       = .UNDEFINED,
        .General         = .GENERAL,
        .Target          = .ATTACHMENT_OPTIMAL,
        .Read_Only       = .READ_ONLY_OPTIMAL,
        .Transfer_Src    = .TRANSFER_SRC_OPTIMAL,
        .Transfer_Dst    = .TRANSFER_DST_OPTIMAL,
        .Pre_Initialized = .PREINITIALIZED,
        .Present         = .PRESENT_SRC_KHR,
}

// } // when RHI == "vulkan"
