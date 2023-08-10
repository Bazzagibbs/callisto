package callisto_asset

vec2 :: [2]f32
vec3 :: [3]f32
vec4 :: [4]f32
mat4 :: matrix[4,4]f32

Mesh                :: struct {
    // Mandatory
    vertices            : []vec3,
    indices             : []u32,
    // Optional
    normals             : Maybe([]vec3),
    tangents            : Maybe([]vec4),
    tex_coords_0        : Maybe([]vec2),
    tex_coords_1        : Maybe([]vec2),
    colors_0            : Maybe([]vec4),
    joints_0            : Maybe([]vec4),
    weights_0           : Maybe([]vec4),
}

Material            :: struct {
    // style: pbr, npr
}

