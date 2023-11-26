package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"
import "core:mem"
import "core:math/linalg"


Pipeline_Info :: struct {
    device:             vk.Device,
    viewport_details:   vk.Viewport,
    scissor_details:    vk.Rect2D,
    render_pass_obj:    vk.RenderPass,

    layout_obj:         vk.PipelineLayout,

    cull_mode:          vk.CullModeFlags,
    stages:             []vk.PipelineShaderStageCreateInfo,
    vertex_input:       vk.PipelineVertexInputStateCreateInfo,
    input_assembly:     vk.PipelineInputAssemblyStateCreateInfo,
    viewport:           vk.PipelineViewportStateCreateInfo,
    rasterizer:         vk.PipelineRasterizationStateCreateInfo,
    multisample:        vk.PipelineMultisampleStateCreateInfo,
    color_blend:        vk.PipelineColorBlendStateCreateInfo,
    color_blend_attach: vk.PipelineColorBlendAttachmentState,
    depth_stencil:      vk.PipelineDepthStencilStateCreateInfo,
    layout:             vk.PipelineLayoutCreateInfo,
}

// CVK_Scene :: struct {
//     // descriptor_sets
// }
// CVK_Render_Pass :: struct {
//     // descriptor_sets
// }

CVK_Shader :: struct {
    pipeline:   vk.Pipeline,
    layout:     vk.PipelineLayout,
}

CVK_Mesh :: struct {
    buffer:         Gpu_Buffer,
    vert_groups:    []CVK_Vertex_Group,
}

CVK_Vertex_Group :: struct {
    mesh_buffer:                vk.Buffer,
    vertex_count:               u32,
    idx_buffer_offset:          vk.DeviceSize,
    vertex_buffers:             []vk.Buffer,
    vertex_buffer_offsets:      []vk.DeviceSize,
    vertex_input_bindings:      []vk.VertexInputBindingDescription,
    vertex_input_attributes:    []vk.VertexInputAttributeDescription,
}

CVK_Model :: struct {
    mesh:       CVK_Mesh,
    materials:  []CVK_Material,
}

CVK_Material :: struct {
    shader:             CVK_Shader,
    // descriptor_set_shape: ,
    // descriptor_set: CVK_Uniforms,
}

