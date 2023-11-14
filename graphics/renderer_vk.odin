package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"
import "../asset"
import "../debug"
import "../platform"
import vkb "backend_vk"
import vk "vendor:vulkan"

when config.RENDERER_API == .Vulkan {
    Graphics_Context :: vkb.Graphics_Context
    cg_ctx: ^Graphics_Context

    bind_context :: proc(ctx: ^Graphics_Context) {
        cg_ctx = ctx
    }

    init :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
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

    shutdown :: proc(cg_ctx: ^Graphics_Context) {
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

    wait_until_idle :: proc() 

    create_shader :: proc(shader_description: ^Shader_Description) -> (shader: Shader, ok: bool)

    destroy_shader :: proc(shader: Shader) 

    create_material_from_shader :: proc(shader: Shader) -> (material: Material, ok: bool)

    destroy_material :: proc(material: Material)

    create_static_mesh :: proc(mesh_asset: ^asset.Mesh) -> (mesh: Mesh, ok: bool)

    destroy_static_mesh :: proc(mesh: Mesh) 

    create_texture :: proc(texture_asset: ^asset.Texture) -> (texture: ^Texture, ok: bool)

    destroy_texture :: proc(texture: Texture) 


    // ==============================================================================

    cmd_begin_graphics :: proc() {
        
    }

    cmd_end_graphics  :: proc() {

    }

    cmd_submit_graphics :: proc() {
        // TODO(headless): Noop this command
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
            pCommandBuffers         = &cg_ctx.graphics_command_buffers[cg_ctx.current_frame],
            signalSemaphoreCount    = u32(len(signal_semaphores)),
            pSignalSemaphores       = raw_data(signal_semaphores),
        }

        vk.QueueSubmit(cg_ctx.graphics_queue, 1, &submit_info, sync_structures.fence_in_flight)
    }
    
    cmd_begin_transfer :: proc()
    cmd_end_transfer :: proc()
    cmd_submit_transfer :: proc()
    
    cmd_begin_compute :: proc()
    cmd_end_compute :: proc()
    cmd_submit_compute :: proc()

    cmd_begin_render_pass :: proc() 
    cmd_end_render_pass :: proc() 

    cmd_bind_uniforms_scene :: proc()
    cmd_bind_uniforms_pass :: proc()
    cmd_bind_uniforms_material :: proc(material: Material) 
    cmd_bind_uniforms_model :: proc()

    cmd_draw :: proc(mesh: Mesh) 

    cmd_present :: proc() {
        // TODO(headless): Noop this command
        wait_semaphores := []vk.Semaphore {
            cg_ctx.sync_structures[cg_ctx.current_frame].sem_render_finished,
        }

        present_info := vk.PresentInfoKHR {
            sType               = .PRESENT_INFO_KHR,
            waitSemaphoreCount  = u32(len(wait_semaphores)),
            pWaitSemaphores     = raw_data(wait_semaphores),
        }

        vk.QueuePresentKHR(cg_ctx.graphics_queue, &present_info)
    }

    // Also need some commands for compute and upload
}
