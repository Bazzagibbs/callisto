#version 450

// layout(binding=1) uniform sampler2D mainTexture;

// layout(location=0) in vec2 fragUV;
layout(location=1) in vec3 fragNormal;
layout(location=2) in vec4 fragTangent;

layout(location=0) out vec4 outColor;

void main() {
    // vec3 fragBitangent = fragTangent.w * cross(fragNormal, fragTangent.xyz);
    // mat3 tbnMatrix = mat3(fragTangent.xyz, fragBitangent, fragNormal);

    // outColor = vec4(fragNormal, 1.0);
    outColor = vec4(1.0, 0.0, 0.0, 1.0);
}
