package callisto_graphics_vkb

import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"
import "core:log"
import "core:mem"

Gpu_Buffer :: struct {
    size:           vk.DeviceSize,
    buffer:         vk.Buffer,
    allocation:     vma.Allocation,
}


create_buffer :: proc(cg_ctx: ^Graphics_Context, size: int, buffer_usage: vk.BufferUsageFlags, mem_usage: vma.MemoryUsage) -> (buffer: Gpu_Buffer, ok: bool) {
    buffer.size = vk.DeviceSize(size)

    buffer_info := vk.BufferCreateInfo {
        sType       = .BUFFER_CREATE_INFO,
        size        = buffer.size,
        usage       = buffer_usage,
        sharingMode = .EXCLUSIVE,
    }

    alloc_info := vma.AllocationCreateInfo {
        usage           = mem_usage,
    }

    res := vma.CreateBuffer(cg_ctx.allocator, &buffer_info, &alloc_info, &buffer.buffer, &buffer.allocation, nil)
    check_result(res) or_return
    defer if !ok do vma.DestroyBuffer(cg_ctx.allocator, buffer.buffer, buffer.allocation)

    return buffer, true
}


create_staging_buffer :: proc(cg_ctx: ^Graphics_Context, size: int) -> (buffer: Gpu_Buffer, ok: bool) {
    buffer_info := vk.BufferCreateInfo {
        sType       = .BUFFER_CREATE_INFO,
        size        = vk.DeviceSize(size),
        usage       = {.TRANSFER_SRC},
        // sharingMode = .EXCLUSIVE,
    }

    alloc_info := vma.AllocationCreateInfo {
        usage = .AUTO,
        flags = {.HOST_ACCESS_SEQUENTIAL_WRITE},
    }

   
    alloc_res: vma.AllocationInfo
    res := vma.CreateBuffer(cg_ctx.allocator, &buffer_info, &alloc_info, &buffer.buffer, &buffer.allocation, &alloc_res)
    check_result(res) or_return
    defer if !ok do vma.DestroyBuffer(cg_ctx.allocator, buffer.buffer, buffer.allocation)

    return buffer, true
}


destroy_buffer :: proc(cg_ctx: ^Graphics_Context, buffer: ^Gpu_Buffer) {
    vma.DestroyBuffer(cg_ctx.allocator, buffer.buffer, buffer.allocation)
}


upload_buffer_data :: proc(cg_ctx: ^Graphics_Context, buffer: ^Gpu_Buffer, data: []byte) -> (ok: bool) {
    staging_buffer := create_staging_buffer(cg_ctx, len(data)) or_return
    defer destroy_buffer(cg_ctx, &staging_buffer)

    upload_buffer_data_no_staging(cg_ctx, &staging_buffer, data) or_return

    buffer_copy(cg_ctx, staging_buffer.buffer, buffer.buffer, vk.DeviceSize(len(data)))

    return true
}

upload_buffer_data_no_staging :: proc(cg_ctx: ^Graphics_Context, buffer: ^Gpu_Buffer, data: []byte) -> (ok: bool) {
    data_size := len(data)

    mapped_mem: rawptr
    res := vma.MapMemory(cg_ctx.allocator, buffer.allocation, &mapped_mem)
    check_result(res) or_return
    mem.copy(raw_data(data), mapped_mem, data_size)
    vma.UnmapMemory(cg_ctx.allocator, buffer.allocation)

    return true
}

// ///////////////////////////////////////////////////////////////////////////

buffer_copy :: proc(cg_ctx: ^Graphics_Context, src_buffer, dst_buffer: vk.Buffer, size: vk.DeviceSize) {
    alloc_info := vk.CommandBufferAllocateInfo {
        sType               = .COMMAND_BUFFER_ALLOCATE_INFO,
        level               = .PRIMARY,
        commandPool         = cg_ctx.transfer_pool,
        commandBufferCount  = 1,
    }

    cmd_buffer: vk.CommandBuffer
    vk.AllocateCommandBuffers(cg_ctx.device, &alloc_info, &cmd_buffer)

    begin_info := vk.CommandBufferBeginInfo {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {.ONE_TIME_SUBMIT},
    }
    
    vk.BeginCommandBuffer(cmd_buffer, &begin_info)

    copy_region := vk.BufferCopy {
        size = size,
    }
    vk.CmdCopyBuffer(cmd_buffer, src_buffer, dst_buffer, 1, &copy_region)

    vk.EndCommandBuffer(cmd_buffer)

    submit_info := vk.SubmitInfo {
        sType = .SUBMIT_INFO,
        commandBufferCount = 1,
        pCommandBuffers = &cmd_buffer,
    }
    vk.QueueSubmit(cg_ctx.transfer_queue, 1, &submit_info, {})
    vk.QueueWaitIdle(cg_ctx.transfer_queue)
    vk.FreeCommandBuffers(cg_ctx.device, cg_ctx.transfer_pool, 1, &cmd_buffer)
}

