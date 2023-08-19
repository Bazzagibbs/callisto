package callisto_asset

import "core:runtime"

delete :: proc {
    delete_meshes,
    delete_mesh,
    delete_materials,
    delete_material,
}

delete_meshes :: proc(meshes: ^[]Mesh) {
    for mesh in meshes {
        delete_mesh(&mesh)
    }
    runtime.delete(meshes^)
}

delete_mesh :: proc(mesh: ^Mesh) {
    runtime.delete(mesh.positions)
    runtime.delete(mesh.indices)
    runtime.delete(mesh.normals)
    runtime.delete(mesh.tex_coords_0)

    if tex_coords_1, ok := mesh.tex_coords_1.?; ok {
        runtime.delete(tex_coords_1)
    }
    if tangents, ok := mesh.tangents.?; ok {
        runtime.delete(tangents)
    }
    if colors_0, ok := mesh.colors_0.?; ok {
        runtime.delete(colors_0)
    }
    if joints_0, ok := mesh.joints_0.?; ok {
        runtime.delete(joints_0)
    }
    if weights_0, ok := mesh.weights_0.?; ok {
        runtime.delete(weights_0)
    }

}

delete_materials :: proc(materials: ^[]Material) {
    for material in materials {
        delete_material(&material)
    }
    runtime.delete(materials^)
}

delete_material :: proc(material: ^Material) {

}

