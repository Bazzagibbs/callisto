package callisto

import "core:math"
import "core:math/linalg"


// D3D11: x-right, y-up, z-forward (left handed)
// Callisto: x-right, z-up, y-forward, (right handed)
// So need to swap z and y columns



// Reversed-depth (1 near, 0 far) perspective projection matrix. 
matrix4_perspective :: proc(fov_y, aspect, near, far: f32) -> matrix[4,4]f32 {
        scale_y       := 1 / math.tan(fov_y * 0.5)
        scale_x       := scale_y / aspect
        scale_z       := near / (near - far)
        translation_z := -far * scale_z

        return matrix[4,4]f32 {
                scale_x, 0,       0,       0,
                0,       0,       scale_y, 0,
                0,       scale_z, 0,       translation_z,
                0,       1,       0,       0
        }
}


// Reversed-depth (1 near, 0 far) orthographic projection matrix. 
matrix4_orthographic :: proc(scale_y, aspect, near, far: f32) -> matrix[4,4]f32 {
        scale_y       := 2 / scale_y
        scale_x       := scale_y / aspect
        scale_z       := 1 / (near - far)
        translation_z := -near * scale_z

        return matrix[4,4]f32 {
                scale_x, 0,       0,       0,
                0,       0,       scale_y, 0,
                0,       scale_z, 0,       translation_z,
                0,       0,       0,       1
        }
}
