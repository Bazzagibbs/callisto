package callisto_importer

import "core:log"
import "core:strings"
import "core:strconv"
// import "vendor:cgltf"
import "gltf"
import cc "../common"
import "../asset"

import_gltf :: proc(model_path: string) -> (
    meshes: []asset.Mesh,
    materials: []asset.Material, 
    textures: []asset.Texture, 
    models: []asset.Model, 
    constructs: []asset.Construct,
    ok: bool) {

        file_data, err := gltf.load_from_file(model_path, true); if err != nil {
            log.error("Importer [glTF]: Error loading file:", err)
            return {}, {}, {}, {}, {}, false
        }
        defer gltf.unload(file_data)

        meshes = make([]asset.Mesh, len(file_data.meshes))

        for src_mesh, mesh_idx in file_data.meshes {
            // Get total buffer size for all primitives
            total_buf_size := 0
            vertex_group_count := len(src_mesh.primitives)

            for primitive, vert_group_idx in src_mesh.primitives {
                vertex_group := &out_mesh.vertex_groups[vert_group_idx]

                index_count := 0
                vert_count := 0
                element_size := 0

                has_normals, has_tangents: bool
                for key, value in primitive.attributes {
                    switch {
                        case key == "POSITION":
                            vert_count = file_data.accessors[value]
                        case key == "NORMAL":
                            has_normals = true
                        case key == "TANGENT":
                            has_tangents = true
                    }
                    

                }

                if has_normals == false {
                    vertex_group_calculate_flat_normals(vertex_group)
                    // TODO: Discard provided tangents
                    has_tangents = false
                } 

                if has_tangents == false {
                    vertex_group_calculate_tangents(vertex_group)
                }
            }

            meshes[mesh_idx] = asset.make_mesh(vertex_group_count, total_buf_size)
            for primitive, vert_group_idx in src_mesh.primitives {
                // TODO: copy buffers into allocated memory
            // switch {
            //     case key == "POSITION":
            //         vertex_group.position = gltf_copy_buffer_from_accessor(cc.vec3, value, file_data)
            //
            //     case key == "NORMAL": 
            //         vertex_group.normal = gltf_copy_buffer_from_accessor(cc.vec3, value, file_data)
            //         has_normals = true
            //
            //     case key == "TANGENT": 
            //         vertex_group.tangent = gltf_copy_buffer_from_accessor(cc.vec4, value, file_data)
            //         has_tangents = true
            //
            //     case key[0] == '_': // Custom attribute, store bytes
            //         log.warn("Importer [glTF]: Custom attribute not implemented:", key)
            //
            //     case:  // Multi-channel attribute
            //         key_iter := key
            //
            //         key_name, _     := strings.split_iterator(&key_iter, "_")
            //         key_idx_str, _  := strings.split_iterator(&key_iter, "_")
            //         key_idx, _      := strconv.parse_u64(key_idx_str)
            //
            //         if key_idx > 0 {
            //             log.warn("Importer [glTF]: Multiple vertex attribute channels not implemented:", key)
            //             continue
            //         }
            //
            //         switch key_name {
            //             case "TEXCOORD": 
            //                 vertex_group.uv = make([][]cc.vec2, 1)
            //                 vertex_group.uv[0] = gltf_copy_buffer_from_accessor(cc.vec2, value, file_data)
            //             case "COLOR": 
            //                 accessor := &file_data.accessors[value]
            //                 if accessor.type != .Vector4 || accessor.component_type != .Unsigned_Byte {
            //                     log.warn("Importer [glTF]: Vertex color attribute format not implemented:", accessor.type, accessor.component_type)
            //                     continue
            //                 }
            //                 vertex_group.color = make([][]cc.color32, 1)
            //                 vertex_group.color[0] = gltf_copy_buffer_from_accessor(cc.color32, value, file_data)
            //             case "JOINTS": 
            //                 vertex_group.joints = make([][]cc.vec4, 1)
            //                 vertex_group.joints[0] = gltf_copy_buffer_from_accessor(cc.vec4, value, file_data)
            //             case "WEIGHTS": 
            //                 vertex_group.weights = make([][]cc.vec4, 1)
            //                 vertex_group.weights[0] = gltf_copy_buffer_from_accessor(cc.vec4, value, file_data)
            //         }
            // }

            }
        }

        // TODO: make models from mesh/material pairs
        // models = make([]asset.Model, len(file_data.meshes))

        return meshes, {}, {}, {}, {}, true
    }

// Copy the data from the provided accessor into a slice.
//
// Allocates using the provided allocator.
gltf_copy_buffer_from_accessor :: proc($T: typeid, accessor_idx: u32, data: ^gltf.Data, allocator := context.allocator) -> []T {
    accessor := &data.accessors[accessor_idx]
    out_buffer := make([]T, accessor.count, allocator)

    for it := gltf.buf_iter_make(T, accessor, data); it.idx < it.count; it.idx += 1 {
        out_buffer[it.idx] = gltf.buf_iter_elem(&it)
    }

    return out_buffer
}

