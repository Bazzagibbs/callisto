#version 460

// UNIFORMS
// ========

// set 0: sceneData

layout(set=1, binding=0) uniform Pass_Data {
    mat4 view;
    mat4 proj;
    mat4 view_proj;
} pass_data;

// set 2: materialData

layout(set=3, binding=0) uniform Model_Data {
    mat4 model;
    mat4 model_view;
    mat4 mv_inverse_transpose;
    mat4 mvp;
    vec3 cam_position_world;
} model_data;


// VERTEX INPUT
// ============

layout(location = 0) in vec3 vert_position;
layout(location = 1) in vec3 vert_normal;
layout(location = 2) in vec4 vert_tangent;
layout(location = 3) in vec2 vert_texcoord_0;
layout(location = 4) in vec2 vert_texcoord_1;
layout(location = 5) in vec4 vert_color_0;
layout(location = 6) in vec4 vert_color_1;


// FRAGMENT INPUT
// ==============

// built-in          out vec4 gl_Position;
layout(location = 0) out vec3 frag_position_world;
layout(location = 1) out vec3 frag_normal;
layout(location = 2) out vec4 frag_tangent;
layout(location = 3) out vec2 frag_texcoord_0;
layout(location = 4) out vec2 frag_texcoord_1;
layout(location = 5) out vec4 frag_color_0;
layout(location = 6) out vec4 frag_color_1;


void main() {
    gl_Position         = model_data.mvp * vec4(vert_position, 1.0);
    frag_position_world = model_data.model * vert_position;
    frag_normal         = model_data.mv_inverse_transpose * vec4(vert_normal, 0);
    frag_tangent        = vec4(model_data.mv_inverse_transpose * vec4(vert_tangent.xyz, 0), vert_tangent.w);
    frag_tex_coord_0    = vert_texcoord_0;
    frag_tex_coord_1    = vert_texcoord_1;
    frag_color_0        = vert_color_0;
    frag_color_1        = vert_color_1;
}
