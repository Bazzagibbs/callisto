package callisto_graphics_vkb
import "../../asset"
import cc "../../common"
import vk "vendor:vulkan"

// MESH
// ////

populate_binding_attribute_descriptions :: proc(asset_vg: ^asset.Vertex_Group, vert_group: ^CVK_Vertex_Group) {
    attribs     := &vert_group.vertex_input_attributes
    i := 0

    vert_group.vertex_input_bindings = []vk.VertexInputBindingDescription {
        {   // Position 
            binding = u32(asset.Vertex_Attribute_Binding.Position),
            stride  = size_of(cc.vec3),
            inputRate = .VERTEX,
        },
        {   // Normal
            binding = u32(asset.Vertex_Attribute_Binding.Normal),
            stride  = size_of(cc.vec3),
            inputRate = .VERTEX,
        },
        {   // Tangent
            binding = u32(asset.Vertex_Attribute_Binding.Tangent),
            stride  = size_of(cc.vec4),
            inputRate = .VERTEX,
        },

        {   // Texcoord
            binding = u32(asset.Vertex_Attribute_Binding.Texcoord),
            stride  = size_of(cc.vec2) * asset_vg.texcoord_channel_count,
            inputRate = .VERTEX,
        },
        {   // Color
            binding = u32(asset.Vertex_Attribute_Binding.Color),
            stride  = size_of(cc.color32) * asset_vg.color_channel_count,
            inputRate = .VERTEX,
        },
        {   // Joint + Weight
            binding = u32(asset.Vertex_Attribute_Binding.Joint_Weight),
            stride  = size_of([4]u16) * 2 * asset_vg.joint_weight_channel_count,
            inputRate = .VERTEX,
        },
    
        // Extension attributes
    }

}
