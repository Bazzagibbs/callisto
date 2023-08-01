package callisto_graphics_vulkan

import "core:os"
import "core:log"
import "core:image"
import "core:image/png"
import "core:image/qoi"
import "core:image/tga"
import "vendor:OpenEXRCore"

import "core:mem"
import vk "vendor:vulkan"
import "../common"

create_texture :: proc(texture_description: ^common.Texture_Description, texture: ^common.Texture) -> (ok: bool) {

    cvk_texture, err := new(CVK_Texture); if err != nil {
        log.error("Failed to allocate CVK_Texture:", err)
        return false
    }
    defer if !ok do free(cvk_texture)
    
    img: ^image.Image
    err_img: image.Error
    img, err_img = image.load(texture_description.image_path); if err_img != nil {
        log.error("Failed to load image:", err_img)
        return false
    }
    defer image.destroy(img)
    image.alpha_add_if_missing(img)
    
    pixels_size := u64(img.width * img.height * img.channels)
    staging_cvk_buffer := new(CVK_Buffer)
    create_buffer(pixels_size, {.TRANSFER_SRC}, {.HOST_VISIBLE, .HOST_COHERENT}, staging_cvk_buffer) or_return
    defer destroy_buffer(staging_cvk_buffer)

    image_format := build_vk_format(img.channels, img.depth, texture_description.color_space)

    // Copy pixels to staging buffer
    mapped_memory: rawptr
    vk.MapMemory(bound_state.device, staging_cvk_buffer.memory, 0, vk.DeviceSize(pixels_size), {}, &mapped_memory)
    mem.copy(mapped_memory, raw_data(img.pixels.buf), int(pixels_size))
    vk.UnmapMemory(bound_state.device, staging_cvk_buffer.memory)

    _create_vk_image(u32(img.width), u32(img.height), image_format, .OPTIMAL, {.TRANSFER_DST, .SAMPLED}, {.DEVICE_LOCAL}, &cvk_texture.image, &cvk_texture.memory) or_return

    _transition_vk_image_layout(cvk_texture.image, image_format, .UNDEFINED, .TRANSFER_DST_OPTIMAL)
    _copy_vk_buffer_to_vk_image(staging_cvk_buffer.buffer, cvk_texture.image, u32(img.width), u32(img.height))
    _transition_vk_image_layout(cvk_texture.image, image_format, .TRANSFER_DST_OPTIMAL, .SHADER_READ_ONLY_OPTIMAL)

    create_texture_image_view(cvk_texture.image, image_format, &cvk_texture.image_view) or_return

    texture^ = transmute(common.Texture)cvk_texture
    return true
}

destroy_texture :: proc(texture: common.Texture) {
    cvk_texture := transmute(^CVK_Texture)texture
    destroy_image_view(cvk_texture.image_view)
    vk.DestroyImage(bound_state.device, cvk_texture.image, nil)
    vk.FreeMemory(bound_state.device, cvk_texture.memory, nil)
    free(cvk_texture)
}


create_texture_image_view :: proc(img: vk.Image, img_format: vk.Format, img_view: ^vk.ImageView) -> (ok: bool) {
    return _create_vk_image_view(img, img_format, img_view)
}

destroy_image_view :: proc(image_view: vk.ImageView) {
    _destroy_vk_image_view(image_view)
}

_create_vk_image_view :: proc(img: vk.Image, format: vk.Format, img_view: ^vk.ImageView) -> (ok: bool) {
    image_view_create_info := vk.ImageViewCreateInfo {
        sType = .IMAGE_VIEW_CREATE_INFO,
        image = img,
        viewType = .D2,
        format = format,
        components = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
        subresourceRange = {
            aspectMask = {.COLOR},
            baseMipLevel = 0,
            levelCount = 1,
            baseArrayLayer = 0,
            layerCount = 1,
        },
    }

    res := vk.CreateImageView(bound_state.device, &image_view_create_info, nil, img_view); if res != .SUCCESS {
        log.error("Failed to create image views:", res)
        return false
    }

    return true
}

_destroy_vk_image_view :: proc(image_view: vk.ImageView) {
    vk.DestroyImageView(bound_state.device, image_view, nil)
}

_create_vk_texture_sampler :: proc(sampler: ^vk.Sampler) -> (ok: bool) {
    sampler_create_info := vk.SamplerCreateInfo {

    }

    res := vk.CreateSampler(bound_state.device, &sampler_create_info, nil, sampler); if res != .SUCCESS {
        log.error("Failed to create texture sampler:", res)
        return false
    }
    return true
}

