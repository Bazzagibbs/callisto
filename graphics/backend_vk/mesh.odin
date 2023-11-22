package callisto_graphics_vkb
import "../../asset"
import cc "../../common"
import vk "vendor:vulkan"

// MESH
// ////

populate_binding_attribute_descriptions :: proc(asset_vg: ^asset.Vertex_Group, vert_group: ^CVK_Vertex_Group) {
    bindings    := &vert_group.vertex_input_bindings
    attribs     := &vert_group.vertex_input_attributes

    // Position
    bindings[0] = {
        binding     = 0,
        stride      = size_of(cc.vec3),
        inputRate   = .VERTEX,
    }
    attribs[0] = {
        binding     = 0,
        location    = 0,
        format      = .R32G32B32_SFLOAT,
        offset      = 0,
    }

    // Normal
    bindings[1] = {
        binding     = 1,
        stride      = size_of(cc.vec3),
        inputRate   = .VERTEX,
    }
    attribs[1] = {
        binding     = 1,
        location    = 0,
        format      = .R32G32B32_SFLOAT,
        offset      = 0,
    }

    // Tangent
    bindings[2] = {
        binding     = 2,
        stride      = size_of(cc.vec4),
        inputRate   = .VERTEX,
    }
    attribs[2] = {
        binding     = 2,
        location    = 0,
        format      = .R32G32B32A32_SFLOAT,
        offset      = 0,
    }


    // Texcoords
    for i in 0..<asset_vg.texcoord_channel_count {
        binding_idx := 3 + u32(i * 5)
        bindings[binding_idx] = {
            binding     = binding_idx,
            stride      = size_of([2]u16),
            inputRate   = .VERTEX,
        }
        attribs[binding_idx] = {
            binding     = binding_idx,
            location    = 0,
            format      = .R16G16_UINT,
            offset      = 0,
        }
    }
   
    // Colors
    for i in 0..<asset_vg.color_channel_count {
        binding_idx := 4 + u32(i * 5)
        bindings[binding_idx] = {
            binding     = binding_idx,
            stride      = size_of([4]u8),
            inputRate   = .VERTEX,
        }
        attribs[binding_idx] = {
            binding     = binding_idx,
            location    = 0,
            format      = .R8G8B8A8_UINT,
            offset      = 0,
        }
    }

    // Joint + Weight
    for i in 0..<asset_vg.joint_weight_channel_count {
        binding_idx := 5 + u32(i * 5)
        // Joint
        bindings[binding_idx] = {
            binding     = binding_idx,
            stride      = size_of([4]u16),
            inputRate   = .VERTEX,
        }
        attribs[binding_idx] = {
            binding     = binding_idx,
            location    = 0,
            format      = .R16G16B16A16_UINT,
            offset      = 0,
        }
        // Weight
        bindings[binding_idx + 1] = {
            binding     = binding_idx + 1,
            stride      = size_of([4]u16),
            inputRate   = .VERTEX,
        }
        attribs[binding_idx + 1] = {
            binding     = binding_idx + 1,
            location    = 0,
            format      = .R16G16B16A16_UINT,
            offset      = 0,
        }

    }
    // Extension
    // for i in 0..<asset_vg.extension_channel_count {
    //
    // }
}


