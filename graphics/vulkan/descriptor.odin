package callisto_graphics_vulkan

import "core:log"
import vk "vendor:vulkan"
import "../common"
import "../../config"



create_descriptor_pool :: proc(descriptor_pool: ^vk.DescriptorPool) -> (ok: bool) {
    // using bound_state // shadows descriptor_pool parameter

    pool_sizes := [] vk.DescriptorPoolSize {
        {   
            type            = .UNIFORM_BUFFER,
            descriptorCount = u32(config.RENDERER_FRAMES_IN_FLIGHT),
        }, 
        {   
            type            = .COMBINED_IMAGE_SAMPLER,
            descriptorCount = u32(config.RENDERER_FRAMES_IN_FLIGHT),
        }, 
    }

    descriptor_pool_create_info := vk.DescriptorPoolCreateInfo {
        sType           = .DESCRIPTOR_POOL_CREATE_INFO,
        poolSizeCount   = u32(len(pool_sizes)),
        pPoolSizes      = raw_data(pool_sizes),
        maxSets         = u32(config.RENDERER_FRAMES_IN_FLIGHT * 2),
    }

    res := vk.CreateDescriptorPool(bound_state.device, &descriptor_pool_create_info, nil, descriptor_pool); if res != .SUCCESS {
        log.error("Failed to create descriptor pool:", res)
        return false
    }

    return true
}

create_descriptor_set_layout :: proc(descriptor_set_layout: ^vk.DescriptorSetLayout) -> (ok: bool) {
    using bound_state

    ubo_layout_binding := vk.DescriptorSetLayoutBinding {
        binding = 0,
        descriptorType = .UNIFORM_BUFFER,
        descriptorCount = 1,
        stageFlags = {.VERTEX},
        pImmutableSamplers = nil,
    }

    sampler_layout_binding :=  vk.DescriptorSetLayoutBinding {
        binding = 1,
        descriptorType = .COMBINED_IMAGE_SAMPLER,
        descriptorCount = 1,
        pImmutableSamplers = nil,
        stageFlags = {.FRAGMENT},
    }

    bindings := []vk.DescriptorSetLayoutBinding {
        ubo_layout_binding,
        sampler_layout_binding,
    }

    layout_create_info: vk.DescriptorSetLayoutCreateInfo = {
        sType = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        bindingCount = u32(len(bindings)),
        pBindings = raw_data(bindings),
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

// Handles do not need to be destroyed, automatically freed when corresponding descriptor pool is destroyed
allocate_descriptor_sets :: proc(descriptor_pool: vk.DescriptorPool, descriptor_set_layout: vk.DescriptorSetLayout, descriptor_sets: ^[dynamic]vk.DescriptorSet) -> (ok: bool) {
    using bound_state
    resize(descriptor_sets, config.RENDERER_FRAMES_IN_FLIGHT)
   
    descriptor_set_layouts := make([]vk.DescriptorSetLayout, config.RENDERER_FRAMES_IN_FLIGHT)
    defer delete(descriptor_set_layouts)
    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        descriptor_set_layouts[i] = descriptor_set_layout
    }

    descriptor_set_alloc_info := vk.DescriptorSetAllocateInfo {
        sType = .DESCRIPTOR_SET_ALLOCATE_INFO,
        descriptorPool = descriptor_pool,
        descriptorSetCount = u32(config.RENDERER_FRAMES_IN_FLIGHT),
        pSetLayouts = raw_data(descriptor_set_layouts),
    }


    res := vk.AllocateDescriptorSets(device, &descriptor_set_alloc_info, raw_data(descriptor_sets^)); if res != .SUCCESS {
        log.error("Failed to allocate descriptor sets:", res)
        return false
    }

    return true
}

