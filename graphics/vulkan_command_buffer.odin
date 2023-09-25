//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:log"
import vk "vendor:vulkan"

_begin_one_shot_commands :: proc(temp_command_buffer: ^vk.CommandBuffer) -> (ok: bool) {
    command_buffer_alloc_info := vk.CommandBufferAllocateInfo {
        sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        level = .PRIMARY,
        commandPool = bound_state.command_pool,
        commandBufferCount = 1,
    }

    res := vk.AllocateCommandBuffers(bound_state.device, &command_buffer_alloc_info, temp_command_buffer); if res != .SUCCESS {
        log.error("Failed to allocate one-shot command buffer:", res)
        return false
    }
    defer if !ok do vk.FreeCommandBuffers(bound_state.device, bound_state.command_pool, 1, temp_command_buffer)

    begin_info := vk.CommandBufferBeginInfo {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {.ONE_TIME_SUBMIT},
    }
    res = vk.BeginCommandBuffer(temp_command_buffer^, &begin_info); if res != .SUCCESS {
        log.error("Failed to begin one-shot command buffer:", res)
        return false
    }

    return true
}

_end_one_shot_commands :: proc(temp_command_buffer: vk.CommandBuffer) -> (ok: bool) {
    temp_command_buffer := temp_command_buffer
    defer vk.FreeCommandBuffers(bound_state.device, bound_state.command_pool, 1, &temp_command_buffer)
    
    res := vk.EndCommandBuffer(temp_command_buffer); if res != .SUCCESS {
        log.error("Failed to end one-shot command buffer:", res)
        return false
    }

    submit_info := vk.SubmitInfo {
        sType = .SUBMIT_INFO,
        commandBufferCount = 1,
        pCommandBuffers = &temp_command_buffer,
    }
   
    res = vk.QueueSubmit(bound_state.queues.graphics, 1, &submit_info, {}); if res != .SUCCESS {
        log.error("Failed to submit one-shot command buffer")
        return false
    }

    vk.QueueWaitIdle(bound_state.queues.graphics)

    return true
}