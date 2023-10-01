//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:log"
import vk "vendor:vulkan"
import "../config"

_impl_cmd_record :: proc() {
    using bound_state
    vk.WaitForFences(device, 1, &in_flight_fences[flight_frame], true, max(u64))

    target_image_index = 0
    res := vk.AcquireNextImageKHR(device, swapchain, max(u64), image_available_semaphores[flight_frame], {}, &target_image_index); if res != .SUCCESS {
        switch {
            case res == .ERROR_OUT_OF_DATE_KHR:
                fallthrough
            case res == .SUBOPTIMAL_KHR:
                log.info("Image out of date, recreating swapchain...")
                ok := _recreate_swapchain(&swapchain, &swapchain_details, &image_views, &framebuffers); if !ok {
                    log.fatal("Failed to recreate swapchain")
                }
            return
        }
    }
    
    vk.ResetFences(device, 1, &in_flight_fences[flight_frame])
    vk.ResetCommandBuffer(command_buffers[flight_frame], {})
    _begin_command_buffer()
}

_impl_cmd_begin_render_pass :: #force_inline proc() {
    _begin_render_pass()
}

_impl_cmd_end_render_pass :: #force_inline proc() {
    _end_render_pass()
}


// _impl_cmd_bind_shader :: proc(shader: Shader) {
//     using bound_state
//     cvk_shader := transmute(^CVK_Shader)shader
//     vk.CmdBindPipeline(command_buffers[flight_frame], .GRAPHICS, cvk_shader.pipeline)
// }

_impl_cmd_bind_material_instance :: proc(material_instance: Material_Instance) {
    using bound_state
    cvk_material_instance := transmute(^CVK_Material_Instance)material_instance
    shader := cvk_material_instance.shader
    command_buffer := command_buffers[flight_frame]
    descriptor_set := cvk_material_instance.descriptor_sets[flight_frame]

    vk.CmdBindPipeline(command_buffer, .GRAPHICS, shader.pipeline)
    vk.CmdBindDescriptorSets(command_buffer, .GRAPHICS, shader.pipeline_layout, 0, 1, &descriptor_set, 0, nil)
}

_impl_cmd_draw :: proc(mesh: Mesh) {
    cvk_mesh := transmute(^CVK_Mesh)mesh
        
    // Individual draw for each primitive for now
    // TODO: batched rendering
    for _, i in cvk_mesh.vertex_groups {
        _impl_cmd_draw_vert_group(&cvk_mesh.vertex_groups[i])
    }
}

_impl_cmd_draw_vert_group :: proc(vert_group: ^CVK_Vertex_Group) {
    command_buffer := bound_state.command_buffers[bound_state.flight_frame]

    vert_buffers := []vk.Buffer { 
        vert_group.position.buffer,
        vert_group.normal.buffer,
        vert_group.tangent.buffer,
        vert_group.uv_0.buffer,
    }
    // offsets := []vk.DeviceSize { 0, 0, 0 }
    offsets := []vk.DeviceSize { 0, 0, 0, 0 }

    vk.CmdBindIndexBuffer(command_buffer, vert_group.index.buffer, 0, .UINT32)
    vk.CmdBindVertexBuffers(command_buffer, 0, u32(len(vert_buffers)), raw_data(vert_buffers), raw_data(offsets))
    vk.CmdDrawIndexed(command_buffer, u32(vert_group.index.length), 1, 0, 0, 0)
}

_impl_cmd_present :: proc() {
    using bound_state
    _end_command_buffer()
    _submit_command_buffer()
    _present()

    flight_frame = (flight_frame + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
}
