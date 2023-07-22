package callisto_graphics_vulkan

import "core:log"
import vk "vendor:vulkan"
import "../common"


create_descriptor_set_layout :: proc(descriptor_set_layout: ^vk.DescriptorSetLayout) -> (ok: bool) {
    using bound_state
    ubo_layout_binding: vk.DescriptorSetLayoutBinding = {
        binding = 0,
        descriptorType = .UNIFORM_BUFFER,
        descriptorCount = 1,
        stageFlags = {.VERTEX},
        pImmutableSamplers = nil,
    }

    layout_create_info: vk.DescriptorSetLayoutCreateInfo = {
        sType = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        bindingCount = 1,
        pBindings = &ubo_layout_binding,
    }
    
    res := vk.CreateDescriptorSetLayout(device, &layout_create_info, nil, descriptor_set_layout); if res != .SUCCESS {
        log.error("Error creating descriptor set layout:", res)
        return false
    }
    defer if !ok do destroy_descriptor_set_layout(descriptor_set_layout)

    return true

}

destroy_descriptor_set_layout :: proc(layout: ^vk.DescriptorSetLayout) {
    using bound_state
    vk.DestroyDescriptorSetLayout(device, layout^, nil)
}