_destroy_vk_texture_sampler :: proc(sampler: vk.Sampler) {
    vk.DestroySampler(bound_state.device,  sampler, nil)
}


_create_vk_image :: proc(width, height: u32, format: vk.Format, tiling: vk.ImageTiling, usage: vk.ImageUsageFlags, properties: vk.MemoryPropertyFlags, 
    image: ^vk.Image, memory: ^vk.DeviceMemory) -> (ok: bool) {

    image_create_info := vk.ImageCreateInfo {
        sType = .IMAGE_CREATE_INFO,
        imageType = .D2,
        extent = {
            width = width,
            height = height,
            depth = 1,
        },
        mipLevels = 1,
        arrayLayers = 1,
        format = format,
        tiling = tiling,
        initialLayout = .UNDEFINED,
        usage = usage,
        samples = {._1},
        sharingMode = .EXCLUSIVE,
    }

    res := vk.CreateImage(bound_state.device, &image_create_info, nil, image); if res != .SUCCESS {
        log.error("Failed to create image:", res)
        return false
    }
    defer if !ok do vk.DestroyImage(bound_state.device, image^, nil)

    memory_requirements: vk.MemoryRequirements
    vk.GetImageMemoryRequirements(bound_state.device, image^, &memory_requirements)
    memory_alloc_info := vk.MemoryAllocateInfo {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = memory_requirements.size,
        memoryTypeIndex = find_memory_type(memory_requirements.memoryTypeBits, properties),
    }

    res = vk.AllocateMemory(bound_state.device, &memory_alloc_info, nil, memory); if res != .SUCCESS {
        log.error("Failed to allocate memory for image:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(bound_state.device, memory^, nil)

    res = vk.BindImageMemory(bound_state.device, image^, memory^, 0); if res != .SUCCESS {
        log.error("Failed to bind image memory:", res)
        return false
    }

    return true
}

_transition_vk_image_layout :: proc(img: vk.Image, format: vk.Format, old_layout, new_layout: vk.ImageLayout) {
    temp_command_buffer: vk.CommandBuffer
    begin_one_shot_commands(&temp_command_buffer)
    defer end_one_shot_commands(temp_command_buffer)

    image_barrier := vk.ImageMemoryBarrier {
        sType = .IMAGE_MEMORY_BARRIER,
        oldLayout = old_layout,
        newLayout = new_layout,
        srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
        dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
        image = img,
        subresourceRange = {
            aspectMask = {.COLOR},
            baseMipLevel = 0,
            levelCount = 1,
            baseArrayLayer = 0,
            layerCount = 1,
        },
    }

    source_stage, destination_stage: vk.PipelineStageFlags

    if old_layout == .UNDEFINED && new_layout == .TRANSFER_DST_OPTIMAL {
        image_barrier.srcAccessMask = {}
        image_barrier.dstAccessMask = {.TRANSFER_WRITE}
        source_stage = {.TOP_OF_PIPE}
        destination_stage = {.TRANSFER}
    }
    else if old_layout == .TRANSFER_DST_OPTIMAL && new_layout == .SHADER_READ_ONLY_OPTIMAL {
        image_barrier.srcAccessMask = {.TRANSFER_WRITE}
        image_barrier.dstAccessMask = {.SHADER_READ}
        source_stage = {.TRANSFER}
        destination_stage = {.FRAGMENT_SHADER}
    }
    else {
        log.error("Unsupported image layout transition:", old_layout, "->", new_layout)
        return
    }

    vk.CmdPipelineBarrier(temp_command_buffer, 
        source_stage, destination_stage, 
        {}, 
        0, nil, 
        0, nil, 
        1, &image_barrier,
    )

}

build_vk_format :: proc(channels, bit_depth: int, color_space: common.Image_Color_Space) -> vk.Format {

    switch color_space {
        case .SRGB:
            switch bit_depth {
                case 8:
                    switch channels {
                        case 1:
                            return .R8_SRGB
                        case 2:
                            return .R8G8_SRGB
                        case 3:
                            return .R8G8B8_SRGB
                        case 4:
                            return .R8G8B8A8_SRGB
                    }
                case: 
                    log.error("Image bit depth", bit_depth, "not implemented")
                    break
            }

        case .LINEAR:
            fallthrough
        case: 
            log.error("Image color space", color_space, "not implemented") 
            break
    }
    
    return .UNDEFINED
}