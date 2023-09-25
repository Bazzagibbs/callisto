package callisto_common

// Aliased types
Handle      :: distinct rawptr
Mesh        :: distinct Handle

uvec2     :: [2]u32
uvec3     :: [3]u32
uvec4     :: [4]u32
ivec2     :: [2]i32
ivec3     :: [3]i32
ivec4     :: [4]i32

vec2        :: [2]f32
vec3        :: [3]f32
vec4        :: [4]f32

mat2        :: matrix[2,2]f32
mat3        :: matrix[3,3]f32
mat4        :: matrix[4,4]f32

color32     :: [4]u8
quat        :: quaternion128

// uuid        :: u128be

Vertex_Buffer   :: []u8
Index_Buffer    :: []u32


// Structs

Axis_Aligned_Bounding_Box :: struct {
    center     : vec3,
    extents    : vec3, // half of width/breadth/height
}

Transform   :: struct {
    translation     : vec3,
    rotation        : quat,
    scale           : [3]f32,
    // parent           : Transform,
    // children         : []Transform,
    // descendents      : []Transform,
}

