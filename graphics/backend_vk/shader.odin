package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:os"
import cc "../../common"

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

create_graphics_pipeline :: proc(cg_ctx: ^Graphics_Context, shader_description: ^cc.Shader_Description) -> (shader: ^CVK_Shader, ok: bool) {
    info := create_pipeline_info(2)
    defer destroy_pipeline_info(&info)

    info.device = cg_ctx.device
    info.render_pass_obj = cg_ctx.render_pass
    info.cull_mode = _cull_mode_to_vk_cull_mode(shader_description.cull_mode)
    vert_shader_module, _ := create_shader_module(&info, shader_description.vertex_shader_data)
    frag_shader_module, _ := create_shader_module(&info, shader_description.fragment_shader_data)
    defer destroy_shader_module(&info, vert_shader_module)
    defer destroy_shader_module(&info, frag_shader_module)

    info.stages[0] = pipeline_stage(vert_shader_module, {.VERTEX})
    info.stages[1] = pipeline_stage(frag_shader_module, {.FRAGMENT})

    info.viewport_details = vk.Viewport{
        x = 0,
        y = 0,
        width = f32(cg_ctx.swapchain_extents.width),
        height = f32(cg_ctx.swapchain_extents.height),
        minDepth = 0,
        maxDepth = 1,
    }
    info.scissor_details.offset = {0, 0}
    info.scissor_details.extent = cg_ctx.swapchain_extents

    pipeline_vertex_input(&info)
    pipeline_input_assembly(&info)
    pipeline_viewport_state(&info)
    pipeline_rasterizer(&info, .FILL)
    pipeline_multisample(&info)
    pipeline_color_blend(&info)

    // This could be moved/managed by render graph?
    pipeline_layout(&info) or_return
    defer if !ok do vk.DestroyPipelineLayout(info.device, info.layout_obj, nil)
    // ////////////////////////////////////////////
   
    shader = new(CVK_Shader)
    defer if !ok do free(shader)

    shader.layout = info.layout_obj
    shader.pipeline = pipeline_build_graphics(&info) or_return

    return shader, true
}

destroy_pipeline :: proc(cg_ctx: ^Graphics_Context, shader: ^CVK_Shader) {
    vk.DestroyPipeline(cg_ctx.device, shader.pipeline, nil)
    vk.DestroyPipelineLayout(cg_ctx.device, shader.layout, nil)
    free(shader)
}

create_pipeline_info :: proc(n_stages: int) -> Pipeline_Info {
    info: Pipeline_Info
    info.stages = make([]vk.PipelineShaderStageCreateInfo, n_stages)
    return info
}

destroy_pipeline_info :: proc(info: ^Pipeline_Info) {
    delete(info.stages)
}

create_shader_module :: proc(info: ^Pipeline_Info, data: []byte) -> (shader_module: vk.ShaderModule, ok: bool) {
    len_u32 := len(data) 
    data_u32 := (^u32)(raw_data(data))
    
    module_create_info := vk.ShaderModuleCreateInfo {
        sType       = .SHADER_MODULE_CREATE_INFO,
        codeSize    = len_u32,
        pCode       = data_u32,
    }

    res := vk.CreateShaderModule(info.device, &module_create_info, nil, &shader_module)
    check_result(res) or_return

    return shader_module, true
}

destroy_shader_module :: proc(info: ^Pipeline_Info, module: vk.ShaderModule) {
    vk.DestroyShaderModule(info.device, module, nil)
}

// ////////////////////////////////////////////////////////////////////////////////

pipeline_stage :: proc(module: vk.ShaderModule, stage: vk.ShaderStageFlags) -> vk.PipelineShaderStageCreateInfo {
    stage_info := vk.PipelineShaderStageCreateInfo {
        sType   = .PIPELINE_SHADER_STAGE_CREATE_INFO,
        stage   = stage,
        module  = module,
        pName   = "main",
    }

    return stage_info
}


