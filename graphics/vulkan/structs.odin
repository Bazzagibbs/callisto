package callisto_graphics_vulkan

import vk "vendor:vulkan"
import "../common"

// Vulkan-specific structs
CVK_Buffer :: struct {
    size        : u64,
    length      : u64,
    buffer      : vk.Buffer,
    memory      : vk.DeviceMemory,
}

CVK_Shader :: struct {
    vertex_typeid           : typeid,
    uniform_buffer_typeid   : typeid,
    pipeline                : vk.Pipeline,
    pipeline_layout         : vk.PipelineLayout,
    descriptor_set_layout   : vk.DescriptorSetLayout,
}

CVK_Mesh :: struct {
    vertex_buffer   : ^CVK_Buffer,
    index_buffer    : ^CVK_Buffer,
}

// CVK_Material_Master :: struct {
//     shared_instance     : common.Material_Instance,
// }

CVK_Material_Instance :: struct {
    shader                  : ^CVK_Shader,
    uniform_buffers         : [dynamic]^CVK_Buffer,
    uniform_buffers_mapped  : [dynamic]rawptr,
    descriptor_sets         : [dynamic]vk.DescriptorSet,
}
