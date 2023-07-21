package callisto_graphics_vulkan

import "core:log"
import vk "vendor:vulkan"
import "../../config"
import "../common"

cmd_record :: proc() {
    using bound_state
    vk.WaitForFences(device, 1, &in_flight_fences[flight_frame], true, max(u64))

    target_image_index = 0
    res := vk.AcquireNextImageKHR(device, swapchain, max(u64), image_available_semaphores[flight_frame], {}, &target_image_index); if res != .SUCCESS {
        switch {
            case res == .ERROR_OUT_OF_DATE_KHR:
                fallthrough
            case res == .SUBOPTIMAL_KHR:
                log.info("Image out of date, recreating swapchain...")
                ok := recreate_swapchain(&swapchain, &swapchain_details, &image_views, &framebuffers); if !ok {
                    log.fatal("Failed to recreate swapchain")
                }
            return
        }
    }
    
    vk.ResetFences(device, 1, &in_flight_fences[flight_frame])
    vk.ResetCommandBuffer(command_buffers[flight_frame], {})
    begin_command_buffer()
}

cmd_begin_render_pass :: proc() {
    begin_render_pass()
}

cmd_end_render_pass :: proc() {
    end_render_pass()
}


cmd_bind_shader :: proc(shader: common.Shader) {
    using bound_state
    cvk_shader := transmute(^CVK_Shader)shader
    vk.CmdBindPipeline(command_buffers[flight_frame], .GRAPHICS, cvk_shader.pipeline)
}

cmd_draw :: proc(mesh: common.Mesh) {
    using bound_state
    cvk_mesh := transmute(^CVK_Mesh)mesh
    cvk_vert_buffer := transmute(^CVK_Buffer)cvk_mesh.vertex_buffer
    cvk_index_buffer := transmute(^CVK_Buffer)cvk_mesh.index_buffer

    command_buffer := command_buffers[flight_frame]

    vert_buffers := []vk.Buffer {cvk_vert_buffer.buffer}
    offsets := []vk.DeviceSize {0}
    vk.CmdBindVertexBuffers(command_buffer, 0, 1, raw_data(vert_buffers), raw_data(offsets))
    vk.CmdBindIndexBuffer(command_buffer, cvk_index_buffer.buffer, 0, .UINT32) // TODO: get index size dynamically
    vk.CmdDrawIndexed(command_buffer, u32(cvk_index_buffer.length), 1, 0, 0, 0)
}

cmd_present :: proc() {
    using bound_state
    end_command_buffer()
    submit_command_buffer()
    present()

    flight_frame = (flight_frame + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
}