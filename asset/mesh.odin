package callisto_asset

import "core:io"
import "core:mem"
import vk "vendor:vulkan"
import cc "../common"


// Galileo file layout
// ///////////////////
Galileo_Mesh_Manifest :: struct #packed {
    bounds              : cc.Axis_Aligned_Bounding_Box,
    vertex_group_count  : u32,
    extension_count     : u32,
    buffer_size         : u64,
    next_mesh_extension : u32,
}

Galileo_Vertex_Group_Info :: struct #packed {
    bounds                      : cc.Axis_Aligned_Bounding_Box,
    buffer_slice_begin          : u64,
    buffer_slice_size           : u64,

    index_count                 : u32,
    vertex_count                : u32,

    texcoord_channel_count      : u8,
    color_channel_count         : u8,
    joint_weight_channel_count  : u8,
    extension_channel_count     : u8,

    next_vertex_group_extension : u32,
}
// ///////////////////

Mesh                :: struct {
    using metadata      : Asset,
    bounds              : cc.Axis_Aligned_Bounding_Box,
    vertex_groups       : []Vertex_Group,   // Each vertex group has its own draw call, and accesses a subset of the index/vertex buffers.
    buffer              : []u8,
}

Vertex_Group        :: struct {
    bounds          : cc.Axis_Aligned_Bounding_Box,

    buffer_slice                : []u8,     // Slice into mesh buffer, not allocated
    
    index_count                 : u32,
    vertex_count                : u32,

    total_channel_count         : u8,
    texcoord_channel_count      : u8,
    color_channel_count         : u8,
    joint_weight_channel_count  : u8,
    extension_channel_count     : u8,

    index_offset                : u64,
    position_offset             : u64,
    normal_offset               : u64,
    tangent_offset              : u64,

    texcoord_offset             : u64,
    color_offset                : u64,
    joint_offset                : u64,
    weight_offset               : u64,
    extension_offset            : u64,
}


load_mesh_body :: proc(file_reader: io.Reader, mesh: ^Mesh) -> (ok: bool) {
    manifest: Galileo_Mesh_Manifest
    io.read_ptr(file_reader, &manifest, size_of(Galileo_Mesh_Manifest))

    mesh.bounds         = manifest.bounds
    mesh.vertex_groups  = make([]Vertex_Group, manifest.vertex_group_count)
    mesh.buffer         = make([]u8, manifest.buffer_size)

    cursor : u64 = 0
    for _, i in mesh.vertex_groups {
        vert_group := &mesh.vertex_groups[i]
        info: Galileo_Vertex_Group_Info
        io.read_ptr(file_reader, &info, size_of(Galileo_Vertex_Group_Info))
        
        vert_group.bounds                       = info.bounds
        vert_group.buffer_slice                 = mesh.buffer[info.buffer_slice_begin:info.buffer_slice_size]
        vert_group.index_count                  = info.index_count
        vert_group.vertex_count                 = info.vertex_count
        
        vert_group.texcoord_channel_count       = info.texcoord_channel_count
        vert_group.color_channel_count          = info.color_channel_count
        vert_group.joint_weight_channel_count   = info.joint_weight_channel_count
        vert_group.extension_channel_count      = info.extension_channel_count

        vert_group.total_channel_count = 3 /* position + normal + tangent */ +
                                        info.texcoord_channel_count + 
                                        info.color_channel_count + 
                                        (info.joint_weight_channel_count * 2) +
                                        info.extension_channel_count

        
        vert_group.index_offset     = calculate_buffer_offset(u32, info.index_count, &cursor)
        vert_group.position_offset  = calculate_buffer_offset([3]f32, info.vertex_count, &cursor)
        vert_group.normal_offset    = calculate_buffer_offset([3]f32, info.vertex_count, &cursor)
        vert_group.tangent_offset   = calculate_buffer_offset([4]f32, info.vertex_count, &cursor)

        vert_group.texcoord_offset  = calculate_buffer_offset([2]u16, info.vertex_count * u32(info.texcoord_channel_count), &cursor)
        vert_group.color_offset     = calculate_buffer_offset([4]u8,  info.vertex_count * u32(info.color_channel_count), &cursor)
        vert_group.joint_offset     = calculate_buffer_offset([4]u16, info.vertex_count * u32(info.joint_weight_channel_count), &cursor)
        vert_group.weight_offset    = calculate_buffer_offset([4]u16, info.vertex_count * u32(info.joint_weight_channel_count), &cursor)
        vert_group.extension_offset = calculate_buffer_offset(u8,     info.vertex_count * u32(info.extension_channel_count), &cursor)
        
        // TODO(galileo): attribute extensions
    }

    // TODO(galileo): mesh extensions
    // for extension, i in mesh.extensions {}

    io.read(file_reader, mesh.buffer)
    return true
}


