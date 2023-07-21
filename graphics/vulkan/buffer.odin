package callisto_graphics_vulkan

import "core:log"
import "core:mem"
import "../common"
import vk "vendor:vulkan"

create_vertex_buffer :: proc(vertices: []$T, buffer: ^common.Vertex_Buffer) -> (ok: bool) {
    using bound_state
    
    buf_len := u64(len(vertices))
    buf_size := u64(buf_len * size_of(T))

    // cvk_buffer, err := mem.new(CVK_Buffer); if err != nil {
    //     log.error("Failed to create buffer:", err)
    //     return false
    // }
    // defer if !ok do mem.free(cvk_buffer)

    staging_buffer, err1 := new(CVK_Buffer); if err1 != .None {
        log.error("Failed to create buffer:", err1)
        return false
    }
    defer _destroy_buffer(staging_buffer)
    staging_buffer.size = buf_size
    staging_buffer.length = buf_len
    staging_buffer_properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    _create_buffer(staging_buffer.size, {.TRANSFER_SRC}, staging_buffer_properties, &staging_buffer.buffer, &staging_buffer.memory) or_return

    // Copy data to staging buffer
    vk_data: rawptr
    vk.MapMemory(device, staging_buffer.memory, 0, vk.DeviceSize(staging_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(vertices), int(staging_buffer.size))
    vk.UnmapMemory(device, staging_buffer.memory)
    
    local_buffer, err2 := new(CVK_Buffer); if err2 != .None {
        log.error("Failed to create buffer:", err2)
        return false
    }
    defer if !ok do _destroy_buffer(local_buffer)
    local_buffer.size = buf_size
    local_buffer.length = buf_len
    properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    _create_buffer(local_buffer.size, {.TRANSFER_DST, .VERTEX_BUFFER}, properties, &local_buffer.buffer, &local_buffer.memory) or_return

    _copy_buffer(staging_buffer, local_buffer) or_return
    buffer^ = transmute(common.Vertex_Buffer)local_buffer
    return true
}

destroy_vertex_buffer :: proc(buffer: common.Vertex_Buffer) {
    _destroy_buffer(transmute(^CVK_Buffer)buffer)
}


_create_buffer :: proc(size: u64, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags, buffer: ^vk.Buffer, memory: ^vk.DeviceMemory) -> (ok: bool) {
    using bound_state

    buffer_create_info: vk.BufferCreateInfo = {
        sType = .BUFFER_CREATE_INFO,
        size = vk.DeviceSize(size),
        usage = usage,
        sharingMode = .EXCLUSIVE,
    }
    
    res := vk.CreateBuffer(device, &buffer_create_info, nil, buffer); if res != .SUCCESS {
        log.error("Failed to create buffer:", res)
        return false
    }
    defer if !ok do vk.DestroyBuffer(device, buffer^, nil)

    requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(device, buffer^, &requirements)

    memory_alloc_info: vk.MemoryAllocateInfo = {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = requirements.size,
        memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, properties),
    }
    
    res = vk.AllocateMemory(device, &memory_alloc_info, nil, memory); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(device, memory^, nil)
    vk.BindBufferMemory(device, buffer^, memory^, 0)

    return true
}

_destroy_buffer :: proc(buffer: ^CVK_Buffer) {
    using bound_state
    vk.DeviceWaitIdle(device)
    vk.DestroyBuffer(device, buffer.buffer, nil)
    vk.FreeMemory(device, vk.DeviceMemory(buffer.memory), nil)
    // mem.free_with_size(buffer, size_of(CVK_Buffer))
    mem.free(buffer)
}

_copy_buffer :: proc(src_buffer, dst_buffer: ^CVK_Buffer) -> (ok: bool) {
    using bound_state
    allocate_info: vk.CommandBufferAllocateInfo = {
        sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        level = .PRIMARY,
        commandPool = command_pool,
        commandBufferCount = 1,
    }
    command_buffer: vk.CommandBuffer
    res := vk.AllocateCommandBuffers(device, &allocate_info, &command_buffer); if res != .SUCCESS {
        log.error("Failed to copy buffer:", res)
        return false
    }
    defer vk.FreeCommandBuffers(device, command_pool, 1, &command_buffer)

    begin_info: vk.CommandBufferBeginInfo = {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {.ONE_TIME_SUBMIT},
    }
    vk.BeginCommandBuffer(command_buffer, &begin_info)

    copy_region: vk.BufferCopy = {
        size = vk.DeviceSize(src_buffer.size),
    }
    vk.CmdCopyBuffer(command_buffer, src_buffer.buffer, dst_buffer.buffer, 1, &copy_region)
    
    vk.EndCommandBuffer(command_buffer)

    submit_info: vk.SubmitInfo = {
        sType = .SUBMIT_INFO,
        commandBufferCount = 1,
        pCommandBuffers = &command_buffer,
    }
    vk.QueueSubmit(queues.graphics, 1, &submit_info, {})
    vk.QueueWaitIdle(queues.graphics)
    return true
}