#version 450

void main() {

    const vec3 positions[3] = vec3[3](
        vec3(-0.5f, 0.5f, 0.0f),
        vec3(0.5f,  0.5f, 0.0f),
        vec3(0.0f,  -0.5f, 0.0f)
    );

    gl_Position = vec4(positions[gl_VertexIndex], 1.0f);
}