// Allocates using context allocator
make_mesh :: proc(vertex_group_count, buffer_size: int) -> Mesh {
    mesh := Mesh {
        type          = .mesh,
        vertex_groups = make([]Vertex_Group, vertex_group_count),
        buffer        = make([]u8, buffer_size),
    }

    return mesh
}


delete_mesh :: proc(mesh: ^Mesh) {
    delete(mesh.vertex_groups)
    delete(mesh.buffer)
    if mesh.name != {} {
        delete(mesh.name)
    }
}

// Convert a mesh struct to a Galileo Mesh buffer, which can be written to a file.
// 
// Allocates using provided allocator
serialize_mesh :: proc(mesh: ^Mesh, allocator := context.allocator) -> (data: []u8) {
    file_buf_size := size_of(Galileo_Mesh_Manifest) + 
                     len(mesh.vertex_groups) * size_of(Galileo_Vertex_Group_Info) + 
                     // n_extensions * size_of(Galileo_Extension_Info) +
                     len(mesh.buffer)

    data = make([]u8, file_buf_size)
    cursor := 0
    
    // Populate mesh manifest
    manifest := new_struct_in_buffer(Galileo_Mesh_Manifest, data, &cursor)
    manifest.bounds             = mesh.bounds
    manifest.vertex_group_count = u32(len(mesh.vertex_groups))
    manifest.extension_count    = 0
    manifest.buffer_size        = u64(len(mesh.buffer))

    // Populate vertex group infos
    for vg in mesh.vertex_groups {
        info := new_struct_in_buffer(Galileo_Vertex_Group_Info, data, &cursor)
        info.bounds                     = vg.bounds
        info.buffer_slice_begin         = vg.index_offset
        info.buffer_slice_size          = u64(len(vg.buffer_slice))
        info.index_count                = vg.index_count
        info.vertex_count               = vg.vertex_count
        info.texcoord_channel_count     = vg.texcoord_channel_count
        info.color_channel_count        = vg.color_channel_count
        info.joint_weight_channel_count = vg.joint_weight_channel_count
        info.extension_channel_count    = 0
    }

    // TODO(galileo): populate extension info

    // Copy mesh buffer
    mem.copy(&data[cursor], raw_data(mesh.buffer), len(mesh.buffer))

    return 
}


// Updates the cursor to the beginning index of the next attribute. Returns the beginning of the current attribute.
calculate_buffer_offset :: proc($element_type: typeid, element_count: u32, cursor: ^u64) -> u64 {
    element_size := u64(type_info_of(element_type).size)
    cursor_cache := cursor^

    cursor^ += element_size * u64(element_count)

    return cursor_cache
}


get_vertex_group_channel_offset :: proc($element_type: typeid, vertex_count: u64, attribute_offset: u64, channel: u8) -> (channel_offset: u64) {
    element_size := u64(type_info_of(element_type).size)
    channel_stride := element_size * vertex_count
    return attribute_offset + (u64(channel) * channel_stride)
}
