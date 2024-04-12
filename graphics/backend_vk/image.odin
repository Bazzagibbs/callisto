package callisto_graphics_vulkan

import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"
import "../../common"

gpu_image_create :: proc(r: ^Renderer_Impl, desc: ^Gpu_Image_Description) -> (gpu_img: ^Gpu_Image_Impl, res: Result) {
    gpu_img = new(Gpu_Image_Impl)
    
    image_create_info := vk.ImageCreateInfo {
        sType       = .IMAGE_CREATE_INFO,
        imageType   = .D2,
        format      = _to_vk_format(desc.format),
        extent      = vk.Extent3D {desc.width, desc.height, desc.depth},
        mipLevels   = 1,
        arrayLayers = 1,
        samples     = {._1}, // MSAA here if required
        tiling      = .OPTIMAL,
        usage       = _to_vk_usage(desc.usage),
    }
    
    alloc_create_info := vma.AllocationCreateInfo {
        usage = .AUTO,
        flags = _to_vma_flags(desc.access),
        priority = 1,
    }
    
    alloc_info: vma.AllocationInfo

    vk_res: vk.Result
    vk_res = vma.CreateImage(r.allocator, &image_create_info, &alloc_create_info, &gpu_img.image, &gpu_img.allocation, &alloc_info)
    check_result(vk_res) or_return

    return gpu_img, .Ok
}

gpu_image_destroy :: proc(r: ^Renderer_Impl, gpu_img: ^Gpu_Image_Impl) {
    vma.DestroyImage(r.allocator, gpu_img.image, gpu_img.allocation)
    vk.DestroyImageView(r.device, gpu_img.view, nil)
    free(gpu_img)
}


cmd_gpu_image_transition :: proc(command_buffer: vk.CommandBuffer, gpu_image: ^Gpu_Image_Impl, new_layout: vk.ImageLayout) {
    aspect_mask: vk.ImageAspectFlags = new_layout == .DEPTH_ATTACHMENT_OPTIMAL ? {.DEPTH} : {.COLOR}

    image_barriers := []vk.ImageMemoryBarrier2 { 
        {
            sType         = .IMAGE_MEMORY_BARRIER_2,
            image         = gpu_image.image,
            srcStageMask  = {.ALL_COMMANDS},
            srcAccessMask = {.MEMORY_WRITE},
            dstStageMask  = {.ALL_COMMANDS},
            dstAccessMask = {.MEMORY_READ, .MEMORY_WRITE},
            oldLayout     = gpu_image.layout,
            newLayout     = new_layout,
            subresourceRange = vk.ImageSubresourceRange {
                aspectMask     = aspect_mask,
                baseMipLevel   = 0,
                levelCount     = 1,
                baseArrayLayer = 0,
                layerCount     = 1,
            },
        },
    }

    dep_info := vk.DependencyInfo {
        sType                   = .DEPENDENCY_INFO,
        imageMemoryBarrierCount = u32(len(image_barriers)),
        pImageMemoryBarriers    = raw_data(image_barriers),
    }

    vk.CmdPipelineBarrier2(command_buffer, &dep_info)

    gpu_image.layout = new_layout
}


_image_view_create :: proc(r: ^Renderer_Impl, desc: ^Gpu_Image_Description, vk_image: vk.Image) -> (view: vk.ImageView, res: Result) {
    info := vk.ImageViewCreateInfo {
        sType    = .IMAGE_VIEW_CREATE_INFO,
        viewType = .D2,
        image    = vk_image,
        format   = _to_vk_format(desc.format),
        subresourceRange = vk.ImageSubresourceRange {
            baseMipLevel   = 0,
            levelCount     = 1,
            baseArrayLayer = 0,
            layerCount     = 1,
            aspectMask     = _to_vk_aspect(desc.aspect),
        },
    }

    flags := vk.ImageUsageFlag.SAMPLED
    vk_res := vk.CreateImageView(r.device, &info, nil, &view)
    check_result(vk_res) or_return

    return view, .Ok
}

_image_view_create_internal :: proc(r: ^Renderer_Impl, image: vk.Image, format: vk.Format, aspect: vk.ImageAspectFlags) -> (view: vk.ImageView, res: Result) {
    info := vk.ImageViewCreateInfo {
        sType    = .IMAGE_VIEW_CREATE_INFO,
        viewType = .D2,
        image    = image,
        format   = format,
        subresourceRange = vk.ImageSubresourceRange {
            baseMipLevel   = 0,
            levelCount     = 1,
            baseArrayLayer = 0,
            layerCount     = 1,
            aspectMask     = aspect,
        },
    }
    vk_res := vk.CreateImageView(r.device, &info, nil, &view)
    check_result(vk_res) or_return

    return view, .Ok
} 


_to_vk_format :: proc(format: common.Gpu_Image_Format) -> vk.Format {
    // Callisto Gpu_Image_Format is based off Vulkan format values
    return vk.Format(format)
}

_to_vk_aspect :: proc(aspect: common.Gpu_Image_Aspect_Flags) -> vk.ImageAspectFlags {

    _to_vk_aspect_flag :: proc(aspect_flag: common.Gpu_Image_Aspect_Flag) -> vk.ImageAspectFlag {
        switch aspect_flag {
        case .Color    : return .COLOR
        case .Depth    : return .DEPTH
        case .Stencil  : return .STENCIL
        case .Plane    : return .PLANE_0
        case .Metadata : return .METADATA
        }

        return {}
    }


    vk_aspect: vk.ImageAspectFlags
    for flag in common.Gpu_Image_Aspect_Flag do if flag in aspect {
        vk_aspect += {_to_vk_aspect_flag(flag)}
    }

    return vk_aspect
}


_to_vk_usage :: proc(usage: common.Gpu_Image_Usage_Flags) -> vk.ImageUsageFlags {
    _to_vk_usage_flag :: proc(usage_flag: common.Gpu_Image_Usage_Flag) -> vk.ImageUsageFlag {
        switch usage_flag {
        case .Transfer_Source          : return .TRANSFER_SRC
        case .Transfer_Dest            : return .TRANSFER_DST
        case .Sampled                  : return .SAMPLED
        case .Storage                  : return .STORAGE
        case .Color_Attachment         : return .COLOR_ATTACHMENT
        case .Depth_Stencil_Attachment : return .DEPTH_STENCIL_ATTACHMENT
        case .Transient_Attachment     : return .TRANSIENT_ATTACHMENT
        case .Input_Attachment         : return .INPUT_ATTACHMENT
        }

        return {}
    }

    vk_usage: vk.ImageUsageFlags
    for flag in common.Gpu_Image_Usage_Flag do if flag in usage {
        vk_usage += {_to_vk_usage_flag(flag)}
    }

    return vk_usage
}

_to_vma_flags :: proc(access: common.Gpu_Access_Flag) -> vma.AllocationCreateFlags {
    switch access {
    case .Gpu_Only   : return {.DEDICATED_MEMORY}
    case .Cpu_To_Gpu : return {.MAPPED, .HOST_ACCESS_SEQUENTIAL_WRITE}
    case .Gpu_To_Cpu : return {.MAPPED, .HOST_ACCESS_RANDOM}
    }

    return {}
}
