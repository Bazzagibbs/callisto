//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:image"
import vk "vendor:vulkan"
import "../asset"

// Vulkan-specific structs
CVK_Buffer :: struct {
    size        : u64,
    length      : u64,
    buffer      : vk.Buffer,
    memory      : vk.DeviceMemory,
}

CVK_Shader :: struct {
    material_buffer_typeid  : typeid,
    pipeline                : vk.Pipeline,
    pipeline_layout         : vk.PipelineLayout,
    descriptor_set_layout   : vk.DescriptorSetLayout,
}

// ===================================

// ===================================

CVK_Mesh :: struct {
    vertex_groups       : []CVK_Vertex_Group,
    asset               : ^asset.Mesh,
}

CVK_Vertex_Group :: struct {
    index           : ^CVK_Buffer,

    position        : ^CVK_Buffer,
    normal          : ^CVK_Buffer,
    tangent         : ^CVK_Buffer,
    uv_0            : ^CVK_Buffer,

//     // // TODO: these should probably bind to a zero buffer
//     // uv_1    : Maybe(^CVK_Buffer),
//     // colors_0        : Maybe(^CVK_Buffer),
//     // joints_0        : Maybe(^CVK_Buffer),
//     // weights_0       : Maybe(^CVK_Buffer),
}

// CVK_Material_Master :: struct {
//     shared_instance     : Material_Instance,
// }

CVK_Material_Instance :: struct {
    shader                  : ^CVK_Shader,
    uniform_buffers         : []^CVK_Buffer,
    uniform_buffers_mapped  : []rawptr,
    descriptor_sets         : []vk.DescriptorSet,
}

CVK_Texture :: struct {
    image                   : vk.Image,
    memory                  : vk.DeviceMemory,
    sampler                 : vk.Sampler,
    image_view              : vk.ImageView,
}
