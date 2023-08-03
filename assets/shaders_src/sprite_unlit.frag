#version 450

layout(binding=1) uniform sampler2D mainTexture;
layout(location=0) in vec2 fragUV;

layout(location=0) out vec4 outColor;

void main() {
    // outColor = vec4(fragUV, 0.0, 1.0);
    outColor = texture(mainTexture, fragUV);
}