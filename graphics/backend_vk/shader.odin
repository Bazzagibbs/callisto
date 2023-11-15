package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:os"

Pipeline_Info :: struct {
    stages:             []vk.PipelineShaderStageCreateInfo,
    vertex_input:       vk.PipelineVertexInputStateCreateInfo,
    input_assembly:     vk.PipelineInputAssemblyStateCreateInfo,
    viewport:           vk.Viewport,
    scissor:            vk.Rect2D,
    rasterizer:         vk.PipelineRasterizationStateCreateInfo,
    color_blend:        vk.PipelineColorBlendAttachmentState,
    multisampling:      vk.PipelineMultisampleStateCreateInfo,
    layout:             vk.PipelineLayout,
}

// SHADER MODULE
// ///////////// 

create_shader_module_from_path :: proc(cg_ctx: ^Graphics_Context, file_path: string) -> (shader_module: vk.ShaderModule, ok: bool) {
    data: []byte
    data, ok = os.read_entire_file_from_filename(file_path)
    
    return create_shader_module_from_data(cg_ctx, data)
}

create_shader_module_from_data :: proc(cg_ctx: ^Graphics_Context, data: []byte) -> (shader_module: vk.ShaderModule, ok: bool) {
    len_u32 := len(data) / 4
    data_u32 := (^u32)(raw_data(data))
    
    module_create_info := vk.ShaderModuleCreateInfo {
        sType       = .SHADER_MODULE_CREATE_INFO,
        codeSize    = len_u32,
        pCode       = data_u32,
    }

    res := vk.CreateShaderModule(cg_ctx.device, &module_create_info, nil, &shader_module)
    check_result(res) or_return

    return shader_module, true
}


// PIPELINE
// ////////

// Forward pipeline with a vertex and fragment shader
create_default_graphics_pipeline :: proc(cg_ctx: ^Graphics_Context, pipeline_info: ^Pipeline_Info) -> (pipeline: vk.Pipeline, ok: bool) {
    dynamic_states := []vk.DynamicState {
        .VIEWPORT,
        .SCISSOR,
    }

    dynamic_state_info := vk.PipelineDynamicStateCreateInfo {
        sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        dynamicStateCount = u32(len(dynamic_states)),
        pDynamicStates = raw_data(dynamic_states),
    }

    desc_set_layouts := []vk.DescriptorSetLayout {
        {}, // Scene
        {}, // Pass
        {}, // Material -- THIS IS SET HERE BASED ON SHADER INPUTS
        {}, // Model
    }

    pipeline_create_info := vk.PipelineLayoutCreateInfo {
        sType = .PIPELINE_LAYOUT_CREATE_INFO,
        // pSetLayoutCount = 4,
        pSetLayouts = nil,
    }

    layout: vk.PipelineLayout

    res := vk.CreatePipelineLayout(cg_ctx.device, &pipeline_create_info, nil, &layout)
    check_result(res) or_return

    // /////////////////////////
    
    // vk.CreateGraphicsPipelines()

    return 
}

vertex_input :: proc() {
    vert_input := vk.PipelineVertexInputStateCreateInfo {
        sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount = 0,
        vertexAttributeDescriptionCount = 0,
    }
}
