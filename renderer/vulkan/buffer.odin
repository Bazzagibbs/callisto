package callisto_renderer_vulkan

import "core:log"
import "core:mem"
import vk "vendor:vulkan"
import cg "../../graphics"

create_vertex_buffer :: proc(vertices: []$T, buffer: ^cg.Vertex_Buffer) -> (ok: bool) {
    using bound_state
    buffer.vertex_count = u32(len(vertices))
    buffer.size = u32(type_info_of(typeid_of(T)).size * len(vertices))

    vertex_buffer_create_info: vk.BufferCreateInfo = {
        sType = .BUFFER_CREATE_INFO,
        size = vk.DeviceSize(buffer.size),
        usage = {.VERTEX_BUFFER},
        sharingMode = .EXCLUSIVE,
    }

    res := vk.CreateBuffer(device, &vertex_buffer_create_info, nil, &buffer.handle); if res != .SUCCESS {
        log.error("Failed to create vertex buffer:", res)
        return false
    }
    defer if !ok do vk.DestroyBuffer(device, buffer.handle, nil)

    requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(device, buffer.handle, &requirements)

    memory_alloc_info: vk.MemoryAllocateInfo = {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = requirements.size,
        memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, {.HOST_VISIBLE, .HOST_COHERENT}),
    }

    res = vk.AllocateMemory(device, &memory_alloc_info, nil, &buffer.memory_handle); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(device, buffer.memory_handle, nil)
    vk.BindBufferMemory(device, buffer.handle, buffer.memory_handle, 0)
    
    // Copy buffer to gpu
    vk_data: rawptr
    vk.MapMemory(device, buffer.memory_handle, 0, vk.DeviceSize(buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(vertices), int(buffer.size))
    vk.UnmapMemory(device, buffer.memory_handle)
    return true
}

destroy_vertex_buffer :: proc(vertex_buffer: ^cg.Vertex_Buffer) {
    using bound_state
    vk.DeviceWaitIdle(device)
    vk.DestroyBuffer(device, vk.Buffer(vertex_buffer.handle), nil)
    vk.FreeMemory(device, vk.DeviceMemory(vertex_buffer.memory_handle), nil)
}