package callisto_graphics

import cc "../common"
import "core:math"
import "core:math/linalg"

// Perspective projection matrix for Callisto world space to Vulkan NDC
matrix4_perspective :: proc "contextless" (fovy, aspect, near, far: f32) -> (mat: linalg.Matrix4f32) {
    ep := math.pow2_f32(-20)
    g := 1 / math.tan_f32(fovy * 0.5)
    
    mat[0, 0] = -g / aspect
    mat[1, 1] = -g
    mat[2, 2] =  ep
    mat[2, 3] =  1
    mat[3, 2] =  near * (1 - ep)

    return mat
}


// Orthographic projection matrix for Callisto world space to Vulkan NDC
matrix4_orthographic :: proc "contextless" (size_y, aspect, near, far: f32) -> (mat: linalg.Matrix4f32) {
    size_x := size_y / 9 * 16

    mat[0, 0] = -2 / size_x
    mat[1, 1] = -2 / size_y
    mat[2, 2] =  1 / (far - near)
    mat[3, 3] =  1

    return mat
}

