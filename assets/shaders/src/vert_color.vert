#version 450

layout(location = 0) in vec3 vertPosition;
layout(location = 1) in vec3 vertColor;

layout(location = 0) out vec3 fragColor;

void main() {
    gl_Position = vec4(vertPosition, 1.0);
    fragColor = vertColor;
}