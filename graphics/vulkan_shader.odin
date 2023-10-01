//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:os"
import "core:log"
import "core:mem"
import "core:runtime"
import vk "vendor:vulkan"

_impl_create_shader :: proc(shader_description: ^Shader_Description, shader: ^Shader) -> (ok: bool) {
    state := bound_state
    cvk_shader, err := mem.new(CVK_Shader); if err != nil {
        log.error("Failed to create shader:", err)
        return false
    }
    defer if !ok do mem.free(cvk_shader)

    vert_file, err1 := os.open(shader_description.vertex_shader_path)
    if err1 != os.ERROR_NONE {
        log.error("Failed to open file", shader_description.vertex_shader_path, ":", err1)
        return false
    }
    defer os.close(vert_file)

    frag_file, err2 := os.open(shader_description.fragment_shader_path)
    if err2 != os.ERROR_NONE {
        log.error("Failed to open file", shader_description.fragment_shader_path, ":", err2)
        return false
    }
    defer os.close(frag_file)

    vert_module := _create_shader_module(state.device, vert_file) or_return
    defer vk.DestroyShaderModule(state.device, vert_module, nil)
    frag_module := _create_shader_module(state.device, frag_file) or_return
    defer vk.DestroyShaderModule(state.device, frag_module, nil)
    
    cvk_shader.uniform_buffer_typeid = shader_description.uniform_buffer_typeid

    shader_stages := [?]vk.PipelineShaderStageCreateInfo {
        // Vertex
        {
            sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            stage = {.VERTEX},
            module = vert_module,
            pName = "main",
        },
        // Fragment
        {
            sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            stage = {.FRAGMENT},
            module = frag_module,
            pName = "main",
        },
    }

    dynamic_state_create_info := vk.PipelineDynamicStateCreateInfo {
        sType             = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        dynamicStateCount = u32(len(dynamic_states)),
        pDynamicStates    = raw_data(dynamic_states),
    }

    binding_descs   := _get_vertex_binding_descriptions()
    defer delete(binding_descs)
    attribute_descs := _get_vertex_attribute_descriptions() 
    defer delete(attribute_descs)


    vertex_input_state_create_info := vk.PipelineVertexInputStateCreateInfo {
        sType                           = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount   = u32(len(binding_descs)),
        pVertexBindingDescriptions      = raw_data(binding_descs),
        vertexAttributeDescriptionCount = u32(len(attribute_descs)),
        pVertexAttributeDescriptions    = raw_data(attribute_descs),
    }

    input_assembly_state_create_info := vk.PipelineInputAssemblyStateCreateInfo {
        sType                  = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        topology               = .TRIANGLE_LIST,
        primitiveRestartEnable = false,
    }

    viewport := vk.Viewport {
        x        = 0,
        y        = 0,
        width    = f32(state.swapchain_details.extent.width),
        height   = f32(state.swapchain_details.extent.height),
        minDepth = 0,
        maxDepth = 1,
    }

    scissor := vk.Rect2D {
        offset = {0, 0},
        extent = state.swapchain_details.extent,
    }

    viewport_state_create_info := vk.PipelineViewportStateCreateInfo {
        sType         = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        viewportCount = 1,
        pViewports    = &viewport,
        scissorCount  = 1,
        pScissors     = &scissor,
    }

    rasterizer_state_create_info := vk.PipelineRasterizationStateCreateInfo {
        sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        depthClampEnable = false,
        rasterizerDiscardEnable = false,
        lineWidth = 1,
        frontFace = .COUNTER_CLOCKWISE,
        depthBiasEnable = false,
    }
    
    switch shader_description.cull_mode {
        case .BACK:
            rasterizer_state_create_info.cullMode = {.BACK}
        case .FRONT:
            rasterizer_state_create_info.cullMode = {.FRONT}
        case .NONE:
            rasterizer_state_create_info.cullMode = {}
    }

    multisample_state_create_info := vk.PipelineMultisampleStateCreateInfo {
        sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        rasterizationSamples = {._1},
        sampleShadingEnable = false,
    }

    color_blend_attachment_state := vk.PipelineColorBlendAttachmentState {
        blendEnable = false,
        colorWriteMask = {.R, .G, .B, .A},
    }

    color_blend_state_create_info := vk.PipelineColorBlendStateCreateInfo {
        sType           = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        logicOpEnable   = false,
        logicOp         = .COPY,
        attachmentCount = 1,
        pAttachments    = &color_blend_attachment_state,
    }
    
    _create_descriptor_set_layout(&cvk_shader.descriptor_set_layout) or_return
    defer if !ok do _destroy_descriptor_set_layout(&cvk_shader.descriptor_set_layout)

    pipeline_layout_create_info := vk.PipelineLayoutCreateInfo {
        sType = .PIPELINE_LAYOUT_CREATE_INFO,
        setLayoutCount = 1,
        pSetLayouts = &cvk_shader.descriptor_set_layout,
    }

    res := vk.CreatePipelineLayout(state.device, &pipeline_layout_create_info, nil, &cvk_shader.pipeline_layout); if res != .SUCCESS {
        log.fatal("Error creating pipeline layout:", res)
        return false
    }
    defer if !ok do vk.DestroyPipelineLayout(state.device, cvk_shader.pipeline_layout, nil)

    depth_stencil_state := vk.PipelineDepthStencilStateCreateInfo {
        sType = .PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        depthTestEnable = true,
        depthWriteEnable = true,
        depthCompareOp = .LESS,
        depthBoundsTestEnable = false,
        minDepthBounds = 0,
        maxDepthBounds = 1,
        stencilTestEnable = false,
        front = {},
        back = {},
    }

    pipeline_create_info := vk.GraphicsPipelineCreateInfo {
        sType               = .GRAPHICS_PIPELINE_CREATE_INFO,
        stageCount          = 2,
        pStages             = &shader_stages[0],
        pVertexInputState   = &vertex_input_state_create_info,
        pInputAssemblyState = &input_assembly_state_create_info,
        pViewportState      = &viewport_state_create_info,
        pRasterizationState = &rasterizer_state_create_info,
        pMultisampleState   = &multisample_state_create_info,
        pDepthStencilState  = &depth_stencil_state,
        pColorBlendState    = &color_blend_state_create_info,
        pDynamicState       = &dynamic_state_create_info,
        layout              = cvk_shader.pipeline_layout,
        renderPass          = state.render_pass,
        subpass             = 0,
    }

    pipeline: vk.Pipeline
    res = vk.CreateGraphicsPipelines(state.device, 0, 1, &pipeline_create_info, nil, &pipeline); if res != .SUCCESS {
        log.fatal("Error creating graphics pipeline:", res)
        return false
    }
    cvk_shader.pipeline = pipeline

    shader^ = transmute(Shader)cvk_shader
    return true
}

