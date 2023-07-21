#version 450

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec2 vertUV;

layout(location = 0) out vec2 fragUV;

void main() {
    gl_Position = vec4(vertPosition, 1.0);
    fragUV = vertUV;
}