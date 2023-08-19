package callisto_graphics_vulkan

import "core:image"
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
    uniform_buffer_typeid   : typeid,
    pipeline                : vk.Pipeline,
    pipeline_layout         : vk.PipelineLayout,
    descriptor_set_layout   : vk.DescriptorSetLayout,
}

CVK_Mesh :: struct {
    indices         : ^CVK_Buffer,

    positions       : ^CVK_Buffer,
    normals         : ^CVK_Buffer,
    tex_coords_0    : ^CVK_Buffer,

    // TODO: these should probably bind to a zero buffer
    tex_coords_1    : Maybe(^CVK_Buffer),
    tangents        : Maybe(^CVK_Buffer),
    colors_0        : Maybe(^CVK_Buffer),
    joints_0        : Maybe(^CVK_Buffer),
    weights_0       : Maybe(^CVK_Buffer),
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

CVK_Texture :: struct {
    image                   : vk.Image,
    memory                  : vk.DeviceMemory,
    sampler                 : vk.Sampler,
    image_view              : vk.ImageView,
}
