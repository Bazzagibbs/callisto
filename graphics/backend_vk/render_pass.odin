package callisto_graphics_vkb

import vk "vendor:vulkan"
import cc "../../common"
import "../../config"

// render_pass_desc is not currently used. TODO(srp): create render passes based on a loaded asset.
create_render_pass :: proc(cg_ctx: ^Graphics_Context, render_pass_desc: ^cc.Render_Pass_Description) -> (render_pass: ^CVK_Render_Pass, ok: bool) {
    // TODO(headless): noop if running in headless

    cvk_render_target: ^CVK_Render_Target 
    if render_pass_desc.is_present_output {
        cvk_render_target = &cg_ctx.swapchain_render_target
    } else {
        cvk_render_target = as_cvk_render_target(render_pass_desc.render_target)
    }

    depth_format := cg_ctx.depth_render_target.format

    // All attachments used in the entire render pass
    attachment_descs := []vk.AttachmentDescription {
        {
            format          = cvk_render_target.format,
            samples         = {._1}, // TODO(srp): Antialiasing
            loadOp          = .CLEAR,
            storeOp         = .STORE,
            stencilLoadOp   = .DONT_CARE,
            stencilStoreOp  = .DONT_CARE,
            initialLayout   = .UNDEFINED,
            finalLayout     = .PRESENT_SRC_KHR,
        },
        {
            format          = depth_format,
            samples         = {._1},
            loadOp          = .CLEAR,
            storeOp         = .STORE,
            stencilLoadOp   = .CLEAR,
            stencilStoreOp  = .DONT_CARE,
            initialLayout   = .UNDEFINED,
            finalLayout     = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
        },
    }

    // References attachments to be used in a subpass and describes how they're used
    // One of these slices may be made per subpass
    color_refs := []vk.AttachmentReference {
        {
            attachment  = 0,
            layout      = .COLOR_ATTACHMENT_OPTIMAL,
        },
    }
    
    depth_stencil_ref := vk.AttachmentReference {
        attachment  = 1,
        layout      = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    }


    // Describes all subpasses used in the render pass
    subpass_descs := []vk.SubpassDescription {
        {
            pipelineBindPoint       = .GRAPHICS,
            colorAttachmentCount    = u32(len(color_refs)),
            pColorAttachments       = raw_data(color_refs),
            pDepthStencilAttachment = &depth_stencil_ref,
        },
    }
    
    // Describes the flow of subpasses
    subpass_depends := []vk.SubpassDependency {
        {   // Color
            srcSubpass      = vk.SUBPASS_EXTERNAL,          // Subpass entry point
            dstSubpass      = 0,                            // Subpass index 0
            srcStageMask    = {.COLOR_ATTACHMENT_OUTPUT},
            srcAccessMask   = {},
            dstStageMask    = {.COLOR_ATTACHMENT_OUTPUT},
            dstAccessMask   = {.COLOR_ATTACHMENT_WRITE},
        },
        {   // Depth
            srcSubpass      = vk.SUBPASS_EXTERNAL,          // Subpass entry point
            dstSubpass      = 0,                            // Subpass index 0
            srcStageMask    = {.EARLY_FRAGMENT_TESTS, .LATE_FRAGMENT_TESTS},
            srcAccessMask   = {},
            dstStageMask    = {.EARLY_FRAGMENT_TESTS, .LATE_FRAGMENT_TESTS},
            dstAccessMask   = {.DEPTH_STENCIL_ATTACHMENT_WRITE},
        },
    }
    

    render_pass_create_info := vk.RenderPassCreateInfo {
        sType           = .RENDER_PASS_CREATE_INFO,
        attachmentCount = u32(len(attachment_descs)),
        pAttachments    = raw_data(attachment_descs),
        subpassCount    = u32(len(subpass_descs)),
        pSubpasses      = raw_data(subpass_descs),
        dependencyCount = u32(len(subpass_depends)),
        pDependencies   = raw_data(subpass_depends),
    }

    cvk_rp := new(CVK_Render_Pass)

    res := vk.CreateRenderPass(cg_ctx.device, &render_pass_create_info, nil, &cvk_rp.render_pass)
    check_result(res) or_return
    defer if !ok do vk.DestroyRenderPass(cg_ctx.device, cvk_rp.render_pass, nil)

    cvk_rp.ubo_type = render_pass_desc.ubo_type

    render_pass_create_uniform_buffer(cg_ctx, cvk_rp) or_return
    defer if !ok do render_pass_destroy_uniform_buffer(cg_ctx, cvk_rp)

    if render_pass_desc.is_present_output {
        cvk_rp.framebuffers = create_swapchain_framebuffers(cg_ctx, cvk_rp.render_pass) or_return
    } else {
        // TODO(srp)
        unimplemented("Create a framebuffer for non-swapchain render targets")
    }

    cvk_rp.render_target = cvk_render_target

    return cvk_rp, true
}


