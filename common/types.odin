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

Vertex_Buffer   :: []u8
Index_Buffer    :: []u32

Mesh :: distinct Handle

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


Shader_Description :: struct {
    material_uniforms_typeid    : typeid,
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

Render_Pass_Uniforms :: struct {
    view:       mat4,
    proj:       mat4,
    viewproj:   mat4,
}

Instance_Uniforms :: struct {
    model:      mat4,
}
