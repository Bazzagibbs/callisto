package callisto_gpu

import dd "vendor:vulkan"

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

@(private)
FRAMES_IN_FLIGHT :: 3


// **IMPORTANT**: Don't use this vtable directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        using vtable         : vk.VTable,

        instance             : vk.Instance,
        debug_messenger      : vk.DebugUtilsMessengerEXT,
        phys_device          : vk.PhysicalDevice,
        device               : vk.Device,

        graphics_family      : u32,
        present_family       : u32,
        async_compute_family : u32,
        
        // Device owns the queues? One queue each per application
        graphics_queue      : vk.Queue,
        present_queue       : vk.Queue,
        async_compute_queue : vk.Queue,

        submit_mutex : sync.Mutex,
}

Swapchain :: struct {
        window               : Window_Handle,
        surface              : vk.SurfaceKHR,
        swapchain            : vk.SwapchainKHR,
        image_format         : vk.SurfaceFormatKHR,
        image_index          : u32,
        textures             : []Texture, // acquired, only destroy full_view
        pending_destroy      : vk.SwapchainKHR,

        image_available_sema : [FRAMES_IN_FLIGHT]vk.Semaphore,
        render_finished_sema : [FRAMES_IN_FLIGHT]vk.Semaphore,
        in_flight_fence      : [FRAMES_IN_FLIGHT]vk.Fence,
        command_buffers      : [FRAMES_IN_FLIGHT]Command_Buffer,

        graphics_queue       : vk.Queue, // Owned by Device
        present_queue        : vk.Queue,

        frame_counter        : u32,
        needs_recreate       : bool,
        vsync                : Vsync_Mode,
        force_draw_occluded  : bool,
}


// Use a separate Command_Buffer per thread.
Command_Buffer :: struct {
        type              : Command_Buffer_Type,

        pool              : vk.CommandPool,
        buffer            : vk.CommandBuffer,
}


Texture        :: struct {
        image     : vk.Image,
        full_view : Texture_View,
}

Texture_View   :: struct {
        view : vk.ImageView,
}

Sampler        :: struct {}
Shader         :: struct {}

Buffer         :: struct {}

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

swapchain_acquire_texture :: proc(d: ^Device, sc: ^Swapchain, texture: ^Texture) -> (res: Result) {
        return _vk_swapchain_acquire_next_image(d, sc, texture)
}

swapchain_acquire_command_buffer :: proc(d: ^Device, sc: ^Swapchain, cb: ^Command_Buffer) -> (res: Result) {
        cb^ = sc.command_buffers[sc.frame_counter]

        vkres := d.ResetCommandPool(d.device, cb.pool, {})
        check_result(vkres) or_return

        return .Ok
}

swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        unimplemented()
}

command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result) {
        log.info("Creating Command Buffer")
        return _vk_command_buffer_init(d, cb, init_info)
}

command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        log.info("Destroying Command Buffer")
        _vk_command_buffer_destroy(d, cb)
}

command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        return _vk_command_buffer_begin(d, cb)
}

command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        return _vk_command_buffer_end(d, cb)
}

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

cmd_set_scissor          :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_set_viewport         :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_texture_clear        :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)

cmd_set_shaders :: proc(d: ^Device, cb: ^Command_Buffer, shaders: []^Shader)
cmd_set_render_targets :: proc(d: ^Device, cb: ^Command_Buffer, color_target: ^Texture_View, depth_stencil_target: ^Texture_View)
// cmd_set_uniform_buffer :: proc(d: ^Device, cb: ^Command_Buffer, slot: u32, ub: ^Uniform_Buffer)

cmd_draw                 :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)

