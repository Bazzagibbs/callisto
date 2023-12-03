package callisto_graphics_vkb

import vk "vendor:vulkan"
import cc "../../common"

// render_pass_desc is not currently used. TODO: create render passes based on a loaded asset.
create_render_pass :: proc(cg_ctx: ^Graphics_Context, render_pass_desc: ^cc.Render_Pass_Description) -> (render_pass: ^CVK_Render_Pass, ok: bool) {
    // TODO(headless): noop if running in headless

    // All attachments used in the entire render pass
    attachment_descs := []vk.AttachmentDescription {
        {
            format          = cg_ctx.swapchain_format,
            samples         = {._1}, // TODO: Antialiasing
            loadOp          = .CLEAR,
            storeOp         = .STORE,
            stencilLoadOp   = .DONT_CARE,
            stencilStoreOp  = .DONT_CARE,
            initialLayout   = .UNDEFINED,
            finalLayout     = .PRESENT_SRC_KHR,
        },
        {
            format          = cg_ctx.depth_image_format,
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

    return cvk_rp, true
}


destroy_render_pass :: proc(cg_ctx: ^Graphics_Context, cvk_rp: ^CVK_Render_Pass) {
    vk.DestroyRenderPass(cg_ctx.device, cvk_rp.render_pass, nil)
    free(cvk_rp)
}

render_pass_get_framebuffer :: proc(cg_ctx: ^Graphics_Context, cvk_rp: ^CVK_Render_Pass) -> vk.Framebuffer {
    return cvk_rp.framebuffers[cvk_rp.current_image_index]
}

