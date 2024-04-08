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
    swapchain_data             : Swapchain_Data,

    logger                     : log.Logger,
    debug_messenger            : vk.DebugUtilsMessengerEXT,
    frames                     : [MAX_FRAMES_IN_FLIGHT]Frame_Data,
}

Swapchain_Data :: struct {
    swapchain               : vk.SwapchainKHR,
    format                  : vk.Format,
    color_space             : vk.ColorSpaceKHR,
    images                  : []Gpu_Image_Impl,
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


Gpu_Image_Impl :: struct {
    image : vk.Image,
    view  : vk.ImageView,
}

Gpu_Buffer_Impl :: struct {}

Gpu_Image_Description         :: common.Gpu_Image_Description
Gpu_Buffer_Description        :: common.Gpu_Buffer_Description
Gpu_Buffer_Upload_Description :: common.Gpu_Buffer_Upload_Description
