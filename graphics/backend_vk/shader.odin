package callisto_graphics_vulkan

import "../../common"
import vk "vendor:vulkan"


_to_vk_descriptor_type :: proc(resource_type: common.Gpu_Shader_Resource_Type) -> vk.DescriptorType {
    switch resource_type {
        case .Storage_Image: return .STORAGE_IMAGE
    }

    return .SAMPLER
}
