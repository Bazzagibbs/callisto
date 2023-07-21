package callisto_graphics_common

import "../../common"

Buffer                  :: distinct common.Handle

Vertex_Buffer           :: distinct Buffer
Index_Buffer            :: distinct Buffer

Shader                  :: distinct common.Handle

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


Mesh                    :: distinct common.Handle