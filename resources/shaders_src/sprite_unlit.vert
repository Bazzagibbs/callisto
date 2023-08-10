#version 450

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
} ubo;

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec2 vertUV;

layout(location = 0) out vec2 fragUV;

void main() {
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(vertPosition, 1.0);
    fragUV = vertUV;
}