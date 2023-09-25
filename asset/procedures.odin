package callisto_asset

import "core:runtime"

make :: proc {
    make_mesh,
    make_material,
}

delete :: proc {
    delete_mesh,
    delete_material,
}


// Allocates using context allocator
make_mesh :: proc(vertex_group_count, buffer_size: int) -> Mesh {
    mesh: Mesh
    mesh.vertex_groups = runtime.make([]Vertex_Group, vertex_group_count)
    mesh.buffer        = runtime.make([]u8, buffer_size)
    return mesh
}

delete_mesh :: proc(mesh: ^Mesh) {
    runtime.delete(mesh.vertex_groups)
    runtime.delete(mesh.buffer)
}



make_material :: proc() -> Material {
}

delete_material :: proc(material: ^Material) {

}

