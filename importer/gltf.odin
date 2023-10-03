package callisto_importer
import "core:intrinsics"

import "core:log"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:fmt"
import "core:slice"
import "core:mem"
import "core:runtime"

import "vendor:cgltf"
// import "gltf"
import cc "../common"
import "../asset"

import_gltf :: proc(model_path: string) -> (
    meshes: []asset.Mesh,
    materials: []asset.Material, 
    textures: []asset.Texture, 
    models: []asset.Model, 
    constructs: []asset.Construct,
    ok: bool) {
        model_path_cstr := strings.clone_to_cstring(model_path)
        defer delete(model_path_cstr)
        file_data, res := cgltf.parse_file({}, model_path_cstr); if res != .success {
        // file_data, err := gltf.load_from_file(model_path, true); if err != nil {
            log.error("Importer [glTF]: Error loading file:", res)
            return {}, {}, {}, {}, {}, false
        }
        defer cgltf.free(file_data)
        res = cgltf.load_buffers({}, file_data, model_path_cstr); if res != .success {
            log.error("Importer [glTF]: Error loading file buffers:", res)
            return {}, {}, {}, {}, {}, false
        }

        meshes = make([]asset.Mesh, len(file_data.meshes))

        for src_mesh, mesh_idx in file_data.meshes {

            // Get total buffer size for all primitives
            total_buf_size := 0
            vertex_group_count := len(src_mesh.primitives)

            Prim_Temp_Info :: struct {
                bounds_center:              [3]f32,
                bounds_extents:             [3]f32,
                bound_min:                  [3]f32,
                bounds_max:                 [3]f32,

                buffer_slice_size:          int,

                index_count:                int,
                vertex_count:               int,
                element_size:               int,
                n_uv_channels:              u64,
                n_color_channels:           u64,
                n_joint_weight_channels:    u64,
            }
            primitive_temp_infos := make([]Prim_Temp_Info, vertex_group_count)
            defer delete(primitive_temp_infos)

            for primitive, vert_group_idx in src_mesh.primitives {
                prim_info := &primitive_temp_infos[vert_group_idx]

                // mandatory:            position          normal            tangent
                prim_info.element_size = size_of([3]f32) + size_of([3]f32) + size_of([4]f32)

                prim_info.index_count = int(primitive.indices.count)

                has_normals, has_tangents: bool

                for attribute in primitive.attributes {
                    accessor := attribute.data
                    #partial switch attribute.type {
                    case .position: 
                        prim_info.vertex_count = int(accessor.count)

                    case .normal:
                        has_normals = true

                    case .tangent:
                        has_tangents = true

                    case .texcoord:  // Multi-channel attribute
                        prim_info.n_uv_channels = math.max(prim_info.n_uv_channels, u64(attribute.index) + 1)
                        prim_info.element_size += size_of([2]f32)

                    case .color:
                        prim_info.n_color_channels = math.max(prim_info.n_color_channels, u64(attribute.index) + 1)
                        prim_info.element_size += size_of([4]u8)

                    case .joints: 
                        prim_info.n_joint_weight_channels = math.max(prim_info.n_joint_weight_channels, u64(attribute.index) + 1)
                        prim_info.element_size += size_of([4]u16) * 2 // Joints and weights channels are 1:1

                    case .custom: // TODO: support custom attributes as an extension
                        log.warn("[Importer: glTF] Custom attributes not implemented:", attribute.name)
                    }
                    
                }

                prim_info.buffer_slice_size = (prim_info.index_count * 4) + prim_info.element_size * prim_info.vertex_count
                total_buf_size += prim_info.buffer_slice_size

                if has_normals == false {
                    // vertex_group_calculate_flat_normals(vertex_group)
                    // TODO: Discard provided tangents
                    has_tangents = false
                    log.error("Importer [glTF]: Mesh is missing normals. Normal generation not implemented.")
                    // return {}, {}, {}, {}, {}, false
                } 

                if has_tangents == false {
                    log.error("Importer [glTF]: Mesh is missing tangents. Tangent generation not implemented.")
                    // return {}, {}, {}, {}, {}, false
                    // vertex_group_calculate_tangents(vertex_group)
                }
            }

            meshes[mesh_idx] = asset.make_mesh(vertex_group_count, total_buf_size)
            mesh := &meshes[mesh_idx]
            mesh_min := [3]f32{max(f32), max(f32), max(f32)}
            mesh_max := [3]f32{min(f32), min(f32), min(f32)}
            slice_begin := 0
           
            for primitive, vert_group_idx in src_mesh.primitives {
                vert_group := &mesh.vertex_groups[vert_group_idx]
                prim_info := &primitive_temp_infos[vert_group_idx]

                if prim_info.n_uv_channels > 0 {
                    vert_group.uv = make([][][2]f32, prim_info.n_uv_channels)
                }
                if prim_info.n_color_channels > 0 {
                    vert_group.color = make([][][4]u8, prim_info.n_color_channels)
                }
                if prim_info.n_joint_weight_channels > 0 {
                    vert_group.joints = make([][][4]u16, prim_info.n_joint_weight_channels)
                    vert_group.weights = make([][][4]u16, prim_info.n_joint_weight_channels)
                }

                vert_group.buffer_slice = mesh.buffer[slice_begin:prim_info.buffer_slice_size]
                                
                vert_group.index, slice_begin    = make_subslice_of_type(u32,    mesh.buffer, slice_begin, prim_info.index_count)
                vert_group.position, slice_begin = make_subslice_of_type([3]f32, mesh.buffer, slice_begin, prim_info.vertex_count)
                vert_group.normal, slice_begin   = make_subslice_of_type([3]f32, mesh.buffer, slice_begin, prim_info.vertex_count)
                vert_group.tangent, slice_begin  = make_subslice_of_type([4]f32, mesh.buffer, slice_begin, prim_info.vertex_count)

                for idx in 0..<len(vert_group.uv) {
                    vert_group.uv[idx], slice_begin = make_subslice_of_type([2]f32, mesh.buffer, slice_begin, prim_info.vertex_count)
                }
                for idx in 0..<len(vert_group.color) {
                    vert_group.color[idx], slice_begin = make_subslice_of_type([4]u8, mesh.buffer, slice_begin, prim_info.vertex_count)
                }
                for idx in 0..<len(vert_group.joints) {
                    vert_group.joints[idx], slice_begin = make_subslice_of_type([4]u16, mesh.buffer, slice_begin, prim_info.vertex_count)
                }
                for idx in 0..<len(vert_group.weights) {
                    vert_group.weights[idx], slice_begin = make_subslice_of_type([4]u16, mesh.buffer, slice_begin, prim_info.vertex_count)
                }

                gltf_unpack_indices(primitive.indices, vert_group.index)
                
                for attribute in primitive.attributes {
                    // Copy buffers
                    #partial switch attribute.type {
                    case .position:
                        min := [3]f32{attribute.data.min[0], attribute.data.min[1], attribute.data.min[2]}
                        max := [3]f32{attribute.data.max[0], attribute.data.max[1], attribute.data.max[2]}
                        mesh_min.x = math.min(min.x, mesh_min.x)
                        mesh_min.y = math.min(min.y, mesh_min.y)
                        mesh_min.z = math.min(min.z, mesh_min.z)
                        mesh_max.x = math.max(max.x, mesh_max.x)
                        mesh_max.y = math.max(max.y, mesh_max.y)
                        mesh_max.z = math.max(max.z, mesh_max.z)

                        vert_group.bounds.center, vert_group.bounds.extents = min_max_to_center_extents(min, max)
                        ok = gltf_unpack_attribute([3]f32, attribute.data, vert_group.position); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex positions")
                        }
                    case .normal:
                        ok = gltf_unpack_attribute([3]f32, attribute.data, vert_group.normal); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex normals")
                        }
                    case .tangent:
                        ok = gltf_unpack_attribute([4]f32, attribute.data, vert_group.tangent); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex tangents")
                        }
                    case .texcoord: 
                        ok = gltf_unpack_attribute([2]f32, attribute.data, vert_group.uv[attribute.index]); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex UVs")
                        }
                    case .color: 
                        ok = gltf_unpack_attribute([4]u8, attribute.data, vert_group.color[attribute.index]); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex colors")
                        }
                    case .joints: 
                        ok = gltf_unpack_attribute([4]u16, attribute.data, vert_group.joints[attribute.index]); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex colors")
                        }
                        // These need to be non-normalized
                    case .weights: 
                        ok = gltf_unpack_attribute([4]u16, attribute.data, vert_group.weights[attribute.index]); if !ok {
                            log.error("Importer [glTF]: Error unpacking vertex colors")
                        }
                    // case .custom:

                    }
                }
            }
            mesh.bounds.center, mesh.bounds.extents = min_max_to_center_extents(mesh_min, mesh_max)
        }

        // TODO: make models from mesh/material pairs
        // models = make([]asset.Model, len(file_data.meshes))

        return meshes, {}, {}, {}, {}, true
    }


