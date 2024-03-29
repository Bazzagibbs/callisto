package callisto_graphics

import "core:log"
import "core:intrinsics"
import "core:os"
import "core:runtime"
import "core:mem"
import "../config"
import "../asset"
import "../debug"
import "../platform"
import vkb "backend_vk"
import vma "backend_vk/vulkan-memory-allocator"
import vk "vendor:vulkan"
import cc "../common"

when config.RENDERER_API == .Vulkan {
    Graphics_Context :: vkb.Graphics_Context
   
    cg_ctx: ^Graphics_Context


    cvk_bind_context :: proc(ctx: ^Graphics_Context) {
        cg_ctx = ctx
    }

    cvk_init :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
        vkb.init_graphics_context(cg_ctx)
        defer if !ok do vkb.destroy_graphics_context(cg_ctx)

        vkb.create_instance(cg_ctx) or_return
        defer if !ok do vkb.destroy_instance(cg_ctx)

        // TODO(headless): check if running headless in case we need to skip this
        vkb.create_surface(cg_ctx, window_ctx) or_return
        defer if !ok do vkb.destroy_surface(cg_ctx)

        vkb.select_physical_device(cg_ctx) or_return

        vkb.create_device(cg_ctx) or_return
        defer if !ok do vkb.destroy_device(cg_ctx)
        
        vkb.create_allocator(cg_ctx) or_return
        defer if !ok do vkb.destroy_allocator(cg_ctx)

        vkb.create_swapchain(cg_ctx, window_ctx) or_return
        defer if !ok do vkb.destroy_swapchain(cg_ctx)

        vkb.create_command_pools(cg_ctx) or_return
        defer if !ok do vkb.destroy_command_pools(cg_ctx)

        vkb.create_builtin_command_buffers(cg_ctx) or_return
        defer if !ok do vkb.destroy_builtin_command_buffers(cg_ctx)

        // vkb.create_builtin_uniform_buffers(cg_ctx) or_return
        // defer if !ok do vkb.destroy_builtin_uniform_buffers(cg_ctx)

        // vkb.create_builtin_pipeline_layout(cg_ctx) or_return
        // defer if !ok do vkb.destroy_builtin_pipeline_layout(cg_ctx)

        // vkb.create_builtin_render_pass(cg_ctx) or_return
        // defer if !ok do vkb.destroy_builtin_render_pass(cg_ctx)

        vkb.create_sync_structures(cg_ctx) or_return
        defer if !ok do vkb.destroy_sync_structures(cg_ctx)

        cg_ctx.current_frame = u32(config.RENDERER_FRAMES_IN_FLIGHT - 1)

        return true
    }

    cvk_shutdown :: proc(cg_ctx: ^Graphics_Context) {
        vk.DeviceWaitIdle(cg_ctx.device)
        
        vkb.destroy_allocator(cg_ctx)
        vkb.destroy_sync_structures(cg_ctx)
        // vkb.destroy_framebuffers(cg_ctx, cg_ctx.render_pass_framebuffers)
        // vkb.destroy_builtin_pipeline_layout(cg_ctx)
        // vkb.destroy_builtin_uniform_buffers(cg_ctx)
        // vkb.destroy_builtin_render_pass(cg_ctx)
        vkb.destroy_builtin_command_buffers(cg_ctx)
        vkb.destroy_command_pools(cg_ctx)
        vkb.destroy_swapchain(cg_ctx)
        vkb.destroy_device(cg_ctx)
        vkb.destroy_surface(cg_ctx)
        vkb.destroy_instance(cg_ctx)

        vkb.destroy_graphics_context(cg_ctx)
    }

    cvk_wait_until_idle :: proc() {
        vk.DeviceWaitIdle(cg_ctx.device)
    }

    cvk_create_render_pass :: proc(render_pass_desc: ^Render_Pass_Description) -> (render_pass: Render_Pass, ok: bool) {
        cvk_rp := vkb.create_render_pass(cg_ctx, render_pass_desc) or_return
        // unimplemented()
        return vkb.as_render_pass(cvk_rp), true
    }

    cvk_destroy_render_pass :: proc(render_pass: Render_Pass) {
        vkb.destroy_render_pass(cg_ctx, vkb.as_cvk_render_pass(render_pass))
    }

    cvk_create_shader :: proc(shader_description: ^Shader_Description) -> (shader: Shader, ok: bool) { 
        cvk_shader: ^vkb.CVK_Shader
        cvk_shader, ok = vkb.create_graphics_pipeline(cg_ctx, shader_description)
        if !ok {
            log.error("Failed to create shader")
        }

        return vkb.as_shader(cvk_shader), ok
    }

    cvk_destroy_shader :: proc(shader: Shader) {
        cvk_shader := vkb.as_cvk_shader(shader)
        vkb.destroy_pipeline(cg_ctx, cvk_shader)
    }

    cvk_create_material_from_shader :: proc(shader: Shader) -> (material: Material, ok: bool) {
        unimplemented()
    }

    cvk_destroy_material :: proc(material: Material) {
        unimplemented()
    }

    cvk_create_static_mesh :: proc(mesh_asset: ^asset.Mesh) -> (mesh: Mesh, ok: bool) { 
        cvk_mesh := new(vkb.CVK_Mesh)
        defer if !ok do free(cvk_mesh)

        cvk_mesh.vert_groups = make([]vkb.CVK_Vertex_Group, len(mesh_asset.vertex_groups))
        defer if !ok do delete(cvk_mesh.vert_groups)

        cvk_mesh.buffer = vkb.create_buffer(cg_ctx, len(mesh_asset.buffer), {.INDEX_BUFFER, .VERTEX_BUFFER, .TRANSFER_DST}, .GPU_ONLY) or_return
        vkb.upload_buffer_data(cg_ctx, &cvk_mesh.buffer, mesh_asset.buffer) or_return
        
        // Sub-allocate buffer and populate attribute descriptions
        for &asset_vg, i in mesh_asset.vertex_groups {
            vg := &cvk_mesh.vert_groups[i]
            
            vg.vertex_count             = asset_vg.vertex_count
            vg.mesh_buffer              = cvk_mesh.buffer.buffer
            vg.idx_buffer_offset        = vk.DeviceSize(asset_vg.index_offset)
            vg.vertex_buffers           = make([]vk.Buffer, asset_vg.total_channel_count)
            vg.vertex_buffer_offsets    = make([]vk.DeviceSize, asset_vg.total_channel_count)
            vg.vertex_input_bindings    = make([]vk.VertexInputBindingDescription, asset_vg.total_channel_count)
            vg.vertex_input_attributes  = make([]vk.VertexInputAttributeDescription, asset_vg.total_channel_count)

            vkb.populate_binding_attribute_descriptions(&asset_vg, vg)
        }

        mesh = vkb.as_mesh(cvk_mesh)
        return mesh, true
    }

    cvk_destroy_static_mesh :: proc(mesh: Mesh) {
        cvk_mesh := vkb.as_cvk_mesh(mesh)
        for vg in cvk_mesh.vert_groups {
            delete(vg.vertex_buffers)
            delete(vg.vertex_buffer_offsets)
            delete(vg.vertex_input_bindings)
            delete(vg.vertex_input_attributes)
        }

        delete(cvk_mesh.vert_groups)
        vkb.destroy_buffer(cg_ctx, &cvk_mesh.buffer)
        free(cvk_mesh)
    }

    cvk_create_texture :: proc(texture_asset: ^asset.Texture) -> (texture: ^Texture, ok: bool) { 
        unimplemented("Create Texture")
    }

    cvk_destroy_texture :: proc(texture: Texture) {
        unimplemented()
    }

    cvk_set_clear_color :: proc(color: [4]f32) {
        cg_ctx.clear_color = color
    }

    cvk_upload_uniforms_render_pass :: proc(render_pass: Render_Pass, uniforms: ^cc.Render_Pass_Uniforms) {
        cvk_rp := vkb.as_cvk_render_pass(render_pass)

        data := mem.byte_slice(uniforms, size_of(cc.Render_Pass_Uniforms))
        vkb.upload_buffer_data_no_staging(cg_ctx, &cvk_rp.uniform_buffer, data) // TODO(srp): with buffer offset
    }


    // ==============================================================================

    cvk_cmd_begin_graphics :: proc() {
        cg_ctx.current_frame = (cg_ctx.current_frame + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
       
        frame, _ := vkb.current_frame_data(cg_ctx)

        vk.WaitForFences(cg_ctx.device, 1, &frame.in_flight_fence, true, max(u64))
        vk.ResetFences(cg_ctx.device, 1, &frame.in_flight_fence)

        vk.AcquireNextImageKHR(cg_ctx.device, cg_ctx.swapchain, max(u64), frame.image_available_sem, {}, &frame.swapchain_image_index)

        vk.ResetCommandBuffer(frame.graphics_command_buffer, {})

        begin_info := vk.CommandBufferBeginInfo {
            sType = .COMMAND_BUFFER_BEGIN_INFO,
            
        }

        vk.BeginCommandBuffer(frame.graphics_command_buffer, &begin_info)
    }

    cvk_cmd_end_graphics  :: proc() {
        frame, _ := vkb.current_frame_data(cg_ctx)
        graphics_buffer := frame.graphics_command_buffer
        vk.EndCommandBuffer(graphics_buffer)
    }


    cvk_cmd_submit_graphics :: proc() {
        // TODO(headless): Noop this command
        frame, _ := vkb.current_frame_data(cg_ctx)

        wait_semaphores := []vk.Semaphore { 
            frame.image_available_sem,
        }

        wait_stages := vk.PipelineStageFlags {.COLOR_ATTACHMENT_OUTPUT}

        signal_semaphores := []vk.Semaphore {
            frame.present_ready_sem,
        }

        submit_info := vk.SubmitInfo {
            sType                   = .SUBMIT_INFO,
            waitSemaphoreCount      = u32(len(wait_semaphores)),
            pWaitSemaphores         = raw_data(wait_semaphores),
            pWaitDstStageMask       = &wait_stages,
            commandBufferCount      = 1,
            pCommandBuffers         = &frame.graphics_command_buffer,
            signalSemaphoreCount    = u32(len(signal_semaphores)),
            pSignalSemaphores       = raw_data(signal_semaphores),
        }

        res := vk.QueueSubmit(cg_ctx.graphics_queue, 1, &submit_info, frame.in_flight_fence)
        vkb.check_result(res)
    }
    
    cvk_cmd_begin_transfer :: proc() {
        unimplemented()
    }
    cvk_cmd_end_transfer :: proc() {
        unimplemented()
    }
    cvk_cmd_submit_transfer :: proc() {
        unimplemented()
    }
    
    cvk_cmd_begin_compute :: proc() {
        unimplemented()
    }
    cvk_cmd_end_compute :: proc() {
        unimplemented()
    }
    cvk_cmd_submit_compute :: proc() {
        unimplemented()
    }

    cvk_cmd_begin_render_pass :: proc(render_pass: Render_Pass) {
        frame, frame_idx    := vkb.current_frame_data(cg_ctx)
        graphics_buffer     := frame.graphics_command_buffer
        cvk_rp              := vkb.as_cvk_render_pass(render_pass)

        // framebuffer := cg_ctx.render_pass_framebuffers[vkb.current_frame_data(cg_ctx).swapchain_image_index]

        clear_values := []vk.ClearValue {
            {color          = {float32 = cg_ctx.clear_color}},
            {depthStencil   = {depth = 1}},
        }

        begin_info := vk.RenderPassBeginInfo {
            sType           = .RENDER_PASS_BEGIN_INFO,
            renderPass      = cvk_rp.render_pass,
            framebuffer     = vkb.render_pass_get_framebuffer(cg_ctx, cvk_rp),
            clearValueCount = u32(len(clear_values)),
            pClearValues    = raw_data(clear_values),
            renderArea      = vk.Rect2D{
                offset      = {0, 0},
                extent      = cg_ctx.swapchain_render_target.extent,
            },
        }
        vk.CmdBeginRenderPass(graphics_buffer, &begin_info, .INLINE)
    }

    cvk_cmd_end_render_pass :: proc() {
        frame, _ := vkb.current_frame_data(cg_ctx)
        vk.CmdEndRenderPass(frame.graphics_command_buffer)
    }

    cvk_cmd_bind_shader :: proc(shader: Shader) {
        frame, _ := vkb.current_frame_data(cg_ctx)
        cvk_shader := vkb.as_cvk_shader(shader)
        vk.CmdBindPipeline(frame.graphics_command_buffer, .GRAPHICS, cvk_shader.pipeline)
    }

    cvk_cmd_bind_uniforms_scene :: proc(/*scene: Scene*/) {
        unimplemented()
    }

    cvk_cmd_bind_uniforms_render_pass :: proc(render_pass: Render_Pass) {
        // Get camera uniform buffer for current frame, ideally from the render_pass struct
        cvk_rp := vkb.as_cvk_render_pass(render_pass)
        frame, frame_idx := vkb.current_frame_data(cg_ctx)

        ubo_offsets := []u32 {
            u32(vkb.ubo_size_padded(cg_ctx, type_info_of(cvk_rp.ubo_type).size)),
        }

        vk.CmdBindDescriptorSets(frame.graphics_command_buffer, .GRAPHICS, cvk_rp.pipeline_layout, 0, 1, &cvk_rp.uniform_set, u32(len(ubo_offsets)), raw_data(ubo_offsets)) // TODO(srp): dynamic offsets
    }

    cvk_cmd_bind_uniforms_material :: proc(material: Material) {
        unimplemented()
    }

    cvk_cmd_bind_uniforms_instance :: proc() {
        unimplemented()
        // graphics_buffer := vkb.current_frame_data(cg_ctx).graphics_command_buffer
        // vk.CmdBindDescriptorSets(graphics_buffer, .GRAPHICS, )
    }

    // Draws all vertex groups in a mesh using the currently bound shader.
    cvk_cmd_draw_mesh :: proc(mesh: Mesh) {
        frame, _ := vkb.current_frame_data(cg_ctx)
        cvk_mesh := vkb.as_cvk_mesh(mesh)

        for &vert_group in cvk_mesh.vert_groups {
            vk.CmdBindIndexBuffer(frame.graphics_command_buffer, vert_group.vertex_buffers[0], vert_group.idx_buffer_offset, .UINT32)
            vk.CmdBindVertexBuffers(frame.graphics_command_buffer, 0, u32(len(vert_group.vertex_input_bindings)), raw_data(vert_group.vertex_buffers), raw_data(vert_group.vertex_buffer_offsets))
            vk.CmdDraw(frame.graphics_command_buffer, vert_group.vertex_count, 1, 0, 0)
        }
    }

    // Each vertex group is queued to be drawn when its corresponding material/shader is bound.
    cvk_cmd_draw_model :: proc(model: Model) {
        unimplemented()
    }

    // Warning: this procedure will change GPU state frequently. 
    // Prefer `cmd_draw_model` to draw vertex groups with shared materials/shaders without unnecessary binds.
    cvk_cmd_draw_model_immediate :: proc(model: Model) {
        frame, _ := vkb.current_frame_data(cg_ctx)
        vk.CmdDraw(frame.graphics_command_buffer, 3, 1, 0, 0) // TEMP
    }


    cvk_cmd_present :: proc() {
        frame, _ := vkb.current_frame_data(cg_ctx)

        // TODO(headless): Noop this command
        wait_semaphores := []vk.Semaphore {
            frame.present_ready_sem,
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
            pImageIndices       = &frame.swapchain_image_index,
        }

        vk.QueuePresentKHR(cg_ctx.graphics_queue, &present_info)

    }


    // ==============================================================================

    // ==============================================================================
    @(init)
    _load_cvk_procs :: proc() {
        bind_context                = cvk_bind_context                   
        init                        = cvk_init
        shutdown                    = cvk_shutdown
        wait_until_idle             = cvk_wait_until_idle
        create_render_pass          = cvk_create_render_pass
        destroy_render_pass         = cvk_destroy_render_pass
        create_shader               = cvk_create_shader
        destroy_shader              = cvk_destroy_shader
        create_material_from_shader = cvk_create_material_from_shader
        destroy_material            = cvk_destroy_material
        create_static_mesh          = cvk_create_static_mesh
        destroy_static_mesh         = cvk_destroy_static_mesh
        create_texture              = cvk_create_texture
        destroy_texture             = cvk_destroy_texture
        set_clear_color             = cvk_set_clear_color

        upload_uniforms_render_pass = cvk_upload_uniforms_render_pass
                                     
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
                                                                   
        cmd_bind_uniforms_scene         = cvk_cmd_bind_uniforms_scene
        cmd_bind_uniforms_render_pass   = cvk_cmd_bind_uniforms_render_pass
        cmd_bind_uniforms_material      = cvk_cmd_bind_uniforms_material
        cmd_bind_uniforms_instance      = cvk_cmd_bind_uniforms_instance
                                                                   
        cmd_draw_mesh               = cvk_cmd_draw_mesh
        cmd_draw_model              = cvk_cmd_draw_model
        cmd_draw_model_immediate    = cvk_cmd_draw_model_immediate
        cmd_present                 = cvk_cmd_present
    }
}
