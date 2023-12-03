package callisto_common

import "core:math/linalg"


// Aliased types
Handle      :: distinct rawptr

uvec2     :: [2]u32
uvec3     :: [3]u32
uvec4     :: [4]u32
ivec2     :: [2]i32
ivec3     :: [3]i32
ivec4     :: [4]i32

vec2        :: [2]f32
vec3        :: [3]f32
vec4        :: [4]f32

mat2        :: matrix[2, 2]f32
mat3        :: matrix[3, 3]f32
mat4        :: matrix[4, 4]f32

MAT2_IDENTITY :: linalg.MATRIX2F32_IDENTITY
MAT3_IDENTITY :: linalg.MATRIX3F32_IDENTITY
MAT4_IDENTITY :: linalg.MATRIX4F32_IDENTITY

color32     :: [4]u8
quat        :: linalg.Quaternionf32


Buffer      :: distinct Handle
Texture     :: distinct Handle
Mesh        :: distinct Handle
Shader      :: distinct Handle
Material    :: distinct Handle
Model       :: distinct Handle // Contains bundled Mesh and Materials
Render_Pass :: distinct Handle


Texture_Description :: struct {
    image_path              : string,
    color_space             : Image_Color_Space,
}

Image_Color_Space :: enum {
    Srgb,
    Linear,
}


Shader_Description :: struct {
    material_uniforms_typeid    : typeid,
    render_pass                 : Render_Pass,
    vertex_shader_data          : []u8,
    fragment_shader_data        : []u8,
    cull_mode                   : Shader_Description_Cull_Mode,
    depth_test                  : bool,
    depth_write                 : bool,
    depth_compare_op            : Compare_Op,
}

Shader_Description_Cull_Mode :: enum {
    Back,
    Front,
    None,
}

Compare_Op :: enum {
    Never,
    Less,
    Equal,
    Less_Or_Equal,
    Greater,
    Not_Equal,
    Greater_Or_Equal,
    Always,
}


Material_Description :: struct {
    // shader
    // uniform values (textures, colors, values)
}

Model_Description :: struct {
    model_path              : string,
}

Render_Pass_Description :: struct {
    // uniform shape
    // output target?
}

// Structs
// ///////

Axis_Aligned_Bounding_Box :: struct {
    center     : vec3,
    extents    : vec3, // half of width/breadth/height
}

Transform :: struct {
    translation     : vec3,
    rotation        : quat,
    scale           : vec3,
}


// ///////////////////////////////////////////////////////////
Render_Pass_Uniforms :: struct {
    view:       mat4,
    proj:       mat4,
    viewproj:   mat4,
}

Instance_Uniforms :: struct {
    model:      mat4,
}
