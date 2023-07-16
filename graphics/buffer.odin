package callisto_graphics

import "../config"

when config.RENDERER_API == .Vulkan {
    import vk "vendor:vulkan"

    Vertex_Buffer :: struct {
        handle:         vk.Buffer,
        memory_handle:  vk.DeviceMemory,
        size:           u32,
        // vertex type?
    }
}