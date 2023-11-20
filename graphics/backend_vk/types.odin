package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"
import "core:mem"


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
    layout:             vk.PipelineLayoutCreateInfo,
}

CVK_Shader :: struct {
    pipeline:   vk.Pipeline,
    layout:     vk.PipelineLayout,
}

CVK_Mesh :: struct {}
