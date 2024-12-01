package callisto_gpu

import "core:os/os2"
import vk "../vendor_mod/vulkan"
import "core:dynlib"
import "../common"
import "core:sync"
import "core:log"

// when RHI == "vulkan"

// **IMPORTANT**: Don't use this vtable directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        using vtable            : vk.VTable,

        instance                : vk.Instance,
        debug_messenger         : vk.DebugUtilsMessengerEXT,
        phys_device             : vk.PhysicalDevice,
        device                  : vk.Device,
        queue_graphics          : vk.Queue,
        queue_present           : vk.Queue,
        queue_async_compute     : vk.Queue,
        async_compute_is_shared : bool,
        present_is_shared       : bool,
        queue_submit_mutex      : sync.Mutex,
}

Swapchain :: struct {
        window  : Window_Handle,
        surface : vk.SurfaceKHR,
        // hdr
}

Buffer         :: struct {}
Texture        :: struct {}
Sampler        :: struct {}
Shader         :: struct {}

Command_Buffer :: struct {}
Queue          :: struct {}

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
        )

        _vk_surface_init(d, sc, init_info) or_return
        // _vk_swapchain_init(d, sc, init_info) or_return

        return .Ok
}

swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        // _vk_swapchain_destroy(d, sc)
        _vk_surface_destroy(d, sc)
}

swapchain_resize              :: proc(d: ^Device, sc: ^Swapchain, size: [2]i32) -> (res: Result)
swapchain_set_vsync           :: proc(d: ^Device, sc: ^Swapchain, vsync: Vsync_Mode) -> (res: Result)
swapchain_get_vsync           :: proc(d: ^Device, sc: ^Swapchain) -> (vsync: Vsync_Mode)
swapchain_get_available_vsync :: proc(d: ^Device, sc: ^Swapchain) -> (vsyncs: Vsync_Modes)

buffer_init                   :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy                :: proc(d: ^Device, b: ^Buffer)
// buffer_transfer            :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init                  :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy               :: proc(d: ^Device, t: ^Texture)

sampler_init                  :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy               :: proc(d: ^Device, s: ^Sampler)

shader_init                   :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy                :: proc(d: ^Device, s: ^Shader)

command_buffer_init           :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result)
command_buffer_destroy        :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_submit         :: proc(d: ^Device, cb: ^Command_Buffer)

cmd_clear                     :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)

cmd_bind_vertex_shader        :: proc(d: ^Device, cb: ^Command_Buffer, vs: ^Shader)
cmd_bind_fragment_shader      :: proc(d: ^Device, cb: ^Command_Buffer, fs: ^Shader)

cmd_draw                      :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)

present                       :: proc(d: ^Device) // the command queue to some provided swapchain?