pipeline_vertex_input :: proc(info: ^Pipeline_Info) { // TODO: pass vertex attribute description here
    info.vertex_input = vk.PipelineVertexInputStateCreateInfo {
        sType                           = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount   = 0,
        vertexAttributeDescriptionCount = 0,
    }
}


pipeline_input_assembly :: proc(info: ^Pipeline_Info, topology: vk.PrimitiveTopology = .TRIANGLE_LIST) {
    info.input_assembly = vk.PipelineInputAssemblyStateCreateInfo {
        sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        topology = topology,
    }
}


pipeline_rasterizer :: proc(info: ^Pipeline_Info, poly_mode: vk.PolygonMode = .FILL) {
    info.rasterizer = vk.PipelineRasterizationStateCreateInfo {
        sType                   = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        depthClampEnable        = false,
        rasterizerDiscardEnable = false,
        polygonMode             = poly_mode,
        lineWidth               = 1,
        cullMode                = info.cull_mode,
        frontFace               = .COUNTER_CLOCKWISE,
    }
}


pipeline_multisample :: proc(info: ^Pipeline_Info) {
    info.multisample = vk.PipelineMultisampleStateCreateInfo {
        sType                   = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        rasterizationSamples    = {._1},
        minSampleShading        = 1,
    }
}


pipeline_color_blend :: proc(info: ^Pipeline_Info) {
    info.color_blend_attach = vk.PipelineColorBlendAttachmentState {
        colorWriteMask  = {.R, .G, .B, .A},
        blendEnable     = false,
    }

    info.color_blend = vk.PipelineColorBlendStateCreateInfo {
        sType           = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        logicOpEnable   = false,
        logicOp         = .COPY,
        attachmentCount = 1,
        pAttachments    = &info.color_blend_attach,
    }
}


pipeline_viewport_state :: proc(info: ^Pipeline_Info) {
    info.viewport = vk.PipelineViewportStateCreateInfo {
        sType           = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        viewportCount   = 1,
        pViewports      = &info.viewport_details,
        scissorCount    = 1,
        pScissors       = &info.scissor_details,
    }
}


pipeline_layout :: proc(info: ^Pipeline_Info) -> (ok: bool) {
    info.layout = vk.PipelineLayoutCreateInfo {
        sType                   = .PIPELINE_LAYOUT_CREATE_INFO,
        setLayoutCount          = 0,
        pSetLayouts             = nil,
        pushConstantRangeCount  = 0,
        pPushConstantRanges     = nil,
    }

    res := vk.CreatePipelineLayout(info.device, &info.layout, nil, &info.layout_obj)
    check_result(res) or_return

    return true
}


pipeline_build_graphics :: proc(info: ^Pipeline_Info) -> (pipeline: vk.Pipeline, ok: bool) {
    create_info := vk.GraphicsPipelineCreateInfo {
        sType               = .GRAPHICS_PIPELINE_CREATE_INFO,
        stageCount          = u32(len(info.stages)),
        pStages             = raw_data(info.stages),
        pVertexInputState   = &info.vertex_input,
        pInputAssemblyState = &info.input_assembly,
        pViewportState      = &info.viewport,
        pRasterizationState = &info.rasterizer,
        pMultisampleState   = &info.multisample,
        pColorBlendState    = &info.color_blend,
        layout              = info.layout_obj,
        renderPass          = info.render_pass_obj,
        subpass             = 0,
    }

    res := vk.CreateGraphicsPipelines(info.device, {}, 1, &create_info, nil, &pipeline)
    check_result(res) or_return

    return pipeline, true
}


@(private)
_cull_mode_to_vk_cull_mode :: proc (mode: cc.Shader_Description_Cull_Mode) -> vk.CullModeFlags {
    switch mode {
    case .BACK:
        return {.BACK}
    case .FRONT:
        return {.FRONT}
    case .NONE:
        return {}
    }

    return {}
}
