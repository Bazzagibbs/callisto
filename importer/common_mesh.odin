package callisto_importer

import "core:log"
import "../common"
import "../asset"

// Replace a mesh primitive's normal data with calculated flat normals.
vertex_group_calculate_flat_normals :: proc(vert_group: ^asset.Vertex_Group) -> (ok: bool) {
    // vertex_count := vert_group.position_accessor.count
    
    // delete(vert_group.normals)
    // primitive.normals = make([]asset.vec3, vertex_count)
    
    log.warn("Not implemented")
    return false
}

// Replace a mesh primitive's tangent data with tangents calculated using MikkTSpace.
vertex_group_calculate_tangents :: proc(vert_group: ^asset.Vertex_Group) -> (ok: bool) {
    // vertex_count := vert_group.position_accessor.count
    // delete(primitive.tangents)
    // primitive.tangents = make([]asset.vec4, vertex_count)


    log.warn("Not implemented")
    return false
}


