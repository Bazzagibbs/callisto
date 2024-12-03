#+private

package callisto_gpu

import "core:log"
import vk "vulkan"
// import dd "vendor:vulkan" // For autocomplete only


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
                defer delete(avail_present_modes, context.temp_allocator)
                
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
                        window_size := _window_get_size(init_info.window)

                        extent = {
                                width  = clamp(window_size.x, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
                                height = clamp(window_size.y, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
                        }

                }
                        
                log.debugf("  Extent: %v, %v", capabilities.currentExtent.width, capabilities.currentExtent.height)
                       

                image_count = capabilities.minImageCount + 1

                // 0 means no maximum
                if capabilities.maxImageCount > 0 {
                        image_count = clamp(image_count, capabilities.minImageCount, capabilities.maxImageCount)
                }
                
                log.debug("  Requested image count:", image_count)

                pre_transform = capabilities.currentTransform
        }

        queue_indices := [2]u32 { d.family_graphics, d.family_present }
        graphics_can_present := d.family_graphics == d.family_present

        swapchain_info := vk.SwapchainCreateInfoKHR {
                sType                 = .SWAPCHAIN_CREATE_INFO_KHR,
                surface               = sc.surface,
                minImageCount         = image_count,
                imageFormat           = format.format,
                imageColorSpace       = format.colorSpace,
                imageExtent           = extent,
                imageArrayLayers      = 1, // VR here!
                imageUsage            = {.COLOR_ATTACHMENT},
                imageSharingMode      = .EXCLUSIVE if graphics_can_present else .CONCURRENT,
                queueFamilyIndexCount = 1 if graphics_can_present else 2,
                pQueueFamilyIndices   = raw_data(&queue_indices),
                preTransform          = pre_transform,
                compositeAlpha        = {.OPAQUE},
                presentMode           = present_mode,
                clipped               = !init_info.force_draw_occluded_fragments,
                oldSwapchain          = old_swapchain,
        }

        if d.queue_graphics == d.queue_present {
                swapchain_info.queueFamilyIndexCount = 1
        }


        vkres := d.CreateSwapchainKHR(d.device, &swapchain_info, nil, &sc.swapchain)
        check_result(vkres) or_return


        count: u32
        vkres = d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, nil)
        check_result(vkres) or_return
        log.debug("  Provided image count:", count)

        // ALLOCATION
        sc.images = make([]vk.Image, count, context.allocator)
        vkres = d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, raw_data(sc.images))
        check_result(vkres) or_return

        // ALLOCATION
        sc.image_views = make([]vk.ImageView, count, context.allocator)

        for i in 0..<count {
                subresource_range := vk.ImageSubresourceRange {
                        aspectMask     = {.COLOR},
                        baseMipLevel   = 0,
                        levelCount     = 1,
                        baseArrayLayer = 0,
                        layerCount     = 1, // VR here!
                }

                image_view_info := vk.ImageViewCreateInfo {
                        sType            = .IMAGE_VIEW_CREATE_INFO,
                        image            = sc.images[i],
                        viewType         = .D2,
                        format           = sc.image_format.format,
                        components       = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
                        subresourceRange = subresource_range,
                }

                vkres = d.CreateImageView(d.device, &image_view_info, nil, &sc.image_views[i])
                check_result(vkres) or_return

        }

        return .Ok
}


_vk_vsync_to_present_mode :: proc(vs: Vsync_Mode) -> (pm: vk.PresentModeKHR) {
        switch vs {
        case .Double_Buffered: return .FIFO
        case .Triple_Buffered: return .MAILBOX
        case .No_Sync: return .IMMEDIATE,
        }

        return .FIFO
}

_vk_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for view in sc.image_views {
                d.DestroyImageView(d.device, view, nil)
        }

        delete(sc.image_views)
        delete(sc.images)
        d.DestroySwapchainKHR(d.device, sc.swapchain, nil)
}

_vk_swapchain_recreate :: proc(d: ^Device, sc: ^Swapchain) {}
