package callisto_common

import cc "../common"

min_max_to_center_extents :: proc(min, max: [3]f32) -> (center, extents: [3]f32) {
    center  = 0.5 * (max + min)
    extents = 0.5 * (max - min)
    return
}

// set_parent :: proc(child, parent: ^cc.Transform) {
//     _ = remove_child(parent, child)
//     child.parent = parent
//     append(&parent.children, child)
//     // Also set child dirty
// }
//
// remove_child :: proc(parent, child: ^cc.Transform, maintain_order := false) -> (did_exist: bool) {
//     for transform, i in parent.children {
//         if transform == child {
//             if maintain_order == false {
//                 unordered_remove(&parent.children, i)
//             } else {
//                 ordered_remove(&parent.children, i)
//             }
//             return true
//         }
//     }
//
//     return false
// }
