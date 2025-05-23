package callisto

import "core:log"
import "core:math"
import "core:math/linalg"

FORWARD  :: [3]f32{0, 0, -1}
BACKWARD :: [3]f32{0, 0, 1}
LEFT     :: [3]f32{-1, 0, 0}
RIGHT    :: [3]f32{1, 0, 0}
UP       :: [3]f32{0, 1, 0}
DOWN     :: [3]f32{0, -1, 0}

Camera_Projection_Mode :: enum {
        Perspective,
        Orthographic,
}
Camera :: struct {
        position        : [3]f32,
        rotation        : quaternion128,
        projection_mode : Camera_Projection_Mode,
        aspect_ratio    : f32,
        fov_y           : f32, // .Perspective only
        height          : f32, // .Orthographic only
        near_plane      : f32,
        far_plane       : f32,
}

Camera_Uniform_Data :: struct {
        view     : matrix[4,4]f32,
        proj     : matrix[4,4]f32,
        viewproj : matrix[4,4]f32,
}

// `fov_y` is in radians
projection_perspective :: proc(fov_y, aspect, near, far: f32) -> matrix[4,4]f32 { 
        // WORLD:
        //  x-right
        //  y-up
        // -z-forward

        // NDC
        // x-right [-1, 1]
        // y-up [-1, 1], (-1, -1) is bottom-left
        // z-forward reversed [0, 1], with 1 near 0 far

        // TODO verify these axes, might need some tweaks
        scale_y := 1 / math.tan(fov_y * 0.5)
        scale_x := scale_y / aspect
        scale_z := near / (near - far)
        translation_z := -far * scale_z

        return {
                scale_x, 0,       0,       0,
                0,       scale_y, 0,       0,
                0,       0,       scale_z, translation_z,
                0,       0,       1,       0
        }
}

// projection_orthographic :: proc(height, aspect, near, far: f32) -> matrix[4,4]f32 {
//         scale_y := -1 * height
//         scale_x := 
// }


camera_get_uniform_data :: proc(camera: ^Camera) -> Camera_Uniform_Data {
        cam_transform := linalg.matrix4_translate_f32(camera.position) * linalg.matrix4_from_quaternion_f32(camera.rotation)
        // view := linalg.matrix4_inverse_transpose(cam_transform)
        view := linalg.matrix4_inverse(cam_transform)
        proj : matrix[4,4]f32

        if camera.projection_mode == .Perspective {
                proj = projection_perspective(camera.fov_y, camera.aspect_ratio, camera.near_plane, camera.far_plane)
        } else {
                log.error("Orthographic projection not implemented")
                proj = projection_perspective(camera.fov_y, camera.aspect_ratio, camera.near_plane, camera.far_plane)
        }

        data := Camera_Uniform_Data {
                view     = view,
                proj     = proj,
                // viewproj = view * proj,
                viewproj = proj * view,
        }


        return data
}