_create_shader_module :: proc(device: vk.Device, file: os.Handle) -> (module: vk.ShaderModule, ok: bool) {
    module_source, ok1 := os.read_entire_file(file); if !ok1 {
        log.error("Failed to create shader module: Could not read file")
        return {}, false
    }
    defer delete(module_source)

    module_info := vk.ShaderModuleCreateInfo {
        sType    = .SHADER_MODULE_CREATE_INFO,
        codeSize = len(module_source),
        pCode    = transmute(^u32)raw_data(module_source),
    }

    res := vk.CreateShaderModule(device, &module_info, nil, &module); if res != .SUCCESS {
        log.error("Failed to create shader module")
        return {}, false
    }

    ok = true
    return
}

_impl_destroy_shader :: proc(shader: Shader) {
    using bound_state
    cvk_shader := transmute(^CVK_Shader)shader

    vk.DeviceWaitIdle(device)
    vk.DestroyPipeline(device, cvk_shader.pipeline, nil)    
    vk.DestroyPipelineLayout(device, cvk_shader.pipeline_layout, nil)
    _destroy_descriptor_set_layout(&cvk_shader.descriptor_set_layout)
    mem.free(cvk_shader)
}

// TODO: calculate which attributes are used by the shaders at shader compile time
_get_vertex_binding_descriptions :: proc() -> (binding_descs: []vk.VertexInputBindingDescription) {

    binding_descs = make([]vk.VertexInputBindingDescription, 4)
    // binding_descs = make([]vk.VertexInputBindingDescription, 3)
    binding_descs[0] = {   // Position (vec3)
        binding     = 0,
        stride      = u32(3 * 4),
        inputRate   = .VERTEX,
    }
    binding_descs[1] = {   // Normal (vec3)
        binding     = 1,
        stride      = u32(3 * 4),
        inputRate   = .VERTEX,
    }
    binding_descs[2] = {   // Tangent (vec4)
        binding     = 2,
        stride      = u32(4 * 4),
        inputRate   = .VERTEX,
    }
    binding_descs[3] = {   // UV (vec2)
        binding     = 3,
        stride      = u32(2 * 4),
        inputRate   = .VERTEX,
    }
   
    return 
}

