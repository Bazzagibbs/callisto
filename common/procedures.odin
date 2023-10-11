package callisto_common

min_max_to_center_extents :: proc(min, max: [3]f32) -> (center, extents: [3]f32) {
    center  = 0.5 * (max + min)
    extents = 0.5 * (max - min)
    return
}
