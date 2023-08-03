package callisto_graphics_common

import "../../common"

Built_In :: struct {
    texture_white           : Texture,
    texture_black           : Texture,
    texture_transparent     : Texture,
}

Handle                  :: common.Handle

Buffer                  :: distinct Handle

Vertex_Buffer           :: distinct Buffer
Index_Buffer            :: distinct Buffer
Uniform_Buffer          :: distinct Buffer

Mesh                    :: distinct Handle


Shader                  :: distinct Handle

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
    cull_mode               : Shader_Description_Cull_Mode,
}

Shader_Description_Cull_Mode :: enum {
    BACK,
    FRONT,
    NONE,
}


// Material_Master         :: distinct Handle
// Material_Variant        :: distinct Handle // Overrides uniforms from a material master
Material_Instance       :: distinct Handle // Instantiated values from a material master or variant

Texture                 :: distinct Handle

Texture_Description :: struct {
    image_path              : string,
    color_space             : Image_Color_Space,
}

Texture_Binding         :: distinct u32

Image_Color_Space :: enum {
    SRGB,
    LINEAR,
}
