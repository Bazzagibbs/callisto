package callisto_asset

vec2        :: [2]f32
vec3        :: [3]f32
vec4        :: [4]f32
vec4_u16    :: [4]u16
mat4        :: matrix[4,4]f32

Mesh                :: struct {
    // Mandatory
    indices             : []u32,
    
    positions           : []vec3,
    normals             : []vec3,
    tex_coords_0        : []vec2,
    // Optional
    tex_coords_1        : Maybe([]vec2),
    tangents            : Maybe([]vec4),
    colors_0            : Maybe([]vec4),
    joints_0            : Maybe([]vec4_u16),
    weights_0           : Maybe([]vec4),
}

Material            :: struct {
    // style: pbr, npr
}

