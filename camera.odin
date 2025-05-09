package callisto

import "core:log"
import "core:math"
import "core:math/linalg"


Camera :: struct {
        // transform           : Transform,
        position            : [3]f32,
        rotation            : quaternion128,
        projection          : matrix[4,4]f32,
        aspect              : f32,
        perspective_fov_y   : f32,
        orthographic_height : f32,
        near                : f32,
        far                 : f32,
}

Camera_Uniform_Data :: struct {
        view     : matrix[4,4]f32,
        proj     : matrix[4,4]f32,
        viewproj : matrix[4,4]f32,
}


camera_create_perspective :: proc(fov_y, aspect, near, far: f32) -> Camera {
        cam := Camera {
                aspect            = aspect,
                perspective_fov_y = fov_y,
                near              = near,
                far               = far,
        }
        
        // WORLD:
        // x-right
        // y-up
        // z-forward

        // SCREEN
        // x-right [-1, 1]
        // y-down [-1, 1], (-1, -1) is top left
        // z-forward reversed [0, 1], with 1 near 0 far

        // TODO verify these axes, might need some tweaks

        scale_y := 1 / math.tan(fov_y * 0.5)
        scale_x := scale_y / aspect
        scale_z := near / (near - far)
        translation_z := -far * scale_z

        cam.projection = {
                scale_x, 0,       0,       0,
                0,       0,       scale_y, 0,
                0,       scale_z, 0,       translation_z,
                0,       1,       0,       0
        }

        return cam
}

camera_get_uniform_data :: proc(camera: ^Camera) -> Camera_Uniform_Data {
        view := linalg.matrix4_translate_f32(camera.position) * linalg.matrix4_from_quaternion_f32(camera.rotation)

        ud := Camera_Uniform_Data {
                view     = view,
                proj     = camera.projection,
                viewproj = view * camera.projection,
        }

        return ud
}

// camera_attach_to_transform :: proc(camera: ^Camera, transform: Transform = TRANSFORM_NONE)
