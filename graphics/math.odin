package callisto_graphics

import cc "../common"
import "core:math"
import "core:math/linalg"


// matrix4_perspective :: proc(fovy_rad, aspect, near, far: f32) -> cc.mat4 {
//     g := 1 / math.tan_f32(fovy_rad * 0.5)
//     k := far / (far - near)
//
//     // To Vulkan NDC ([-1, 1], [-1, 1], [0, 1])
//     return cc.mat4 {
//         
//     }
// }

matrix4_orthographic :: proc(size_y, aspect, near, far: f32) -> cc.mat4 {

    // To Vulkan NDC ([-1, 1], [-1, 1], [0, 1])
    // with intermediate space
    return cc.mat4 { 
        2 / (size_y * aspect),  0,                  0,             0,
        0,                      0,                  -(2 / size_y), 0,
        0,                      1 / (far - near),   0,             0,
        0,                      0,                  0,             1,
    }
}

// Inverse of (y = -z), (z = y)
// intermediate_space :: cc.mat4 {
//     1,  0,  0,  0,
//     0,  0, -1,  0,
//     0,  1,  0,  0,
//     0,  0,  0,  1,
// }
