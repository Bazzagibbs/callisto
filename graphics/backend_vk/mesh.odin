package callisto_graphics_vkb
import "../../asset"
import cc "../../common"
import vk "vendor:vulkan"

// MESH
// ////

populate_binding_attribute_descriptions :: proc(asset_vg: ^asset.Vertex_Group, vert_group: ^CVK_Vertex_Group) {
    bindings    := &vert_group.vertex_input_bindings
    attribs     := &vert_group.vertex_input_attributes
    offsets     := &vert_group.vertex_buffer_offsets
    
    for &buf in vert_group.vertex_buffers {
        buf = vert_group.mesh_buffer
    }

    cursor := 0

    // Position
    bindings[cursor] = {
        binding     = 0,
        stride      = size_of(cc.vec3),
        inputRate   = .VERTEX,
    }
    attribs[cursor] = {
        binding     = 0,
        location    = 0,
        format      = .R32G32B32_SFLOAT,
        offset      = 0,
    }
    offsets[cursor] = vk.DeviceSize(asset_vg.position_offset)
    cursor += 1

    // Normal
    bindings[cursor] = {
        binding     = 1,
        stride      = size_of(cc.vec3),
        inputRate   = .VERTEX,
    }
    attribs[cursor] = {
        binding     = 1,
        location    = 1,
        format      = .R32G32B32_SFLOAT,
        offset      = 0,
    }
    offsets[cursor] = vk.DeviceSize(asset_vg.normal_offset)
    cursor += 1

    // Tangent
    bindings[cursor] = {
        binding     = 2,
        stride      = size_of(cc.vec4),
        inputRate   = .VERTEX,
    }
    attribs[cursor] = {
        binding     = 2,
        location    = 2,
        format      = .R32G32B32A32_SFLOAT,
        offset      = 0,
    }
    offsets[cursor] = vk.DeviceSize(asset_vg.tangent_offset)
    cursor += 1


    // Texcoords
    texcoord_channel_size := size_of([2]u16) * u64(asset_vg.texcoord_channel_count)
    for i in 0..<asset_vg.texcoord_channel_count {
        binding_idx := 3 + u32(i * 5)
        bindings[cursor] = {
            binding     = binding_idx,
            stride      = size_of([2]u16),
            inputRate   = .VERTEX,
        }
        attribs[cursor] = {
            binding     = binding_idx,
            location    = binding_idx,
            format      = .R16G16_UINT,
            offset      = 0,
        }
        offsets[cursor] = vk.DeviceSize(asset_vg.texcoord_offset + texcoord_channel_size * u64(i))
        
        cursor += 1
    }
   
    // Colors
    color_channel_size := size_of([4]u8) * u64(asset_vg.color_channel_count)
    for i in 0..<asset_vg.color_channel_count {
        binding_idx := 4 + u32(i * 5)
        bindings[cursor] = {
            binding     = binding_idx,
            stride      = size_of([4]u8),
            inputRate   = .VERTEX,
        }
        attribs[cursor] = {
            binding     = binding_idx,
            location    = binding_idx,
            format      = .R8G8B8A8_UINT,
            offset      = 0,
        }
        offsets[cursor] = vk.DeviceSize(asset_vg.color_offset + color_channel_size * u64(i))

        cursor += 1
    }

    // Joint + Weight
    joint_weight_channel_size := size_of([4]u8) * u64(asset_vg.joint_weight_channel_count)
    for i in 0..<asset_vg.joint_weight_channel_count {
        binding_idx := 5 + u32(i * 5)
        // Joint
        bindings[cursor] = {
            binding     = binding_idx,
            stride      = size_of([4]u16),
            inputRate   = .VERTEX,
        }
        attribs[cursor] = {
            binding     = binding_idx,
            location    = binding_idx,
            format      = .R16G16B16A16_UINT,
            offset      = 0,
        }
        offsets[cursor] = vk.DeviceSize(asset_vg.joint_offset + joint_weight_channel_size * u64(i))
        
        cursor += 1
        
        // Weight
        bindings[cursor] = {
            binding     = binding_idx + 1,
            stride      = size_of([4]u16),
            inputRate   = .VERTEX,
        }
        attribs[cursor] = {
            binding     = binding_idx + 1,
            location    = binding_idx + 1,
            format      = .R16G16B16A16_UINT,
            offset      = 0,
        }
        offsets[cursor] = vk.DeviceSize(asset_vg.joint_offset + joint_weight_channel_size * u64(i))

        cursor += 1
    }
    // Extension
    // for i in 0..<asset_vg.extension_channel_count {
    //
    // }
}


