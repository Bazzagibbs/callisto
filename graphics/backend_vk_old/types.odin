package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"
import "core:mem"
import "core:math/linalg"
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
    depth_stencil:      vk.PipelineDepthStencilStateCreateInfo,
    layout:             vk.PipelineLayoutCreateInfo,
}

// CVK_Scene :: struct {
//     // descriptor_sets
// }

CVK_Render_Pass :: struct {
    render_pass:        vk.RenderPass,
    render_target:      ^CVK_Render_Target,
    framebuffers:       []vk.Framebuffer,
    is_present_output:  bool,

    pipeline_layout:    vk.PipelineLayout,      // So it can bind its descriptor set
    descriptor_layout:  vk.DescriptorSetLayout,
    descriptor_pool:    vk.DescriptorPool,

    ubo_type:               typeid,
    uniform_buffer:         Gpu_Buffer,
    uniform_set:            vk.DescriptorSet,
    uniform_offset_stride:  u64,
    
}

CVK_Render_Target :: struct {
    format:             vk.Format,
    extent:             vk.Extent2D,
    image:              Gpu_Image,
    image_view:         vk.ImageView,
    image_index:        u32,
}

CVK_Shader :: struct {
    pipeline:           vk.Pipeline,
    pipeline_layout:    vk.PipelineLayout,
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

// //////////////////////////////////////////////////////////////////////////

as_cvk_render_pass :: #force_inline proc(render_pass: cc.Render_Pass) -> ^CVK_Render_Pass {
    return transmute(^CVK_Render_Pass)render_pass
}

as_render_pass :: #force_inline proc(cvk_render_pass: ^CVK_Render_Pass) -> cc.Render_Pass {
    return transmute(cc.Render_Pass)cvk_render_pass
}

as_cvk_render_target :: #force_inline proc(render_target: cc.Render_Target) -> ^CVK_Render_Target {
    return transmute(^CVK_Render_Target)render_target
}

as_render_target :: #force_inline proc(cvk_render_target: ^CVK_Render_Target) -> cc.Render_Target {
    return transmute(cc.Render_Target)cvk_render_target
}

as_cvk_shader :: #force_inline proc(shader: cc.Shader) -> ^CVK_Shader {
    return transmute(^CVK_Shader)shader
}

as_shader :: #force_inline proc(cvk_shader: ^CVK_Shader) -> cc.Shader {
    return transmute(cc.Shader)cvk_shader
}

as_cvk_mesh :: #force_inline proc(mesh: cc.Mesh) -> ^CVK_Mesh {
    return transmute(^CVK_Mesh)mesh
}

as_mesh :: #force_inline proc(cvk_mesh: ^CVK_Mesh) -> cc.Mesh {
    return transmute(cc.Mesh)cvk_mesh
}

as_cvk_model :: #force_inline proc(model: cc.Model) -> ^CVK_Model {
    return transmute(^CVK_Model)model
}

as_model :: #force_inline proc(cvk_model: ^CVK_Model) -> cc.Model {
    return transmute(cc.Model)cvk_model
}
