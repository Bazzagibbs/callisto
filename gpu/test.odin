package callisto_gpu

import "core:log"
import "core:testing"

@(test)
test_main :: proc(t: ^testing.T) {
        d: Device
        // runner := common.dummy_runner()

        device_init_info := Device_Init_Info {
                // runner = &runner,
        }

        device_init(&d, &device_init_info)
}

// @(test)
// test_clamp_length :: proc(t: ^testing.T) {
//         e2 := math.F64_EPSILON * math.F64_EPSILON
//         log.info("Epsilon squared:", e2)
//         log.info("Less than 0:", e2 <= 0)
//         
//         right := [3]f32 {15, 0, 0}
//         right_clamped := linalg.clamp_length(right, 3)
//         testing.expect_value(t, right_clamped, [3]f32 {3, 0, 0})
//
//         down := [3]f32 {0, -15, 0}
//         down_clamped := linalg.clamp_length(down, 2)
//         testing.expect_value(t, down_clamped, [3]f32 {0, -2, 0})
//
//         small := [3]f32 {0, 0, 0.2}
//         small_clamped := linalg.clamp_length(small, 1)
//         testing.expect_value(t, small_clamped, [3]f32 {0, 0, 0.2})
//
//         clamped_to_zero := linalg.clamp_length(right, 0)
//         testing.expect_value(t, clamped_to_zero, [3]f32 {0, 0, 0})
//
//         zero := [3]f32 {0, 0, 0}
//         zero_clamped := linalg.clamp_length(zero, 10) 
//         testing.expect_value(t, zero_clamped, [3]f32 {0, 0, 0})
// }
