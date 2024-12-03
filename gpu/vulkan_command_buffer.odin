#+private

package callisto_gpu
// import dd "vendor:vulkan"

import vk "vulkan"

_vk_command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result) {
        cb.type = init_info.type

        family : u32
        switch init_info.type {
        case .Graphics, .Compute_Sync: 
                family = d.family_graphics
        case .Compute_Async:
                family = d.family_async_compute
        }
        
        pool_info := vk.CommandPoolCreateInfo {
                sType            = .COMMAND_POOL_CREATE_INFO,
                flags            = {}, // Might need .RESET here but probably not, just reset the pool
                queueFamilyIndex = family,
        }

        vkres: vk.Result

        // Pools
        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.front_pool)
        check_result(vkres) or_return
        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.idle_pool)
        check_result(vkres) or_return
        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.recording_pool)
        check_result(vkres) or_return

     
        temp_buffers : [2]vk.CommandBuffer

        // front
        buffer_info := vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.front_pool,
                commandBufferCount = 2,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, raw_data(&temp_buffers))
        check_result(vkres) or_return
        cb.front_buffer          = temp_buffers[0]
        cb.front_transfer_buffer = temp_buffers[1]

        // idle
        buffer_info = vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.idle_pool,
                commandBufferCount = 2,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, raw_data(&temp_buffers))
        check_result(vkres) or_return
        cb.idle_buffer          = temp_buffers[0]
        cb.idle_transfer_buffer = temp_buffers[1]

        // recording
        buffer_info = vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.recording_pool,
                commandBufferCount = 2,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, raw_data(&temp_buffers))
        check_result(vkres) or_return
        cb.recording_buffer          = temp_buffers[0]
        cb.recording_transfer_buffer = temp_buffers[1]
        
        return .Ok
}


_vk_command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        d.DestroyCommandPool(d.device, cb.front_pool, nil)
        d.DestroyCommandPool(d.device, cb.idle_pool, nil)
        d.DestroyCommandPool(d.device, cb.recording_pool, nil)
}


_vk_command_buffer_swap_finished_reading :: proc(d: ^Device, cb: ^Command_Buffer) {
        // if `idle` is fresh, swap `front` and `idle`.
        // `idle` is now invalid and must be recorded again.
}

_vk_command_buffer_swap_finished_recording :: proc(d: ^Device, cb: ^Command_Buffer) {
        // swap `idle` and `recording`.
        // `idle` is now fresh and can be presented.
        // reset the `recording` pool.
}
