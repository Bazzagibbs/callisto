#version 460

// #include <cal_fragment_input.glsl>

// UNIFORMS
// ========

// set 0: sceneData

layout(set=1, binding=0) uniform PassData {
    mat4 view;
    mat4 proj;
    mat4 viewproj;
} passData;

// set 2: materialData

layout(set=3, binding=0) uniform ModelData {
    mat4 model;
    mat4 modelView;
    mat4 mv_InverseTranspose;
    mat4 mvp;
    vec3 camPosition_World;
} modelData;


// VERTEX INPUT
// ============

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec3 vertNormal;
layout(location = 2) in vec4 vertTangent;
layout(location = 3) in vec2 vertTexCoord_0;
layout(location = 4) in vec2 vertTexCoord_1;
layout(location = 5) in vec4 vertColor_0;
layout(location = 6) in vec4 vertColor_1;


// FRAGMENT INPUT // TODO: move to cal_fragment_input.glsl
// ==============

// built-in          out vec4 gl_Position;
layout(location = 0) out vec3 fragPositionWorld;
layout(location = 1) out vec3 fragNormal;
layout(location = 2) out vec4 fragTangent;
layout(location = 3) out vec2 fragTexCoord_0;
layout(location = 4) out vec2 fragTexCoord_1;
layout(location = 5) out vec4 fragColor_0;
layout(location = 6) out vec4 fragColor_1;


void main() {
    gl_Position       = modelData.mvp * vec4(vertPosition, 1.0);
    fragPositionWorld = modelData.model * vertPosition;
    fragNormal        = modelData.mv_InverseTranspose * vec4(vertNormal, 0);
    fragTangent       = vec4(modelData.mv_InverseTranspose * vec4(vertTangent.xyz, 0), vertTangent.w);
    fragTexCoord_0    = vertTexCoord_0;
    fragTexCoord_1    = vertTexCoord_1;
    fragColor_0       = vertColor_0;
    fragColor_1       = vertColor_1;
}