gltf_unpack_attribute :: proc($T: typeid/[$N]$E, accessor: ^cgltf.accessor, out_data: []T) -> (ok: bool) {
    assert(accessor.count == len(out_data))

    n_components_in_element := N
    insert_alpha := false

    if N == 4 && accessor.type == .vec3 {
        n_components_in_element = 3
        insert_alpha = true
    }
    
    n_components := int(accessor.count) * n_components_in_element
    
    available_floats := cgltf.accessor_unpack_floats(accessor, nil, uint(n_components))
    float_storage := make([]f32, available_floats)
    defer delete(float_storage)
    
    written_data := cgltf.accessor_unpack_floats(accessor, raw_data(float_storage), uint(n_components))
    if written_data == 0 {
        log.error("Accessor could not unpack floats")
        return false
    }

    if insert_alpha {
        temp_out_data := (transmute([^]E)raw_data(out_data))[:n_components]
        dst_idx := 0
        for src_value, src_idx in float_storage {
            temp_out_data[dst_idx] = E(src_value * f32(max(E)))
            dst_idx += 1
            if src_idx % 3 == 2 {
                // Insert alpha afterwards
                temp_out_data[dst_idx] = E(src_value * f32(max(E)))
                dst_idx += 1
            }
        }
    } 
    else {
        // transmute destination buffer to flat slice
        temp_out_data := (transmute([^]E)raw_data(out_data))[:n_components]
        for src_value, src_idx in float_storage {
            if accessor.normalized {
                temp_out_data[src_idx] = E(src_value * f32(max(E)))
            } else {
                temp_out_data[src_idx] = E(src_value)
            }
        }
    }

    return true
}

gltf_unpack_indices :: proc(accessor: ^cgltf.accessor, out_indices: []u32) {
    assert(accessor.count == len(out_indices))
    for idx in 0..<accessor.count {
        out_indices[idx] = u32(cgltf.accessor_read_index(accessor, idx))
    }
}

make_subslice_of_type :: proc($T: typeid, data_buffer: []u8, offset, length: int) -> (subslice: []T, next_offset: int){
    stride := size_of(T)
    subslice = transmute([]T) mem.Raw_Slice{&data_buffer[offset], length}
    return subslice, (offset + stride * length)
}

min_max_to_center_extents :: proc(min, max: [3]f32) -> (center, extents: [3]f32) {
    center  = 0.5 * (max + min)
    extents = 0.5 * (max - min)
    return
}
