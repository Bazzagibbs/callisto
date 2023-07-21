package callisto_graphics_vulkan

import "core:log"
import "core:mem"
import "../common"
import vk "vendor:vulkan"

create_vertex_buffer :: proc(vertices: []$T, buffer: ^common.Vertex_Buffer) -> (ok: bool) {
    using bound_state
    cvk_buffer, err := mem.new(CVK_Buffer); if err != nil {
        log.error("Failed to create buffer:", err)
        return false
    }
    defer if !ok do mem.free(cvk_buffer)

    properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    _create_buffer(vertices, {.VERTEX_BUFFER}, properties, cvk_buffer)

    // Copy buffer
    vk_data: rawptr
    vk.MapMemory(device, cvk_buffer.memory, 0, vk.DeviceSize(cvk_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(vertices), int(cvk_buffer.size))
    vk.UnmapMemory(device, cvk_buffer.memory)

    buffer^ = transmute(common.Vertex_Buffer)cvk_buffer
    return true
}

destroy_vertex_buffer :: proc(buffer: common.Vertex_Buffer) {
    _destroy_buffer(transmute(^CVK_Buffer)buffer)
}

_create_buffer :: proc(data: []$T, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags, buffer: ^CVK_Buffer) -> (ok: bool) {
    using bound_state
    buffer.size = u64(type_info_of(typeid_of(T)).size * len(data))

    buffer_create_info: vk.BufferCreateInfo = {
        sType = .BUFFER_CREATE_INFO,
        size = vk.DeviceSize(buffer.size),
        usage = usage,
        sharingMode = .EXCLUSIVE,
    }

    res := vk.CreateBuffer(device, &buffer_create_info, nil, &buffer.buffer); if res != .SUCCESS {
        log.error("Failed to create buffer:", res)
        return false
    }
    defer if !ok do vk.DestroyBuffer(device, buffer.buffer, nil)

    requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(device, buffer.buffer, &requirements)

    memory_alloc_info: vk.MemoryAllocateInfo = {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = requirements.size,
        memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, properties),
    }

    res = vk.AllocateMemory(device, &memory_alloc_info, nil, &buffer.memory); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(device, buffer.memory, nil)
    vk.BindBufferMemory(device, buffer.buffer, buffer.memory, 0)

    return true
}

_destroy_buffer :: proc(buffer: ^CVK_Buffer) {
    using bound_state
    vk.DeviceWaitIdle(device)
    vk.DestroyBuffer(device, buffer.buffer, nil)
    vk.FreeMemory(device, vk.DeviceMemory(buffer.memory), nil)
    mem.free(buffer)
}