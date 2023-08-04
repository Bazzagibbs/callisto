package callisto_graphics_vulkan

import "core:os"
import "core:log"
import "core:mem"
import "core:runtime"
import vk "vendor:vulkan"
// Graphics common
import "../common"

create_shader :: proc(shader_description: ^common.Shader_Description, shader: ^common.Shader) -> (ok: bool) {
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

    vert_module := create_shader_module(state.device, vert_file) or_return
    defer vk.DestroyShaderModule(state.device, vert_module, nil)
    frag_module := create_shader_module(state.device, frag_file) or_return
    defer vk.DestroyShaderModule(state.device, frag_module, nil)
    
    cvk_shader.vertex_typeid = shader_description.vertex_typeid
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

    binding_desc := _get_vertex_binding_description(shader_description.vertex_typeid)
    attribute_descs: [dynamic]vk.VertexInputAttributeDescription
    defer delete(attribute_descs)
    _get_vertex_attribute_descriptions(shader_description.vertex_typeid, &attribute_descs) or_return


    vertex_input_state_create_info := vk.PipelineVertexInputStateCreateInfo {
        sType                           = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount   = 1,
        pVertexBindingDescriptions      = &binding_desc,
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
    
    create_descriptor_set_layout(&cvk_shader.descriptor_set_layout) or_return
    defer if !ok do destroy_descriptor_set_layout(&cvk_shader.descriptor_set_layout)

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

    shader^ = transmute(common.Shader)cvk_shader
    return true
}

create_shader_module :: proc(device: vk.Device, file: os.Handle) -> (module: vk.ShaderModule, ok: bool) {
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

destroy_shader :: proc(shader: common.Shader) {
    using bound_state
    cvk_shader := transmute(^CVK_Shader)shader

    vk.DeviceWaitIdle(device)
    vk.DestroyPipeline(device, cvk_shader.pipeline, nil)    
    vk.DestroyPipelineLayout(device, cvk_shader.pipeline_layout, nil)
    destroy_descriptor_set_layout(&cvk_shader.descriptor_set_layout)
    mem.free(cvk_shader)
}

_get_vertex_binding_description :: proc(vertex_type: typeid) -> (binding_desc: vk.VertexInputBindingDescription) {
    binding_desc = {
        binding = 0,
        stride = u32(type_info_of(vertex_type).size),
        inputRate = .VERTEX,
    }
    return
}

_get_vertex_attribute_descriptions :: proc(vertex_type: typeid, attribute_descs: ^[dynamic]vk.VertexInputAttributeDescription) -> (ok: bool) {
    
    location_accumulator := 0
    
    vertex_type_info := type_info_of(vertex_type)
    struct_info: runtime.Type_Info_Struct = {}
    #partial switch variant_info in vertex_type_info.variant {
        case runtime.Type_Info_Named:
            struct_info = variant_info.base.variant.(runtime.Type_Info_Struct)
        case runtime.Type_Info_Struct:
            struct_info = variant_info
        case:
            log.fatal("Invalid vertex attribute struct")
            return false
    }

    attr_count := len(struct_info.types)
    resize(attribute_descs, attr_count)
    defer if !ok do resize(attribute_descs, 0)
    
    for i in 0..<attr_count {
        type := struct_info.types[i]
        offset := struct_info.offsets[i]
        ok = _get_vertex_attribute_from_type(type.id, offset, &location_accumulator, &attribute_descs[i]); if !ok {
            log.fatal("Invalid vertex attribute type:", type)
            return
        }
    }

    return
}

_get_vertex_attribute_from_type :: proc(attribute_type: typeid, offset: uintptr, location_accumulator: ^int, attribute_description: ^vk.VertexInputAttributeDescription) -> (ok: bool) {
    vk_format, locations_used := _typeid_to_vk_format(attribute_type)
    if vk_format == .UNDEFINED do return false

    attribute_description^ = {
        binding =   0,
        location =  u32(location_accumulator^),
        format =    vk_format,
        offset =    u32(offset),
    }

    location_accumulator^ += locations_used
    return true
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
