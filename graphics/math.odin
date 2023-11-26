package callisto_graphics

import cc "../common"
import "core:math"
import "core:math/linalg"

// Perspective projection matrix for Callisto world space to Vulkan NDC
matrix4_perspective :: proc "contextless" (fovy, aspect, near, far: f32) -> cc.mat4 {
    tan_half_fovy := 1 / math.tan_f32(fovy * 0.5)
    k := far / (far - near)

    return cc.mat4 {
        tan_half_fovy / aspect,     0,                  0,                  0,
        0,                          0,                  -tan_half_fovy,     0,
        0,                          k,                  0,                  -near * k,
        0,                          1,                  0,                  0,
    }
}


// Orthographic projection matrix for Callisto world space to Vulkan NDC
matrix4_orthographic :: proc "contextless" (size_y, aspect, near, far: f32) -> cc.mat4 {
    return cc.mat4 {
        2 / (size_y * aspect),      0,                  0,                  0,
        0,                          0,                  -(2 / size_y),      0,
        0,                          1 / (far - near),   0,                  0,
        0,                          0,                  0,                  1,
    }
}


// INTERMEDIATE_SPACE :: cc.mat4 {  // Inverse of (y = -z), (z = y)
//     1,  0,  0,  0,
//     0,  0, -1,  0,
//     0,  1,  0,  0,
//     0,  0,  0,  1,
// }
