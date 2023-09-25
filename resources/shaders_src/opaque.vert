#version 450

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
} ubo;

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec2 vertUV;
layout(location = 2) in vec3 vertNormal;
layout(location = 3) in vec4 vertTangent;

layout(location = 0) out vec2 fragUV;
layout(location = 1) out vec3 fragNormal;
layout(location = 2) out vec4 fragTangent;

void main() {
    fragUV = vertUV;
    
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(vertPosition, 1.0);
    mat4 modelViewMatrix = ubo.view * ubo.model;
    fragNormal = (modelViewMatrix * vec4(vertNormal, 1.0)).xyz;
    fragTangent = vec4(0.0, 0.0, 0.0, 1.0);
}