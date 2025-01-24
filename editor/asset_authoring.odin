package callisto_editor

import cal ".."
import "core:container/queue"
import "ufbx"
import "core:image"

Construct_Create_Info_Builder :: struct {
        construct    : cal.Construct_Create_Info,
        attachments_buffer : [dynamic]cal.Attachment_Info,
        cursor       : int,
        child_cursor : int,
        child_queue  : queue.Queue(struct {^ufbx.Node, u32}),
}

construct_create_info_builder_init :: proc(b: ^Construct_Create_Info_Builder, size: int) -> (res: Result) {
        b.construct.transforms = make([]cal.Transform, size)
        b.attachments_buffer   = make([dynamic]cal.Attachment_Info)

        b.child_cursor = 1

        return .Ok
}

construct_create_info_builder_destroy :: proc(b: ^Construct_Create_Info_Builder) {
        delete(b.construct.transforms)
}

construct_create_info_builder_append :: proc(b: ^Construct_Create_Info_Builder, child_count: int) -> ^cal.Transform {
        t := &b.construct.transforms[b.cursor]
        t.child_count = i32(child_count)
        t.child_index = i32(b.child_cursor)

        b.child_cursor += child_count
        b.cursor += 1

        return t
}

// texture2d_create_info_from_image :: proc(img: ^image.Image, lossless := false) -> (info: cal.Texture2D_Create_Info, res: Result) {
//
// }
//
// texture2d_create_info_destroy :: proc(info: ^cal.Texture2D_Create_Info) {
//
// }
