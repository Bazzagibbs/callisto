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

vec2        :: linalg.Vector2f32
vec3        :: linalg.Vector3f32
vec4        :: linalg.Vector4f32

mat2        :: linalg.Matrix2f32
mat3        :: linalg.Matrix3f32
mat4        :: linalg.Matrix4f32

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


