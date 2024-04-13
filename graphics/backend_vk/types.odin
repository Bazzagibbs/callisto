package callisto_graphics_vulkan

import "../../common"
import "core:log"
import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"

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

    frame_idx                  : int,
    frames                     : [MAX_FRAMES_IN_FLIGHT]Frame_Data,
    
    logger                     : log.Logger,
    debug_messenger            : vk.DebugUtilsMessengerEXT,
    allocator                  : vma.Allocator,
}

Swapchain_Data :: struct {
    swapchain               : vk.SwapchainKHR,
    format                  : vk.Format,
    color_space             : vk.ColorSpaceKHR,
    image_idx               : u32,
    images                  : []Gpu_Image_Impl,
    
    draw_target                : ^Gpu_Image_Impl,
    draw_extent                : vk.Extent2D,
}


Frame_Data :: struct {
    command_pools   : Command_Pools,
    command_buffers : Command_Buffers,

    sem_swapchain   : vk.Semaphore,
    sem_render      : vk.Semaphore,
    fence_render    : vk.Fence,
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

Command_Buffers :: struct {
    compute  : vk.CommandBuffer,
    graphics : vk.CommandBuffer,
    transfer : vk.CommandBuffer,
    
}


Gpu_Image_Impl :: struct {
    image      : vk.Image,
    view       : vk.ImageView,
    layout     : vk.ImageLayout,
    format     : vk.Format,
    aspect     : vk.ImageAspectFlags,
    extent     : vk.Extent3D,
    usage      : vk.ImageUsageFlags,
    filter     : vk.Filter,

    allocation : vma.Allocation,
}

Gpu_Buffer_Impl :: struct {}

Gpu_Image_Description         :: common.Gpu_Image_Description
Gpu_Buffer_Description        :: common.Gpu_Buffer_Description
Gpu_Buffer_Upload_Description :: common.Gpu_Buffer_Upload_Description
