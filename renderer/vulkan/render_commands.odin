package callisto_renderer_vulkan

import "core:log"
import vk "vendor:vulkan"
import cg "../../graphics"
import "../../config"

cmd_record :: proc() {
    using bound_state
    begin_command_buffer()
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
}

cmd_begin_render_pass :: proc() {
    begin_render_pass()
}

cmd_end_render_pass :: proc() {
    end_render_pass()
}


cmd_bind_shader :: proc(shader: ^cg.Shader) {
    using bound_state
    vk.CmdBindPipeline(command_buffers[flight_frame], .GRAPHICS, vk.Pipeline(shader.handle))
}

cmd_bind_buffer :: proc(buffer: ^cg.Vertex_Buffer) {
    using bound_state
    buffers := [?]vk.Buffer {vk.Buffer(buffer.handle)}
    offsets := [?]vk.DeviceSize {0}
    vk.CmdBindVertexBuffers(command_buffers[flight_frame], 0, 1, &buffers[0], &offsets[0])
}

cmd_present :: proc() {
    using bound_state
    end_command_buffer()
    submit_command_buffer()
    present()

    flight_frame = (flight_frame + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
}