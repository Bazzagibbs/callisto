#version 450

layout(binding=1) uniform sampler2D mainTexture;
layout(location=0) in vec2 fragNormal;

layout(location=0) out vec4 outColor;

void main() {
    vec2 uv = fragNormal.xy;
    // uv.y *= -1;
    uv += 1;
    uv *= 0.5;

    outColor = texture(mainTexture, uv);
    // outColor = vec4(uv, 0, 1);
}