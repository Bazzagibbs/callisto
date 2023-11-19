package callisto_graphics

import "core:log"
import "core:intrinsics"
import "core:os"
import "../config"
import "../asset"
import "../debug"
import "../platform"
import vkb "backend_vk"
import vk "vendor:vulkan"

when config.RENDERER_API == .Vulkan {
    Graphics_Context :: vkb.Graphics_Context
    cg_ctx: ^Graphics_Context

    cvk_bind_context :: proc(ctx: ^Graphics_Context) {
        cg_ctx = ctx
    }

    cvk_init :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
        vkb.create_instance(cg_ctx) or_return
        defer if !ok do vkb.destroy_instance(cg_ctx)

        // TODO: check if running headless in case we need to skip this
        vkb.create_surface(cg_ctx, window_ctx) or_return
        defer if !ok do vkb.destroy_surface(cg_ctx)

        vkb.select_physical_device(cg_ctx) or_return

        vkb.create_device(cg_ctx) or_return
        defer if !ok do vkb.destroy_device(cg_ctx)

        vkb.create_swapchain(cg_ctx, window_ctx) or_return
        defer if !ok do vkb.destroy_swapchain(cg_ctx)

        vkb.create_command_pools(cg_ctx) or_return
        defer if !ok do vkb.destroy_command_pools(cg_ctx)

        vkb.create_builtin_command_buffers(cg_ctx) or_return
        defer if !ok do vkb.destroy_builtin_command_buffers(cg_ctx)

        vkb.create_builtin_render_pass(cg_ctx) or_return
        defer if !ok do vkb.destroy_builtin_render_pass(cg_ctx)

        cg_ctx.render_pass_framebuffers = vkb.create_framebuffers(cg_ctx, cg_ctx.render_pass) or_return
        defer if !ok do vkb.destroy_framebuffers(cg_ctx, cg_ctx.render_pass_framebuffers)

        vkb.create_sync_structures(cg_ctx) or_return
        defer if !ok do vkb.destroy_sync_structures(cg_ctx)

        return true
    }

    cvk_shutdown :: proc(cg_ctx: ^Graphics_Context) {
        vk.DeviceWaitIdle(cg_ctx.device)

        vkb.destroy_sync_structures(cg_ctx)
        vkb.destroy_framebuffers(cg_ctx, cg_ctx.render_pass_framebuffers)
        vkb.destroy_builtin_render_pass(cg_ctx)
        vkb.destroy_builtin_command_buffers(cg_ctx)
        vkb.destroy_command_pools(cg_ctx)
        vkb.destroy_swapchain(cg_ctx)
        vkb.destroy_device(cg_ctx)
        vkb.destroy_surface(cg_ctx)
        vkb.destroy_instance(cg_ctx)
    }

    cvk_wait_until_idle :: proc() {
        vk.DeviceWaitIdle(cg_ctx.device)
    }

    cvk_create_shader :: proc(shader_description: ^Shader_Description) -> (shader: Shader, ok: bool) { 
        cvk_shader: ^vkb.CVK_Shader
        cvk_shader, ok = vkb.create_graphics_pipeline(cg_ctx, shader_description)
        if !ok {
            log.error("Failed to create shader")
        }

        return _as_shader(cvk_shader), ok
    }

    cvk_destroy_shader :: proc(shader: Shader) {
        cvk_shader := _as_cvk_shader(shader)
        vkb.destroy_pipeline(cg_ctx, cvk_shader)
    }

    cvk_create_material_from_shader :: proc(shader: Shader) -> (material: Material, ok: bool) { return {}, false }

    cvk_destroy_material :: proc(material: Material) {}

    cvk_create_static_mesh :: proc(mesh_asset: ^asset.Mesh) -> (mesh: Mesh, ok: bool) { 
        return {}, false 
    }

    cvk_destroy_static_mesh :: proc(mesh: Mesh) {}

    cvk_create_texture :: proc(texture_asset: ^asset.Texture) -> (texture: ^Texture, ok: bool) { 
        return {}, false 
    }

    cvk_destroy_texture :: proc(texture: Texture) {}

    cvk_set_clear_color :: proc(color: [4]f32) {
        cg_ctx.clear_color = color
    }


    // ==============================================================================

    cvk_cmd_begin_graphics :: proc() {
        sync_structures := &cg_ctx.sync_structures[cg_ctx.current_frame]

        vk.WaitForFences(cg_ctx.device, 1, &sync_structures.fence_in_flight, true, max(u64))
        vk.ResetFences(cg_ctx.device, 1, &sync_structures.fence_in_flight)

        vk.AcquireNextImageKHR(cg_ctx.device, cg_ctx.swapchain, max(u64), sync_structures.sem_image_available, {}, &cg_ctx.current_image_index)
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        vk.ResetCommandBuffer(graphics_buffer, {})

        begin_info := vk.CommandBufferBeginInfo {
            sType = .COMMAND_BUFFER_BEGIN_INFO,
            
        }

        vk.BeginCommandBuffer(graphics_buffer, &begin_info)
    }

    cvk_cmd_end_graphics  :: proc() {
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        vk.EndCommandBuffer(graphics_buffer)
    }


    cvk_cmd_submit_graphics :: proc() {
        // TODO(headless): Noop this command

        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        sync_structures := &cg_ctx.sync_structures[cg_ctx.current_frame]
        

        wait_semaphores := []vk.Semaphore { 
            sync_structures.sem_image_available,
        }

        wait_stages := vk.PipelineStageFlags {.COLOR_ATTACHMENT_OUTPUT}

        signal_semaphores := []vk.Semaphore {
            sync_structures.sem_render_finished,
        }

        submit_info := vk.SubmitInfo {
            sType                   = .SUBMIT_INFO,
            waitSemaphoreCount      = u32(len(wait_semaphores)),
            pWaitSemaphores         = raw_data(wait_semaphores),
            pWaitDstStageMask       = &wait_stages,
            commandBufferCount      = 1,
            pCommandBuffers         = &graphics_buffer,
            signalSemaphoreCount    = u32(len(signal_semaphores)),
            pSignalSemaphores       = raw_data(signal_semaphores),
        }

        res := vk.QueueSubmit(cg_ctx.graphics_queue, 1, &submit_info, sync_structures.fence_in_flight)
        vkb.check_result(res)
    }
    
    cvk_cmd_begin_transfer :: proc() {}
    cvk_cmd_end_transfer :: proc() {}
    cvk_cmd_submit_transfer :: proc() {}
    
    cvk_cmd_begin_compute :: proc() {}
    cvk_cmd_end_compute :: proc() {}
    cvk_cmd_submit_compute :: proc() {}

    cvk_cmd_begin_render_pass :: proc() {
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        framebuffer := cg_ctx.render_pass_framebuffers[cg_ctx.current_image_index]

        clear_values := []vk.ClearValue {
            {color = {float32 = cg_ctx.clear_color}},
        }

        begin_info := vk.RenderPassBeginInfo {
            sType = .RENDER_PASS_BEGIN_INFO,
            renderPass = cg_ctx.render_pass,
            framebuffer = framebuffer,
            clearValueCount = u32(len(clear_values)),
            pClearValues = raw_data(clear_values),
            renderArea = vk.Rect2D{
                offset = {0, 0},
                extent = cg_ctx.swapchain_extents,
            },
        }
        vk.CmdBeginRenderPass(graphics_buffer, &begin_info, .INLINE)
    }

    cvk_cmd_end_render_pass :: proc() {
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        vk.CmdEndRenderPass(graphics_buffer)
    }

    cvk_cmd_bind_shader :: proc(shader: Shader) {
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        cvk_shader := _as_cvk_shader(shader)
        vk.CmdBindPipeline(graphics_buffer, .GRAPHICS, cvk_shader.pipeline)
    }

    cvk_cmd_bind_uniforms_scene :: proc() {}
    cvk_cmd_bind_uniforms_pass :: proc() {}
    cvk_cmd_bind_uniforms_material :: proc(material: Material) {}
    cvk_cmd_bind_uniforms_model :: proc() {}

    cvk_cmd_draw :: proc(mesh: Mesh) {
        graphics_buffer := cg_ctx.graphics_command_buffers[cg_ctx.current_frame]
        vk.CmdDraw(graphics_buffer, 3, 1, 0, 0) // TEMP
    }

    cvk_cmd_present :: proc() {
        // TODO(headless): Noop this command
        wait_semaphores := []vk.Semaphore {
            cg_ctx.sync_structures[cg_ctx.current_frame].sem_render_finished,
        }

        swapchains := []vk.SwapchainKHR {
            cg_ctx.swapchain,
        }

        present_info := vk.PresentInfoKHR {
            sType               = .PRESENT_INFO_KHR,
            waitSemaphoreCount  = u32(len(wait_semaphores)),
            pWaitSemaphores     = raw_data(wait_semaphores),
            swapchainCount      = u32(len(swapchains)),
            pSwapchains         = raw_data(swapchains),
            pImageIndices       = &cg_ctx.current_image_index,
        }

        vk.QueuePresentKHR(cg_ctx.graphics_queue, &present_info)

        cg_ctx.current_image_index = (cg_ctx.current_image_index + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
    }


    // ==============================================================================

    @(private)
    _as_cvk_shader :: #force_inline proc(shader: Shader) -> ^vkb.CVK_Shader {
        return transmute(^vkb.CVK_Shader)shader
    }

    @(private)
    _as_shader :: #force_inline proc(cvk_shader: ^vkb.CVK_Shader) -> Shader {
        return transmute(Shader)cvk_shader
    }


    // ==============================================================================
    @(init)
    _load_cvk_procs :: proc() {
        bind_context                = cvk_bind_context                   
        init                        = cvk_init
        shutdown                    = cvk_shutdown
        wait_until_idle             = cvk_wait_until_idle
        create_shader               = cvk_create_shader
        destroy_shader              = cvk_destroy_shader
        create_material_from_shader = cvk_create_material_from_shader
        destroy_material            = cvk_destroy_material
        create_static_mesh          = cvk_create_static_mesh
        destroy_static_mesh         = cvk_destroy_static_mesh
        create_texture              = cvk_create_texture
        destroy_texture             = cvk_destroy_texture
        set_clear_color             = cvk_set_clear_color
                                     
        cmd_begin_graphics          = cvk_cmd_begin_graphics
        cmd_end_graphics            = cvk_cmd_end_graphics
        cmd_submit_graphics         = cvk_cmd_submit_graphics
        cmd_begin_transfer          = cvk_cmd_begin_transfer
        cmd_end_transfer            = cvk_cmd_end_transfer
        cmd_submit_transfer         = cvk_cmd_submit_transfer
        cmd_begin_compute           = cvk_cmd_begin_compute
        cmd_end_compute             = cvk_cmd_end_compute
        cmd_submit_compute          = cvk_cmd_submit_compute
                                                                   
        cmd_begin_render_pass       = cvk_cmd_begin_render_pass
        cmd_end_render_pass         = cvk_cmd_end_render_pass
                                                                   
        cmd_bind_shader             = cvk_cmd_bind_shader
                                                                   
        cmd_bind_uniforms_scene     = cvk_cmd_bind_uniforms_scene
        cmd_bind_uniforms_pass      = cvk_cmd_bind_uniforms_pass
        cmd_bind_uniforms_material  = cvk_cmd_bind_uniforms_material
        cmd_bind_uniforms_model     = cvk_cmd_bind_uniforms_model
                                                                   
        cmd_draw                    = cvk_cmd_draw
        cmd_present                 = cvk_cmd_present
    }
}
