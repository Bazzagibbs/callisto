#+private

package callisto_gpu
// import dd "vendor:vulkan"

import vk "vulkan"

_vk_command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result) {
        cb.type = init_info.type

        family : u32
        switch cb.type {
        case .Graphics, .Compute_Sync: 
                family = d.graphics_family
        case .Compute_Async:
                family = d.async_compute_family
        }
        
        pool_info := vk.CommandPoolCreateInfo {
                sType            = .COMMAND_POOL_CREATE_INFO,
                flags            = {}, // Might need .RESET here but probably not, just reset the pool
                queueFamilyIndex = family,
        }

        vkres: vk.Result

        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.pool)
        check_result(vkres) or_return
   

        buffer_info := vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.pool,
                commandBufferCount = 1,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, &cb.buffer)
        check_result(vkres) or_return

        
        return .Ok
}


_vk_command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        d.DestroyCommandPool(d.device, cb.pool, nil)
}

_vk_command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> Result {
        unimplemented()
}

_vk_command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> Result {
        unimplemented()
}
