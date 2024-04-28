//+private
package callisto_graphics

import vk "vendor:vulkan"
import "../config"
import "../common"
import backend "backend_vk"

when config.RENDERER_API == .Vulkan {

    _check_result :: backend.check_result
   

    _renderer_create :: proc(description: ^Engine_Description, window: Window) -> (r: Renderer, res: Result) {
        r_vk := new(backend.Renderer_Impl)
        r = to_handle(r_vk)

        defer if res != .Ok do _renderer_destroy(r)

        backend.instance_create(r_vk, description) or_return
        backend.surface_create(r_vk, window) or_return
        backend.physical_device_select(r_vk) or_return
        backend.device_create(r_vk, description) or_return
        backend.allocator_create(r_vk) or_return
        backend.swapchain_create(r_vk, description) or_return
        backend.command_structures_create(r_vk) or_return
        backend.sync_structures_create(r_vk) or_return

        return r, .Ok
    }

    _renderer_destroy :: proc(r: Renderer) {
        r_vk := from_handle(r)

        backend.device_wait_idle(r_vk)

        backend.sync_structures_destroy(r_vk)
        backend.command_structures_destroy(r_vk)
        backend.swapchain_destroy(r_vk)
        backend.allocator_destroy(r_vk)
        backend.device_destroy(r_vk)
        backend.surface_destroy(r_vk)
        backend.instance_destroy(r_vk)

        free(r_vk)
    }

    _gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Description) -> (gpu_image: Gpu_Image, res: Result) {
        unimplemented()
    }

    _gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
        unimplemented()
    }

    _gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Description) -> (gpu_buffer: Gpu_Buffer, res: Result) {
        unimplemented()
    }

    _gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Description) -> (res: Result) {
        unimplemented()
    }

    _gpu_buffer_destroy :: proc(r: Renderer, gpu_buffer: Gpu_Buffer) {
        unimplemented()
    }

    _gpu_shader_create :: proc(r: Renderer, description: ^Gpu_Shader_Description) -> (gpu_shader: Gpu_Shader, res: Result) {
        unimplemented()
    }

    _gpu_shader_destroy :: proc(r: Renderer, gpu_shader: Gpu_Shader) {
        unimplemented()
    }


    _cmd_graphics_begin :: proc(r: Renderer) {
        r_vk := from_handle(r)
        vk_res: vk.Result
        vk_res = vk.WaitForFences(r_vk.device, 1, &backend.current_frame(r_vk).fence_render, true, 1_000_000_000)
        _check_result(vk_res)
        vk_res = vk.ResetFences(r_vk.device, 1, &backend.current_frame(r_vk).fence_render)
        _check_result(vk_res)

        swapchain_image_idx: u32
        vk_res = vk.AcquireNextImageKHR(r_vk.device, r_vk.swapchain_data.swapchain, 1_000_000_000, backend.current_frame(r_vk).sem_swapchain, {}, &swapchain_image_idx)
        _check_result(vk_res)
        r_vk.swapchain_data.image_idx = swapchain_image_idx

        cmd := backend.current_frame(r_vk).command_buffers.graphics
        vk_res = vk.ResetCommandBuffer(cmd, {})
        _check_result(vk_res)

        begin_info := vk.CommandBufferBeginInfo {
            sType = .COMMAND_BUFFER_BEGIN_INFO,
            flags = {.ONE_TIME_SUBMIT},
        }
        vk_res = vk.BeginCommandBuffer(cmd, &begin_info)
        _check_result(vk_res)

        backend.cmd_gpu_image_transition(cmd, r_vk.swapchain_data.draw_target, .GENERAL, false)
        backend.cmd_gpu_image_transition(cmd, backend.swapchain_current_image(r_vk), .TRANSFER_DST_OPTIMAL, false)
    }


    _cmd_graphics_end :: proc(r: Renderer) {
        r_vk  := from_handle(r)

        frame := backend.current_frame(r_vk)
        cmd   := frame.command_buffers.graphics

        draw_target := r_vk.swapchain_data.draw_target
        swap_target := backend.swapchain_current_image(r_vk)

        backend.cmd_gpu_image_transition(cmd, draw_target, .TRANSFER_SRC_OPTIMAL, true)
        backend.cmd_gpu_image_transfer(cmd, draw_target, swap_target, {draw_target.extent.width, draw_target.extent.height}, {swap_target.extent.width, swap_target.extent.height})
        backend.cmd_gpu_image_transition(cmd, swap_target, .PRESENT_SRC_KHR, true)

        vk.EndCommandBuffer(cmd)

        wait_sem_submit_infos := []vk.SemaphoreSubmitInfo {
            {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = frame.sem_swapchain,
                stageMask   = {.COLOR_ATTACHMENT_OUTPUT},
                deviceIndex = 0,
                value       = 1,
            },
        }
        
        signal_sem_submit_infos := []vk.SemaphoreSubmitInfo {
            {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = frame.sem_render,
                stageMask   = {.ALL_GRAPHICS},
                deviceIndex = 0,
                value       = 1,
            },
        }

        cmd_buffer_submit_infos := []vk.CommandBufferSubmitInfo {
            {
                sType         = .COMMAND_BUFFER_SUBMIT_INFO,
                commandBuffer = cmd,
                deviceMask    = {},
            },
        }

        submit_info := vk.SubmitInfo2 {
            sType                    = .SUBMIT_INFO_2,
            waitSemaphoreInfoCount   = u32(len(wait_sem_submit_infos)),
            pWaitSemaphoreInfos      = raw_data(wait_sem_submit_infos),
            signalSemaphoreInfoCount = u32(len(signal_sem_submit_infos)),
            pSignalSemaphoreInfos    = raw_data(signal_sem_submit_infos),
            commandBufferInfoCount   = u32(len(cmd_buffer_submit_infos)),
            pCommandBufferInfos      = raw_data(cmd_buffer_submit_infos),
        }

        vk.QueueSubmit2(r_vk.queues.graphics, 1, &submit_info, frame.fence_render)

    }
    
    _cmd_graphics_present :: proc(r: Renderer) { 
        r_vk := from_handle(r)

        present_info := vk.PresentInfoKHR {
            sType              = .PRESENT_INFO_KHR,
            swapchainCount     = 1,
            pSwapchains        = &r_vk.swapchain_data.swapchain,
            waitSemaphoreCount = 1,
            pWaitSemaphores    = &backend.current_frame(r_vk).sem_render,
            pImageIndices      = &r_vk.swapchain_data.image_idx,
        }

        vk_res: vk.Result
        vk_res = vk.QueuePresentKHR(r_vk.queues.graphics, &present_info)
        _check_result(vk_res)

        r_vk.frame_idx += 1
        r_vk.frame_idx %= backend.MAX_FRAMES_IN_FLIGHT
    }


    _cmd_graphics_clear :: proc(r: Renderer, color: common.vec4) {
        r_vk := from_handle(r)

        cmd := backend.current_frame(r_vk).command_buffers.graphics

        clear_val := vk.ClearColorValue {
            float32 = color,
        }
        
        subresource_range := vk.ImageSubresourceRange {
            aspectMask = {.COLOR},
            baseMipLevel = 0,
            baseArrayLayer = 0,
            levelCount = 1,
            layerCount = 1,
        }

        vk.CmdClearColorImage(cmd, r_vk.swapchain_data.draw_target.image, .GENERAL, &clear_val, 1, &subresource_range)
    }

    _cmd_graphics_image_transfer :: proc(r: Renderer, src, dst: Gpu_Image, src_extent, dst_extent: common.uvec2) {
        r_vk     := from_handle(r)
        src_vk   := from_handle(src)
        dst_vk   := from_handle(dst)

        cmd := backend.current_frame(r_vk).command_buffers.graphics

        backend.cmd_gpu_image_transfer(cmd, src_vk, dst_vk, src_extent, dst_extent)
    }

}
