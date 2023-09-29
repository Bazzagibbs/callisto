package callisto_asset

import "core:runtime"

make :: proc {
    make_mesh,
    // make_material,
}

delete :: proc {
    delete_mesh,
    delete_mesh_slice,
    // delete_material,
}


// Allocates using context allocator
make_mesh :: proc(vertex_group_count, buffer_size: int) -> Mesh {
    mesh: Mesh
    mesh.vertex_groups = runtime.make([]Vertex_Group, vertex_group_count)
    mesh.buffer        = runtime.make([]u8, buffer_size)
    return mesh
}

delete_mesh :: proc(mesh: ^Mesh) {
    for vert_group in mesh.vertex_groups {
        if len(vert_group.uv) > 0       do runtime.delete(vert_group.uv)
        if len(vert_group.color) > 0    do runtime.delete(vert_group.color)
        if len(vert_group.joints) > 0   do runtime.delete(vert_group.joints)
        if len(vert_group.weights) > 0  do runtime.delete(vert_group.weights)
    }
    runtime.delete(mesh.vertex_groups)
    runtime.delete(mesh.buffer)
}

delete_mesh_slice :: proc(slice: []Mesh) {
    for mesh in slice  {
        mesh := mesh
        delete(&mesh)
    }
    runtime.delete(slice)
}

// make_material :: proc() -> Material {
//     return {}
// }

// delete_material :: proc(material: ^Material) {
//
// }

