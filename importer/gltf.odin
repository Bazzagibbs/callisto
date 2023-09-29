package callisto_importer

import "core:log"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:fmt"
import "core:slice"
import "core:mem"

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

            Prim_Temp_Info :: struct {
                bounds_center:              [3]f32,
                bounds_extents:             [3]f32,
                buffer_slice_size:          int,

                index_count:                int,
                vertex_count:               int,
                element_size:               int,
                n_uv_channels:              u64,
                n_color_channels:           u64,
                n_joint_weight_channels:    u64,
            }
            primitive_temp_infos := make([]Prim_Temp_Info, vertex_group_count)

            for primitive, vert_group_idx in src_mesh.primitives {
                prim_info := &primitive_temp_infos[vert_group_idx]

                // mandatory:            position          normal            tangent
                prim_info.element_size = size_of([3]f32) + size_of([3]f32) + size_of([4]f32)

                has_normals, has_tangents: bool
                for key, value in primitive.attributes {
                    accessor := &file_data.accessors[value]
                    switch {
                        case key == "POSITION":
                            prim_info.vertex_count = int(accessor.count)

                        case key == "NORMAL":
                            has_normals = true

                        case key == "TANGENT":
                            has_tangents = true

                        // case key[0] == '_': // TODO: support custom attributes
                        //     element_size += gltf_get_accessor_attribute_size(accessor)

                        case:  // Multi-channel attribute
                            key_iter := key

                            key_name, _     := strings.split_iterator(&key_iter, "_")
                            key_idx_str, _  := strings.split_iterator(&key_iter, "_")
                            key_idx, _      := strconv.parse_u64(key_idx_str)

                            switch key_name {
                                case "TEXCOORD": 
                                    prim_info.n_uv_channels = math.max(prim_info.n_uv_channels, key_idx + 1)
                                    prim_info.element_size += size_of([2]f32)
                                case "COLOR": 
                                    prim_info.n_color_channels = math.max(prim_info.n_color_channels, key_idx + 1)
                                    prim_info.element_size += size_of([4]u8)
                                case "JOINTS": 
                                    prim_info.n_joint_weight_channels = math.max(prim_info.n_joint_weight_channels, key_idx + 1)
                                    prim_info.element_size += size_of([4]u16) * 2 // Joints and weights channels are 1-1
                            }
                    }
                    
                }

                prim_info.buffer_slice_size = prim_info.element_size * prim_info.vertex_count
                total_buf_size += prim_info.buffer_slice_size

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
            mesh := &meshes[mesh_idx]
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
    
                for key, value in primitive.attributes {
                    // Copy buffers
                    switch {
                    case key == "POSITION":
                        gltf_copy_vec3_f32_buffer(value, file_data, &vert_group.position)
                    case key == "NORMAL":
                        gltf_copy_vec3_f32_buffer(value, file_data, &vert_group.normal)
                    case key == "TANGENT":
                        gltf_copy_vec4_f32_buffer(value, file_data, &vert_group.tangent)
                    // case key[0] == '_':
                    case:
                        key_iter := key

                        key_name, _     := strings.split_iterator(&key_iter, "_")
                        key_idx_str, _  := strings.split_iterator(&key_iter, "_")
                        key_idx, _      := strconv.parse_u64(key_idx_str)
                        switch key_name {
                            case "TEXCOORD": 
                                gltf_copy_vec2_f32_buffer(value, file_data, &vert_group.uv[key_idx])
                            case "COLOR": 
                                gltf_copy_color_buffer(value, file_data, &vert_group.color[key_idx])
                            case "JOINTS": 
                                gltf_copy_vec4_u16_buffer(value, false, file_data, &vert_group.joints[key_idx])
                            case "WEIGHTS": 
                                gltf_copy_vec4_u16_buffer(value, true, file_data, &vert_group.joints[key_idx])
                        }

                    }
                }
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

gltf_copy_vec2_f32_buffer :: proc(accessor_idx: u32, gltf_data: ^gltf.Data, output_mem: ^[][2]f32) {
    accessor := &gltf_data.accessors[accessor_idx]
    assert(len(output_mem) == int(accessor.count))
    
    #partial switch accessor.component_type {
    case .Float:
        for it := gltf.buf_iter_make([2]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            output_mem[it.idx] = gltf.buf_iter_elem(&it)
        }

    case .Unsigned_Short:
        for it := gltf.buf_iter_make([2]u16, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {_norm_to_float(u16, temp_vec.x), _norm_to_float(u16, temp_vec.y)}
        }
    case .Unsigned_Byte:
        for it := gltf.buf_iter_make([2]u8, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {_norm_to_float(u8, temp_vec.x), _norm_to_float(u8, temp_vec.y)}
        }
    }
}

gltf_copy_vec3_f32_buffer :: proc(accessor_idx: u32, gltf_data: ^gltf.Data, output_mem: ^[][3]f32) {
    accessor := &gltf_data.accessors[accessor_idx]
    assert(len(output_mem) == int(accessor.count))
    
    #partial switch accessor.component_type {
    case .Float:
        for it := gltf.buf_iter_make([3]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            output_mem[it.idx] = gltf.buf_iter_elem(&it)
        }

    case .Unsigned_Short:
        for it := gltf.buf_iter_make([3]u16, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {_norm_to_float(u16, temp_vec.x), _norm_to_float(u16, temp_vec.y), _norm_to_float(u16, temp_vec.z)}
        }
    case .Unsigned_Byte:
        for it := gltf.buf_iter_make([3]u8, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {_norm_to_float(u8, temp_vec.x), _norm_to_float(u8, temp_vec.y), _norm_to_float(u8, temp_vec.z)}
        }
    }
}

