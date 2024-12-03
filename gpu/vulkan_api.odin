package callisto_gpu

import "core:os/os2"
import vk "vulkan"
import "core:dynlib"
import "../common"
import "core:sync"
import "core:log"

// when RHI == "vulkan"
@(private)
VK_VALIDATION_LAYER          :: ODIN_DEBUG

@(private)
VK_ENABLE_INSTANCE_DEBUGGING :: false


// **IMPORTANT**: Don't use this vtable directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        using vtable         : vk.VTable,

        instance             : vk.Instance,
        debug_messenger      : vk.DebugUtilsMessengerEXT,
        phys_device          : vk.PhysicalDevice,
        device               : vk.Device,

        family_graphics      : u32,
        family_present       : u32,
        family_async_compute : u32,
        
        // Device owns the queues? One queue each per application
        queue_graphics      : vk.Queue,
        queue_present       : vk.Queue,
        queue_async_compute : vk.Queue,

        submit_mutex : sync.Mutex,
}

Swapchain :: struct {
        window          : Window_Handle,
        surface         : vk.SurfaceKHR,
        swapchain       : vk.SwapchainKHR,
        image_format    : vk.SurfaceFormatKHR,
        images          : []vk.Image, // acquired, don't destroy
        image_views     : []vk.ImageView,
        pending_destroy : vk.SwapchainKHR,

        present_sema : vk.Semaphore,
}


// Use a separate Command_Buffer per thread.
Command_Buffer :: struct {
        type: Command_Buffer_Type,
        was_transfer_used : bool,

        front_finished_fence: vk.Fence,

        // Internally triple-buffer so GPU can be working while we write the next buffer
        front_pool                : vk.CommandPool,
        idle_pool                 : vk.CommandPool,
        recording_pool            : vk.CommandPool,

        // Draw command buffers
        front_buffer              : vk.CommandBuffer,
        idle_buffer               : vk.CommandBuffer,
        recording_buffer          : vk.CommandBuffer,
        
        // Transfer command buffers
        front_transfer_buffer     : vk.CommandBuffer,
        idle_transfer_buffer      : vk.CommandBuffer,
        recording_transfer_buffer : vk.CommandBuffer,
}

Buffer         :: struct {}
Texture        :: struct {}
Sampler        :: struct {}
Shader         :: struct {}

Fence          :: struct {} // GPU -> CPU sync
Semaphore      :: struct {} // GPU -> GPU sync


device_init :: proc(d: ^Device, init_info: ^Device_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Device")

        validate_info(location,
                Valid_Not_Nil{".runner", init_info.runner},
        ) or_return


        _vk_loader(d)
        _vk_instance_init(d, init_info) or_return
        _vk_physical_device_select(d, init_info) or_return
        _vk_device_init(d, init_info) or_return

        return .Ok
}


device_destroy :: proc(d: ^Device) {
        log.info("Destroying Device")

        _vk_device_destroy(d)
        _vk_instance_destroy(d)
}


swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Swapchain")

        validate_info(location, 
                Valid_Not_Nil{".window", init_info.window}
        ) or_return

        _vk_surface_init(d, sc, init_info) or_return
        _vk_swapchain_init(d, sc, init_info) or_return

        return .Ok
}


swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        log.info("Destroying Swapchain")
        _vk_swapchain_destroy(d, sc)
        _vk_surface_destroy(d, sc)
}

// swapchain_rebuild             :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result)
// swapchain_set_vsync           :: proc(d: ^Device, sc: ^Swapchain, vsync: Vsync_Mode) -> (res: Result)
// swapchain_get_vsync           :: proc(d: ^Device, sc: ^Swapchain) -> (vsync: Vsync_Mode)
// swapchain_get_available_vsync :: proc(d: ^Device, sc: ^Swapchain) -> (vsyncs: Vsync_Modes)
swapchain_acquire_texture :: proc(d: ^Device, sc: ^Swapchain, texture: ^Texture) {

}

command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result) {
        log.info("Creating Command Buffer")
        return _vk_command_buffer_init(d, cb, init_info)
}

command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        log.info("Destroying Command Buffer")
        _vk_command_buffer_destroy(d, cb)
}

command_buffer_begin     :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_end       :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_submit    :: proc(d: ^Device, cb: ^Command_Buffer)

buffer_init              :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy           :: proc(d: ^Device, b: ^Buffer)
// buffer_transfer       :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init             :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy          :: proc(d: ^Device, t: ^Texture)

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

fence_reset              :: proc(d: ^Device, fences:[]^Fence) -> (res: Result)
fence_wait               :: proc(d: ^Device, fences: []^Fence) -> (res: Result)
cmd_fence_signal         :: proc(d: ^Device, fences: []^Fence)
cmd_semaphore_wait       :: proc(d: ^Device, semaphores: []^Semaphore)
cmd_semaphore_signal     :: proc(d: ^Device, semaphores: []^Semaphore)

cmd_set_scissor          :: proc(d: ^Device, cb: ^Command_Buffer, position: [2]int, size: [2]int)
cmd_clear_texture        :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)

cmd_render_begin :: proc(d: ^Device, cb: ^Command_Buffer, color_targets: []^Color_Target_Info, depth_stencil_target: ^Depth_Stencil_Target_Info)

cmd_bind_vertex_shader   :: proc(d: ^Device, cb: ^Command_Buffer, vs: ^Shader)
cmd_bind_fragment_shader :: proc(d: ^Device, cb: ^Command_Buffer, fs: ^Shader)

cmd_draw                 :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)

present                  :: proc(d: ^Device) // the command queue to some provided swapchain?


