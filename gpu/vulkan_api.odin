package callisto_gpu

import "core:os/os2"
import vk "vendor:vulkan"
import "core:dynlib"

// when RHI == "vulkan"

// **IMPORTANT**: Don't use these vtables directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        // I'm so sorry but it must be done for hot reload support
        using vtable_instance : VK_Instance_VTable,
        using vtable_device   : vk.Device_VTable,

        debug_messenger : vk.DebugUtilsMessengerEXT,
        instance        : vk.Instance,
        device          : vk.Device,
        phys_device     : vk.PhysicalDevice,
        phys_properties : vk.PhysicalDeviceProperties,
        phys_features   : vk.PhysicalDeviceFeatures,
        families        : vk.QueueFamilyProperties,
}


Buffer         :: struct {}
Texture        :: struct {}
Sampler        :: struct {}
Shader         :: struct {}

Command_Buffer :: struct {}
Queue          :: struct {}

Swapchain      :: struct {}
Fence          :: struct {} // GPU -> CPU sync
Semaphore      :: struct {} // GPU -> GPU sync


device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        _vk_instance_init(d, init_info) or_return
        // _vk_debug_messenger_init(d, init_info)
        _vk_physical_device_select(d, init_info) or_return
        _vk_device_init(d, init_info) or_return

        return .Ok
}


device_destroy :: proc(d: ^Device) {
        _vk_device_destroy(d)
        _vk_instance_destroy(d)
}


swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info) -> (res: Result)
swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain)

buffer_init              :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy           :: proc(d: ^Device, b: ^Buffer)
// buffer_transfer          :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init             :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy          :: proc(d: ^Device, t: ^Texture)

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

command_buffer_init      :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result)
command_buffer_destroy   :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_submit    :: proc(d: ^Device, cb: ^Command_Buffer)

cmd_clear                :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)

cmd_bind_vertex_shader   :: proc(d: ^Device, cb: ^Command_Buffer, vs: ^Shader)
cmd_bind_fragment_shader :: proc(d: ^Device, cb: ^Command_Buffer, fs: ^Shader)

cmd_draw                 :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)

present :: proc(d: ^Device) // the command queue to some provided swapchain?


