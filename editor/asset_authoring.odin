package callisto_editor

import cal ".."
import "core:container/queue"
import "ufbx"

Construct_Builder :: struct {
        construct    : cal.Construct,
        cursor       : int,
        child_cursor : int,
        child_queue  : queue.Queue(struct {^ufbx.Node, u32}),
}

construct_builder_init :: proc(b: ^Construct_Builder, size: int) -> (res: Result) {
        b.construct.transforms     = make([]cal.Transform, size)
        b.construct.local_matrices = make([]matrix[4,4]f32, size)
        b.construct.world_matrices = make([]matrix[4,4]f32, size)

        b.child_cursor = 1

        return .Ok
}

construct_builder_destroy :: proc(b: ^Construct_Builder) {
        delete(b.construct.transforms)
        delete(b.construct.local_matrices)
        delete(b.construct.world_matrices)
}

construct_builder_append :: proc(b: ^Construct_Builder, child_count: int) -> ^cal.Transform {
        t := &b.construct.transforms[b.cursor]
        t.child_count = i32(child_count)
        t.child_index = i32(b.child_cursor)

        b.child_cursor += child_count
        b.cursor += 1

        return t
}
