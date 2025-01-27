package callisto

// Serializable reference to an asset on disk. Once loaded, can be resolved to a `Reference(T)`.
Reference_Info :: struct($T: typeid) {
        asset_id : Uuid,
}

Construct_Create_Info :: struct {
        transforms : []Transform,
        attachments : []Attachment_Info,
}

Attachment_Info :: struct {
        transform_index: int,
        // Some other data that refers to this transform
}

Mesh_Create_Info :: struct {
        submeshes : []Submesh_Info,
}

Submesh_Info :: struct {
        index_buffer       : union { []i16, []i32, },
        vertex_position    : [][3]f32,
        vertex_color       : [][4]u8,
        vertex_tex_coord_0 : [][2]f16,
        vertex_tex_coord_1 : [][2]f16,
        vertex_normal      : [][3]f16,
        vertex_tangent     : [][4]f16,
        vertex_joints_0    : [][4]u16,
        vertex_joints_1    : [][4]u16,
        vertex_weights_0   : [][4]f16,
        vertex_weights_1   : [][4]f16,
}
