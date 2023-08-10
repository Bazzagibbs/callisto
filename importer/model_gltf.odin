package callisto_importer

import "core:log"
import "core:strings"
import "vendor:cgltf"
import "../common"
import "../asset"

import_gltf :: proc(model_path: string) -> (mesh: asset.Mesh, material: asset.Material, ok: bool) {
    model_path_cstr, _ := strings.clone_to_cstring(model_path)
    defer delete_cstring(model_path_cstr)
    data, res1 := cgltf.parse_file({}, model_path_cstr); if res1 != .success {
        log.error("Error loading file", model_path, ":", res1)
        ok = false; return
    }
    defer cgltf.free(data)

    if len(data.meshes) != 1  {
        log.error("Multiple meshes in glTF not yet implemented")
        ok = false; return
    }

    if res := cgltf.load_buffers({}, data, model_path_cstr); res != .success {
        log.error("Failed to load glTF buffers")
        ok = false; return
    }

    // for mesh in data.meshes {
    for primitive in data.meshes[0].primitives {
        if primitive.type != .triangles {
            log.error("Primitive type not implemented:", primitive.type)
        }
        
        for attribute in primitive.attributes {
            switch attribute.type {
                case .invalid: 
                    log.error("Invalid attribute type")
                    // return false
                
                case .position: 
                    mesh.vertices = make([]asset.vec3, attribute.data.count)
                    _ = cgltf.accessor_unpack_floats(attribute.data, transmute(^f32)raw_data(mesh.vertices), attribute.data.count * 3)
                
                case .normal: 
                    mesh.normals = make([]asset.vec3, attribute.data.count)
                    _ = cgltf.accessor_unpack_floats(attribute.data, transmute(^f32)raw_data(mesh.normals.([]asset.vec3)), attribute.data.count * 3)

                case .texcoord:
                    tex_coord_store: ^f32
                    switch attribute.name {
                        case "TEXCOORD_0": 
                            mesh.tex_coords_0 = make([]asset.vec2, attribute.data.count)
                            tex_coord_store = transmute(^f32)raw_data(mesh.tex_coords_0.([]asset.vec2))
                        case "TEXCOORD_1":
                            mesh.tex_coords_1 = make([]asset.vec2, attribute.data.count)
                            tex_coord_store = transmute(^f32)raw_data(mesh.tex_coords_1.([]asset.vec2))
                        case: 
                            log.error("Unsupported number of texture coordinates:", attribute.name)
                            ok = false; return
                    }
                    _ = cgltf.accessor_unpack_floats(attribute.data, tex_coord_store, attribute.data.count * 2)

                case .tangent: 
                    fallthrough
                case .color: 
                    fallthrough
                case .joints: 
                    fallthrough
                case .weights: 
                    fallthrough
                case .custom:
                    log.error("GLTF Attribute type not implemented:", attribute.type)
            }
        }
    }
    // }

    ok = true
    return
}

// gltf_accessor_to_slice
