package callisto_graphics

import "../config"

when config.RENDERER_API == .Vulkan {
    import vk "vendor:vulkan"

    Vertex_Buffer :: struct {
        handle:         vk.Buffer,
        memory_handle:  vk.DeviceMemory,
        size:           u32,    // byte size of the buffer
        vertex_count:   u32,
    }
}