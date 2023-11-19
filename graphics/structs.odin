package callisto_graphics

import "../common"

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

Mesh                    :: common.Mesh

// Contains bundled mesh/texture/material data
Model                   :: distinct Handle
Model_Description :: struct {
    model_path              : string,
}

Shader                  :: distinct Handle
Shader_Description      :: common.Shader_Description


// Material_Master         :: distinct Handle
// Material_Variant        :: distinct Handle // Overrides uniforms from a material master
Material                :: distinct Handle // Instantiated values from a material master or variant

Texture                 :: distinct Handle
Texture_Description :: struct {
    image_path              : string,
    color_space             : Image_Color_Space,
}

Image_Color_Space :: enum {
    SRGB,
    LINEAR,
}

Texture_Binding         :: distinct u32
