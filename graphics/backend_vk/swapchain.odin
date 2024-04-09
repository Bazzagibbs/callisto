package callisto_graphics_vulkan

import "../../common"
import vk "vendor:vulkan"
import "core:math"


swapchain_create :: proc(r: ^Renderer_Impl, desc: ^common.Engine_Description) -> (res: Result) {
    if r.swapchain_data.swapchain != {} {
        _swapchain_images_destroy(r)
    }
    
    support := _query_swapchain_support(r.physical_device, r.surface)
    defer _delete_swapchain_support(&support)

    surface_format := _swapchain_select_surface_format(r, &support)
    present_mode   := _swapchain_select_present_mode(r, desc.display_description, &support)
    extent         := _swapchain_select_extent(r, desc.display_description, &support)

    r.swapchain_data.format      = surface_format.format
    r.swapchain_data.color_space = surface_format.colorSpace

    image_count    := support.capabilities.minImageCount + 1
    if (support.capabilities.maxImageCount != 0) {
        image_count = math.min(image_count, support.capabilities.maxImageCount)
    }
                                                                                  
    swapchain_info := vk.SwapchainCreateInfoKHR {
        sType            = .SWAPCHAIN_CREATE_INFO_KHR,
        surface          = r.surface,
        imageFormat      = surface_format.format,
        imageColorSpace  = surface_format.colorSpace,
        imageExtent      = extent,
        imageUsage       = {.COLOR_ATTACHMENT}, 
        // imageUsage       = {.COLOR_ATTACHMENT, .TRANSFER_DST},
        imageSharingMode = .EXCLUSIVE,
        imageArrayLayers = 1, // Unless stereoscopic/multiview?
        preTransform     = support.capabilities.currentTransform,
        compositeAlpha   = {.OPAQUE},
        clipped          = true, 
        minImageCount    = image_count,
        presentMode      = present_mode,
        oldSwapchain     = r.swapchain_data.swapchain,
    }

    vk_res := vk.CreateSwapchainKHR(r.device, &swapchain_info, nil, &r.swapchain_data.swapchain)
    check_result(vk_res) or_return

    // Get images and create views
    actual_image_count: u32

    vk_res = vk.GetSwapchainImagesKHR(r.device, r.swapchain_data.swapchain, &actual_image_count, nil)
    check_result(vk_res) or_return
    
    images_temp := make([]vk.Image, actual_image_count)
    defer delete(images_temp)
    vk_res = vk.GetSwapchainImagesKHR(r.device, r.swapchain_data.swapchain, &actual_image_count, raw_data(images_temp))
    check_result(vk_res) or_return

    r.swapchain_data.images  = make([]Gpu_Image_Impl, actual_image_count)
    for image, i in images_temp {
        r.swapchain_data.images[i].image = image
        r.swapchain_data.images[i].view  = _image_view_create_internal(r, image, r.swapchain_data.format, {.COLOR}) or_return
    }

    return .Ok
}


swapchain_destroy :: proc(r: ^Renderer_Impl) {
    _swapchain_images_destroy(r)
    vk.DestroySwapchainKHR(r.device, r.swapchain_data.swapchain, nil)
    r.swapchain_data.swapchain = {}
}


_swapchain_images_destroy :: proc(r: ^Renderer_Impl) {
    for gpu_img in r.swapchain_data.images {
        vk.DestroyImageView(r.device, gpu_img.view, nil)
    }
    delete(r.swapchain_data.images)
}


Swapchain_Support_Details :: struct {
    capabilities:   vk.SurfaceCapabilitiesKHR,
    formats:        []vk.SurfaceFormatKHR,
    present_modes:  []vk.PresentModeKHR,
}

_query_swapchain_support :: proc(phys_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> Swapchain_Support_Details {
    details: Swapchain_Support_Details

    vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(phys_device, surface, &details.capabilities)
    
    fmt_count: u32
    vk.GetPhysicalDeviceSurfaceFormatsKHR(phys_device, surface, &fmt_count, nil)
    details.formats = make([]vk.SurfaceFormatKHR, fmt_count)
    vk.GetPhysicalDeviceSurfaceFormatsKHR(phys_device, surface, &fmt_count, raw_data(details.formats))

    present_mode_count: u32
    vk.GetPhysicalDeviceSurfacePresentModesKHR(phys_device, surface, &present_mode_count, nil)
    details.present_modes = make([]vk.PresentModeKHR, present_mode_count)
    vk.GetPhysicalDeviceSurfacePresentModesKHR(phys_device, surface, &present_mode_count, raw_data(details.present_modes))

    return details
}


_delete_swapchain_support :: proc(details: ^Swapchain_Support_Details) {
    delete(details.formats)
    delete(details.present_modes)
}

_swapchain_select_surface_format :: proc(r: ^Renderer_Impl, support: ^Swapchain_Support_Details) -> vk.SurfaceFormatKHR {
    for format in support.formats {
        if format.format == .B8G8R8A8_SRGB && format.colorSpace == .SRGB_NONLINEAR {
            return format
        }
    }

    return support.formats[0]
}


_swapchain_select_extent :: proc(r: ^Renderer_Impl, desc: ^common.Display_Description, support: ^Swapchain_Support_Details) -> vk.Extent2D {
    if support.capabilities.currentExtent.width != max(u32) {
        return support.capabilities.currentExtent
    }

    min := support.capabilities.minImageExtent
    max := support.capabilities.maxImageExtent

    extent := vk.Extent2D { 
        width  = math.clamp(desc.window_width, min.width, max.width),
        height = math.clamp(desc.window_height, min.height, max.height),
    }

    return extent
}


_swapchain_select_present_mode :: proc(r: ^Renderer_Impl, desc: ^common.Display_Description, support: ^Swapchain_Support_Details) -> vk.PresentModeKHR {
    pres_mode: vk.PresentModeKHR
    switch desc.vsync {
    case .Off           : pres_mode = .IMMEDIATE
    case .Double_Buffer : pres_mode = .FIFO_RELAXED
    case .Triple_Buffer : pres_mode = .MAILBOX
    }

    for mode in support.present_modes {
        if mode == pres_mode {
            return pres_mode
        }
    }

    return .FIFO
}
