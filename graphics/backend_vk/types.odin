package callisto_graphics_vulkan

import "../../common"
import "core:log"
import vk "vendor:vulkan"

MAX_FRAMES_IN_FLIGHT :: 2

Result :: common.Result

Renderer_Impl :: struct {
    instance                   : vk.Instance,
    surface                    : vk.SurfaceKHR,    
    physical_device            : vk.PhysicalDevice,
    physical_device_properties : vk.PhysicalDeviceProperties,
    queues                     : Queues,
    device                     : vk.Device,

    logger                     : log.Logger,
    debug_messenger            : vk.DebugUtilsMessengerEXT,
    frames                     : [MAX_FRAMES_IN_FLIGHT]Frame_Data,
}

Frame_Data :: struct {
    command_pools : Command_Pools,
}

Queues :: struct {
    compute_family  : u32,
    graphics_family : u32,
    transfer_family : u32,
    compute         : vk.Queue,
    graphics        : vk.Queue,
    transfer        : vk.Queue,
}

Command_Pools :: struct {
    compute  : vk.CommandPool,
    graphics : vk.CommandPool,
    transfer : vk.CommandPool,
}


Gpu_Image_Impl :: struct {}

Gpu_Buffer_Impl :: struct {}
