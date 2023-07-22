package callisto_graphics_common

import "../../common"

Buffer                  :: distinct common.Handle

Vertex_Buffer           :: distinct Buffer
Index_Buffer            :: distinct Buffer
Uniform_Buffer          :: distinct Buffer

Mesh                    :: distinct common.Handle


Shader_Description :: struct {
    // typeid of a struct that describes the layout of vertex attributes for this shader.
    // ```
    //  UV_Vertex :: struct {
    //      position:   [3]f32,
    //      uv:         [2]f32,
    //  }
    // ```
    vertex_typeid           : typeid,
    uniform_buffer_typeid   : typeid,
    vertex_shader_path      : string,
    fragment_shader_path    : string,
}

Shader                  :: distinct common.Handle

// Material_Master         :: distinct common.Handle
// Material_Variant        :: distinct common.Handle // Overrides uniforms from a material master
Material_Instance       :: distinct common.Handle // Instantiated values from a material master or variant
