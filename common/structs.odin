package callisto_common

// Aliased types
Handle      :: distinct rawptr
Mesh        :: distinct Handle

Vec2_U     :: [2]u32
Vec3_U     :: [3]u32
Vec4_U     :: [4]u32
Vec2_I     :: [2]i32
Vec3_I     :: [3]i32
Vec4_I     :: [4]i32

Vec2        :: [2]f32
Vec3        :: [3]f32
Vec4        :: [4]f32

Mat2        :: matrix[2,2]f32
Mat3        :: matrix[3,3]f32
Mat4        :: matrix[4,4]f32

Quat        :: quaternion128

// uuid        :: u128be

Vertex_Buffer   :: []u8
Index_Buffer    :: []u32


// Structs

Axis_Aligned_Bounding_Box :: struct {
    center     : Vec3,
    extents    : Vec3, // half of width/breadth/height
}

Transform   :: struct {
    translation     : Vec3,
    rotation        : Quat,
    scale           : [3]f32,
    // parent           : Transform,
    // children         : []Transform,
    // descendents      : []Transform,
}