gltf_copy_vec4_f32_buffer :: proc(accessor_idx: u32, gltf_data: ^gltf.Data, output_mem: ^[][4]f32) {
    accessor := &gltf_data.accessors[accessor_idx]
    assert(len(output_mem) == int(accessor.count))
    for it := gltf.buf_iter_make([4]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
        output_mem[it.idx] = gltf.buf_iter_elem(&it)
    }
}

gltf_copy_vec4_u16_buffer :: proc(accessor_idx: u32, is_normalized: bool, gltf_data: ^gltf.Data, output_mem: ^[][4]u16) {
    accessor := &gltf_data.accessors[accessor_idx]
    assert(len(output_mem) == int(accessor.count))

    #partial switch accessor.component_type {
    case .Unsigned_Byte:
        for it := gltf.buf_iter_make([4]u8, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {u16(temp_vec.x), u16(temp_vec.y), u16(temp_vec.z), u16(temp_vec.w)}
            if is_normalized {
                output_mem[it.idx] *= 2
            }
        }
    case .Unsigned_Short:
        for it := gltf.buf_iter_make([4]u16, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            output_mem[it.idx] = gltf.buf_iter_elem(&it)
        }
    case .Float:
        for it := gltf.buf_iter_make([4]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
            temp_vec := gltf.buf_iter_elem(&it)
            output_mem[it.idx] = {_float_to_norm_u16(temp_vec.x), _float_to_norm_u16(temp_vec.y), _float_to_norm_u16(temp_vec.z), _float_to_norm_u16(temp_vec.w)}
        }
    }
}

gltf_copy_color_buffer :: proc(accessor_idx: u32, gltf_data: ^gltf.Data, output_mem: ^[][4]u8) {
    accessor := &gltf_data.accessors[accessor_idx]
    assert(len(output_mem) == int(accessor.count))
    #partial switch accessor.type {
    case .Vector3:
        // If vec3, alpha is 255
        #partial switch accessor.component_type {
        case .Float:
            for it := gltf.buf_iter_make([3]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                temp_vec := gltf.buf_iter_elem(&it)
                output_mem[it.idx] = {_float_to_norm_u8(temp_vec.x), _float_to_norm_u8(temp_vec.y), _float_to_norm_u8(temp_vec.z), 255}
            }
        case .Unsigned_Short:
            for it := gltf.buf_iter_make([3]u16, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                temp_vec := gltf.buf_iter_elem(&it)
                output_mem[it.idx] = {_norm_u16_to_norm_u8(temp_vec.x), _norm_u16_to_norm_u8(temp_vec.y), _norm_u16_to_norm_u8(temp_vec.z), 255}
            }
        case .Unsigned_Byte:
            for it := gltf.buf_iter_make([3]u8, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                temp_vec := gltf.buf_iter_elem(&it)
                output_mem[it.idx] = {temp_vec.x, temp_vec.y, temp_vec.z, 255}
            }
        }
    case .Vector4:
        #partial switch accessor.component_type {
        case .Float: 
            for it := gltf.buf_iter_make([4]f32, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                temp_vec := gltf.buf_iter_elem(&it)
                output_mem[it.idx] = {_float_to_norm_u8(temp_vec.x), _float_to_norm_u8(temp_vec.y), _float_to_norm_u8(temp_vec.z), _float_to_norm_u8(temp_vec.w)}
            }
        case .Unsigned_Short:
            for it := gltf.buf_iter_make([4]u16, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                temp_vec := gltf.buf_iter_elem(&it)
                output_mem[it.idx] = {_norm_u16_to_norm_u8(temp_vec.x), _norm_u16_to_norm_u8(temp_vec.y), _norm_u16_to_norm_u8(temp_vec.z), _norm_u16_to_norm_u8(temp_vec.w)}
            }
        case .Unsigned_Byte:
            for it := gltf.buf_iter_make([4]u8, accessor, gltf_data); it.idx < it.count; it.idx += 1 {
                output_mem[it.idx] = gltf.buf_iter_elem(&it)
            }
        }
    }

}

@(private)
_norm_to_float :: proc($T: typeid, norm: T) -> f32 {
    return f32(norm) / f32(max(T))
}

@(private)
_float_to_norm_u8 :: proc(float: f32) -> u8 {
    return u8(float * f32(max(u8)))
}
@(private)
_float_to_norm_u16 :: proc(float: f32) -> u16 {
    return u16(float * f32(max(u16)))    
}

@(private)
_norm_u16_to_norm_u8 :: proc(norm16: u16) -> u8 {
    return u8(norm16 / 2)
}

make_subslice_of_type :: proc($T: typeid, data_buffer: []u8, offset, length: int) -> (subslice: []T, next_offset: int){
    stride := size_of(T)
    subslice = transmute([]T) mem.Raw_Slice{&data_buffer[offset], length}
    return subslice, (offset + stride * length)
}