// TODO: get info from shader compile time
_get_vertex_attribute_descriptions :: proc() -> (attribute_descs: []vk.VertexInputAttributeDescription) {
    vec2, _ := _typeid_to_vk_format([2]f32)
    vec3, _ := _typeid_to_vk_format([3]f32)
    vec4, _ := _typeid_to_vk_format([4]f32)

    attribute_descs = make([]vk.VertexInputAttributeDescription, 4)
    // attribute_descs = make([]vk.VertexInputAttributeDescription, 3)
    attribute_descs[0] = {   // Position
        binding     = 0,
        location    = 0,
        format      = vec3,
        offset      = 0,
    }
    attribute_descs[1] = {   // Normal
        binding     = 1,
        location    = 1,
        format      = vec3,
        offset      = 0,
    }
    attribute_descs[2] = {   // Tangent
        binding     = 2,
        location    = 2,
        format      = vec4,
        offset      = 0,
    }
    attribute_descs[3] = {   // UV
        binding     = 3,
        location    = 3,
        format      = vec2,
        offset      = 0,
    }
    
    return
}

_typeid_to_vk_format :: #force_inline proc(id: typeid) -> (format: vk.Format, locations_used: int) {
    locations_used = 1
    switch id {
        // Unsigned Int
        case typeid_of(u8):
            format = .R8_UINT
        case typeid_of([2]u8):
            format = .R8G8_UINT
        case typeid_of([3]u8):
            format = .R8G8B8_UINT
        case typeid_of([4]u8):
            format = .R8G8B8A8_UINT
        case typeid_of(u16):
            format = .R16_UINT
        case typeid_of([2]u16):
            format = .R16G16_UINT
        case typeid_of([3]u16):
            format = .R16G16B16_UINT
        case typeid_of([4]u16):
            format = .R16G16B16A16_UINT
        case typeid_of(u32):
            format = .R32_UINT
        case typeid_of([2]u32):
            format = .R32G32_UINT
        case typeid_of([3]u32):
            format = .R32G32B32_UINT
        case typeid_of([4]u32):
            format = .R32G32B32A32_UINT
        case typeid_of(u64):
            format = .R64_UINT
        case typeid_of([2]u64):
            format = .R64G64_UINT
        case typeid_of([3]u64):
            format = .R64G64B64_UINT
        case typeid_of([4]u64):
            format = .R64G64B64A64_UINT

        // Signed Int
        case typeid_of(i8):
            format = .R8_SINT
        case typeid_of([2]i8):
            format = .R8G8_SINT
        case typeid_of([3]i8):
            format = .R8G8B8_SINT
        case typeid_of([4]i8):
            format = .R8G8B8A8_SINT
        case typeid_of(i16):
            format = .R16_SINT
        case typeid_of([2]i16):
            format = .R16G16_SINT
        case typeid_of([3]i16):
            format = .R16G16B16_SINT
        case typeid_of([4]i16):
            format = .R16G16B16A16_SINT
        case typeid_of(i32):
            format = .R32_SINT
        case typeid_of([2]i32):
            format = .R32G32_SINT
        case typeid_of([3]i32):
            format = .R32G32B32_SINT
        case typeid_of([4]i32):
            format = .R32G32B32A32_SINT
        case typeid_of(i64):
            format = .R64_SINT
        case typeid_of([2]i64):
            format = .R64G64_SINT
        case typeid_of([3]i64):
            format = .R64G64B64_SINT
        case typeid_of([4]i64):
            format = .R64G64B64A64_SINT
        
        // Float
        case typeid_of(f32):
            format = .R32_SFLOAT
        case typeid_of([2]f32):
            format = .R32G32_SFLOAT
        case typeid_of([3]f32):
            format = .R32G32B32_SFLOAT
        case typeid_of([4]f32):
            format = .R32G32B32A32_SFLOAT
        case typeid_of(f64):
            format = .R64_SFLOAT
        case typeid_of([2]f64):
            format = .R64G64_SFLOAT
        case typeid_of([3]f64):
            format = .R64G64B64_SFLOAT
            locations_used = 2
        case typeid_of([4]f64):
            format = .R64G64B64A64_SFLOAT
            locations_used = 2

        // TODO: Mat3, Mat4

        case:
            format = .UNDEFINED
    }
    return

}
