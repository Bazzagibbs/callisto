package callisto_graphics_vkb

import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"
import "core:log"
import "core:mem"


Gpu_Image :: struct {
    image:      vk.Image,
    allocation: vma.Allocation,
}


create_image :: proc(cg_ctx: ^Graphics_Context, format: vk.Format, usage: vk.ImageUsageFlags, extent: vk.Extent3D) -> (image: Gpu_Image, ok: bool) {
    image_info := vk.ImageCreateInfo {
        sType       = .IMAGE_CREATE_INFO,
        imageType   = .D2,
        format      = format,
        extent      = extent,
        mipLevels   = 1,
        arrayLayers = 1,
        samples     = {._1},
        tiling      = .OPTIMAL,
        usage       = usage,
    }

    alloc_info := vma.AllocationCreateInfo {
        usage           = .GPU_ONLY,
        requiredFlags   = {.DEVICE_LOCAL},
    }

    res := vma.CreateImage(cg_ctx.allocator, &image_info, &alloc_info, &image.image, &image.allocation, nil)
    check_result(res) or_return

    return image, true
}

destroy_image :: proc(cg_ctx: ^Graphics_Context, image: ^Gpu_Image) {
    vma.DestroyImage(cg_ctx.allocator, image.image, image.allocation)
}


create_image_view :: proc(cg_ctx: ^Graphics_Context, format: vk.Format, vk_image: vk.Image, aspect_flags: vk.ImageAspectFlags) -> (image_view: vk.ImageView, ok: bool) {
    view_info := vk.ImageViewCreateInfo {
        sType       = .IMAGE_VIEW_CREATE_INFO,
        viewType    = .D2,
        image       = vk_image,
        format      = format,
        subresourceRange = vk.ImageSubresourceRange {
            baseMipLevel    = 0,
            levelCount      = 1,
            baseArrayLayer  = 0,
            layerCount      = 1,
            aspectMask      = aspect_flags,
        },
    }

    res := vk.CreateImageView(cg_ctx.device, &view_info, nil, &image_view)
    check_result(res) or_return

    return image_view, true
}


// RENDER TARGET

render_target_create :: proc(cg_ctx: ^Graphics_Context) -> (target: CVK_Render_Target, ok: bool) {
    return {}, true
}

render_target_destroy :: proc(cg_ctx: ^Graphics_Context, target: ^CVK_Render_Target) {

}
