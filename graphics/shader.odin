package callisto_graphics

import "core:os"
import "../config"

Shader_Description :: struct {
    vertex_shader_path:     string,
    fragment_shader_path:   string,
    // typeid of a struct that describes the layout of vertex attributes for this shader.
    // ```
    //  UV_Vertex :: struct {
    //      position:   [3]f32,
    //      uv:         [2]f32,
    //  }
    // ```
    vertex_typeid:          typeid,
}

when config.RENDERER_API == .Vulkan {
    import vk "vendor:vulkan"

    Shader :: struct {
        handle:     vk.Pipeline,
        layout:     vk.PipelineLayout,
    }
    
}