destroy_render_pass :: proc(cg_ctx: ^Graphics_Context, cvk_rp: ^CVK_Render_Pass) {
    destroy_framebuffers(cg_ctx, cvk_rp.framebuffers)
    vk.DestroyPipelineLayout(cg_ctx.device, cvk_rp.pipeline_layout, nil)
    vk.DestroyRenderPass(cg_ctx.device, cvk_rp.render_pass, nil)
    free(cvk_rp)
}

render_pass_create_uniform_buffer :: proc(cg_ctx: ^Graphics_Context, render_pass: ^CVK_Render_Pass) -> (ok: bool) {
    pool_sizes := []vk.DescriptorPoolSize {
        { .UNIFORM_BUFFER, 10 },
        { .UNIFORM_BUFFER_DYNAMIC, 10 },
    }

    pool_info := vk.DescriptorPoolCreateInfo {
        sType           = .DESCRIPTOR_POOL_CREATE_INFO,
        maxSets         = 10,
        poolSizeCount   = u32(len(pool_sizes)),
        pPoolSizes      = raw_data(pool_sizes),
    }

    res := vk.CreateDescriptorPool(cg_ctx.device, &pool_info, nil, &render_pass.descriptor_pool)
    check_result(res) or_return
    defer if !ok do vk.DestroyDescriptorPool(cg_ctx.device, render_pass.descriptor_pool, nil)

    layout_bindings := [] vk.DescriptorSetLayoutBinding {
        // 0: Scene 
        {   // 1: Render pass
            binding         = 1,
            descriptorCount = 1,
            descriptorType  = .UNIFORM_BUFFER_DYNAMIC,
            stageFlags      = {.VERTEX},
        },
        // 2: Material
        // 3: Instance
    }

    set_info := vk.DescriptorSetLayoutCreateInfo {
        sType           = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        bindingCount    = u32(len(layout_bindings)),
        pBindings       = raw_data(layout_bindings),
    }

    res = vk.CreateDescriptorSetLayout(cg_ctx.device, &set_info, nil, &render_pass.descriptor_layout)
    check_result(res) or_return
    defer if !ok do vk.DestroyDescriptorSetLayout(cg_ctx.device, render_pass.descriptor_layout, nil)

    desc_layouts := []vk.DescriptorSetLayout {
        render_pass.descriptor_layout,
    }

    pipeline_layout_info := vk.PipelineLayoutCreateInfo {
        sType           = .PIPELINE_LAYOUT_CREATE_INFO,
        setLayoutCount  = u32(len(desc_layouts)),
        pSetLayouts     = raw_data(desc_layouts),
    }

    res = vk.CreatePipelineLayout(cg_ctx.device, &pipeline_layout_info, nil, &render_pass.pipeline_layout)
    check_result(res) or_return
    defer if !ok do vk.DestroyPipelineLayout(cg_ctx.device, render_pass.pipeline_layout, nil)
    
    // for &frame in cg_ctx.frame_data {
    rp_buffer_size := ubo_size_padded(cg_ctx, type_info_of(render_pass.ubo_type).size) * config.RENDERER_FRAMES_IN_FLIGHT
    render_pass.uniform_buffer = create_buffer(cg_ctx, rp_buffer_size, {.UNIFORM_BUFFER}, .CPU_TO_GPU) or_return

    desc_set_alloc_info := vk.DescriptorSetAllocateInfo {
        sType               = .DESCRIPTOR_SET_ALLOCATE_INFO,
        descriptorPool      = render_pass.descriptor_pool,
        descriptorSetCount  = 1,
        pSetLayouts         = &render_pass.descriptor_layout,
    }
    res = vk.AllocateDescriptorSets(cg_ctx.device, &desc_set_alloc_info, &render_pass.uniform_set)
    check_result(res) or_return

    buffer_info := vk.DescriptorBufferInfo {
        buffer  = render_pass.uniform_buffer.buffer,
        offset  = 0,
        range   = vk.DeviceSize(size_of(cc.Render_Pass_Uniforms)),
    }

    write_set := vk.WriteDescriptorSet {
        sType           = .WRITE_DESCRIPTOR_SET,
        dstBinding      = 1,
        dstSet          = render_pass.uniform_set,
        descriptorCount = 1,
        descriptorType  = .UNIFORM_BUFFER_DYNAMIC,
        pBufferInfo     = &buffer_info,
    }

    vk.UpdateDescriptorSets(cg_ctx.device, 1, &write_set, 0, nil)

    return true
}


render_pass_destroy_uniform_buffer :: proc(cg_ctx: ^Graphics_Context, render_pass: ^CVK_Render_Pass) {
    destroy_buffer(cg_ctx, &render_pass.uniform_buffer)

    vk.DestroyDescriptorSetLayout(cg_ctx.device, render_pass.descriptor_layout, nil)
    vk.DestroyDescriptorPool(cg_ctx.device, render_pass.descriptor_pool, nil)
}


render_pass_get_framebuffer :: proc(cg_ctx: ^Graphics_Context, render_pass: ^CVK_Render_Pass) -> vk.Framebuffer {
    if render_pass.is_present_output {
        frame, _ := current_frame_data(cg_ctx)
        return render_pass.framebuffers[frame.swapchain_image_index]
    }

    return render_pass.framebuffers[0]
}
