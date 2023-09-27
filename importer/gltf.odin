package callisto_importer

import "core:log"
import "core:strings"
import "core:strconv"
import "core:math"
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

                index_count := 0
                vert_count := 0
                // mandatory:   position          normal            tangent
                element_size := size_of([3]f32) + size_of([3]f32) + size_of([4]f32)

                has_normals, has_tangents: bool
                n_uv_channels, n_color_channels, n_joint_weight_channels: u64

                for key, value in primitive.attributes {
                    accessor := &file_data.accessors[value]
                    switch {
                        case key == "POSITION":
                            vert_count = int(accessor.count)
                            // element_size += size_of([3]f32) 

                        case key == "NORMAL":
                            has_normals = true
                            // element_size += size_of([3]f32)

                        case key == "TANGENT":
                            has_tangents = true
                            // element_size += size_of([4]f32)

                        // case key[0] == '_': // TODO: support custom attributes
                        //     element_size += gltf_get_accessor_attribute_size(accessor)

                        case:  // Multi-channel attribute
                            key_iter := key

                            key_name, _     := strings.split_iterator(&key_iter, "_")
                            key_idx_str, _  := strings.split_iterator(&key_iter, "_")
                            key_idx, _      := strconv.parse_u64(key_idx_str)

                            switch key_name {
                                case "TEXCOORD": 
                                    n_uv_channels = math.max(n_uv_channels, key_idx)
                                    element_size += size_of([2]f32)
                                case "COLOR": 
                                    n_color_channels = math.max(n_color_channels, key_idx)
                                    element_size += size_of([4]u8)
                                case "JOINTS": 
                                    n_joint_weight_channels = math.max(n_joint_weight_channels, key_idx)
                                    element_size += size_of([4]u16) * 2 // Joints and weights channels are 1-1
                                // case "WEIGHTS": 
                            }
                    }
                    
                }

                total_buf_size += element_size

                if has_normals == false {
                    // vertex_group_calculate_flat_normals(vertex_group)
                    // TODO: Discard provided tangents
                    has_tangents = false
                    log.error("Importer [glTF]: Mesh is missing normals. Normal generation not implemented.")
                    return {}, {}, {}, {}, {}, false
                } 

                if has_tangents == false {
                    log.error("Importer [glTF]: Mesh is missing tangents. Tangent generation not implemented.")
                    return {}, {}, {}, {}, {}, false
                    // vertex_group_calculate_tangents(vertex_group)
                }
            }

            meshes[mesh_idx] = asset.make_mesh(vertex_group_count, total_buf_size)
            for primitive, vert_group_idx in src_mesh.primitives {
                // TODO: copy buffers into allocated memory
            }
        }

        // TODO: make models from mesh/material pairs
        // models = make([]asset.Model, len(file_data.meshes))

        return meshes, {}, {}, {}, {}, true
    }

gltf_get_accessor_attribute_size :: proc(accessor: ^gltf.Accessor) -> int {
    custom_attr_size: int
    
    switch accessor.component_type {
        case .Byte: fallthrough
        case .Unsigned_Byte: custom_attr_size = 1
        case .Short: fallthrough
        case .Unsigned_Short:   custom_attr_size = 2
        case .Float: fallthrough
        case .Unsigned_Int: custom_attr_size = 4
    }
    
    switch accessor.type {
        // TODO: some accessor types are aligned strangely
        case .Scalar:   // custom_attr_size *= 1
        case .Vector2:     custom_attr_size *= 2
        case .Vector3:     custom_attr_size *= 3
        case .Vector4:     custom_attr_size *= 4
        case .Matrix2:     custom_attr_size *= 4
        case .Matrix3:     custom_attr_size *= 9
        case .Matrix4:     custom_attr_size *= 12
    }

    return custom_attr_size
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
