#version 450

layout(location=0) in vec2 fragUV;
// TODO: Texture sample
layout(location=0) out vec4 outColor;

void main() {
    outColor = vec4(fragUV, 0.0, 1.0);
}