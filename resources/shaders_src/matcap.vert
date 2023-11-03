#version 450

// layout(set=0, binding=0) uniform SceneBuffer {
//     // lights?
// } sceneData;

layout(set=1, binding=0) uniform PassBuffer {
    mat4 view;
    mat4 proj;
    mat4 viewproj;
} passData;

// layout(set=2, binding=0) uniform MaterialBuffer {
//     // textures, colors
//     
// } materialData;

layout(set=3, binding=0) uniform ModelBuffer {
    mat4 model;
} modelData;

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec3 vertNormal;
layout(location = 2) in vec4 vertTangent;
// layout(location = 3) in vec2 vertUV;

layout(location = 0) out vec2 fragNormal;
// layout(location = 1) out vec2 fragUV;

void main() {
    gl_Position = passData.viewproj * modelData.model * vec4(vertPosition, 1.0);
    fragNormal = (transpose(inverse(passData.view * modelData.model)) * vec4(vertNormal, 1.0)).xy;
    // fragNormal = (transform * vec4(vertNormal, 1)).xyz;
}
