package callisto_graphics_vulkan

import vk "vendor:vulkan"
import "../../common"

gpu_image_create :: proc(r: ^Renderer_Impl, desc: ^Gpu_Image_Description) -> (gpu_img: ^Gpu_Image_Impl, res: Result) {
    gpu_img = new(Gpu_Image_Impl)

    return gpu_img, .Ok
}

gpu_image_destroy :: proc(r: ^Renderer_Impl, gpu_img: ^Gpu_Image_Impl) {
    vk.DestroyImageView(r.device, gpu_img.view, nil)
    vk.DestroyImage(r.device, gpu_img.image, nil)
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
    unimplemented("Gpu_Image_Format and Usage flags not implemented")
    // info := vk.ImageViewCreateInfo {
    //     sType    = .IMAGE_VIEW_CREATE_INFO,
    //     viewType = .D2,
    //     image    = vk_image,
    //     format   = _to_vk_format(desc.format),
    //     subresourceRange = vk.ImageSubresourceRange {
    //         baseMipLevel   = 0,
    //         levelCount     = 1,
    //         baseArrayLayer = 0,
    //         layerCount     = 1,
    //         aspectMask     = _to_vk_aspect_flags(desc.usage),
    //     },
    // }
    // vk_res := vk.CreateImageView(r.device, &info, nil, &view)
    // check_result(vk_res) or_return
    //
    // return view, .Ok
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
    return .UNDEFINED
}

_to_vk_aspect_flags :: proc(usage: common.Gpu_Image_Usage_Flags) -> vk.ImageAspectFlags {
    return {.COLOR}
}
