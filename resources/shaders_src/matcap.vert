#version 450

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
} ubo;

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec3 vertNormal;
layout(location = 2) in vec2 vertUV;

layout(location = 0) out vec2 fragNormal;
// layout(location = 1) out vec2 fragUV;

void main() {
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(vertPosition, 1.0);
    fragNormal = (ubo.view * ubo.model * vec4(vertNormal, 1.0)).xy;
    // fragNormal = (transform * vec4(vertNormal, 1)).xyz;
}