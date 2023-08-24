package callisto_importer

import "core:log"
import "core:strings"
import "vendor:cgltf"
import "../common"
import "../asset"

// note: Allocates using context allocator
import_gltf :: proc(model_path: string) -> (meshes: []asset.Mesh, materials: []asset.Material, ok: bool) {
    model_path_cstr, _ := strings.clone_to_cstring(model_path)
    defer delete_cstring(model_path_cstr)
    data, res1 := cgltf.parse_file({}, model_path_cstr); if res1 != .success {
        log.error("Error loading file", model_path, ":", res1)
        ok = false; return
    }
    defer cgltf.free(data)

    if res := cgltf.load_buffers({}, data, model_path_cstr); res != .success {
        log.error("Failed to load glTF buffers")
        ok = false; return
    }

    meshes = make([]asset.Mesh, len(data.meshes))

    for mesh, i in data.meshes {
        for primitive in mesh.primitives {
            if primitive.type != .triangles {
                log.error("Primitive type not implemented:", primitive.type)
            }
            
            for attribute in primitive.attributes {
                switch attribute.type {
                    case .invalid: 
                        log.error("Invalid attribute type")
                        // return false
                    
                    case .position: 
                        meshes[i].positions = make([]asset.vec3, attribute.data.count)
                        _ = cgltf.accessor_unpack_floats(attribute.data, transmute(^f32)raw_data(meshes[i].positions), attribute.data.count * 3)
                    
                    case .normal: 
                        meshes[i].normals = make([]asset.vec3, attribute.data.count)
                        _ = cgltf.accessor_unpack_floats(attribute.data, transmute(^f32)raw_data(meshes[i].normals), attribute.data.count * 3)

                    case .texcoord:
                        tex_coord_store: ^f32
                        switch attribute.name {
                            case "TEXCOORD_0": 
                                meshes[i].tex_coords_0 = make([]asset.vec2, attribute.data.count)
                                tex_coord_store = transmute(^f32)raw_data(meshes[i].tex_coords_0)
                            case "TEXCOORD_1":
                                meshes[i].tex_coords_1 = make([]asset.vec2, attribute.data.count)
                                tex_coord_store = transmute(^f32)raw_data(meshes[i].tex_coords_1.([]asset.vec2))
                            case: 
                                log.warn("Unsupported number of texture coordinates:", attribute.name)
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
                        log.warn("glTF Attribute type not implemented:", attribute.type)
                }

                indices_accessor := primitive.indices
                delete(meshes[i].indices)
                meshes[i].indices = make([]u32, indices_accessor.count)

                for j in 0..<indices_accessor.count {
                    meshes[i].indices[j] = u32(cgltf.accessor_read_index(indices_accessor, j))
                }

            }
        }
    }

    ok = true
    return
}
