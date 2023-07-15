package callisto_renderer_vulkan

import "core:log"
import "core:mem"
import vk "vendor:vulkan"
import cg "../../graphics"

create_vertex_buffer :: proc(state: ^State, vertices: []$T, buffer: ^cg.Vertex_Buffer) -> (ok: bool) {
    vert_array_size := vk.DeviceSize(size_of(typeid_of(T)) * len(vertices))
    vertex_buffer_create_info: vk.BufferCreateInfo = {
        sType = .BUFFER_CREATE_INFO,
        size = vert_array_size,
        usage = {.VERTEX_BUFFER},
        sharingMode = .EXCLUSIVE,
    }

    res := vk.CreateBuffer(state.device, &vertex_buffer_create_info, nil, &buffer.handle); if res != .SUCCESS {
        log.error("Failed to create vertex buffer:", res)
        return false
    }
    defer if !ok do vk.DestroyBuffer(state.device, buffer.handle, nil)

    requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(state.device, buffer.handle, &requirements)

    memory_alloc_info: vk.MemoryAllocateInfo = {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = requirements.size,
        memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, {.HOST_VISIBLE, .HOST_COHERENT}),
    }

    res = vk.AllocateMemory(state.device, &memory_alloc_info, nil, &buffer.memory_handle); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(state.device, buffer.memory_handle, nil)
    
    // Copy buffer to gpu
    vk_data: rawptr
    vk.MapMemory(state.device, buffer.memory_handle, 0, vert_array_size, {}, &vk_data)
    mem.copy(vk_data, raw_data(vertices), int(vert_array_size))
    vk.UnmapMemory(state.device, buffer.memory_handle)
    return true
}

destroy_vertex_buffer :: proc(state: ^State, vertex_buffer: ^cg.Vertex_Buffer) {
    vk.FreeMemory(state.device, vk.DeviceMemory(vertex_buffer.memory_handle), nil)
    vk.DestroyBuffer(state.device, vk.Buffer(vertex_buffer.handle), nil)
}