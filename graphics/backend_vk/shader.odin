package callisto_graphics_vulkan

import "../../common"
import vk "vendor:vulkan"

_gpu_resource_to_vk_descriptor_type_array := [common.Gpu_Resource_Type]vk.DescriptorType {
    .Storage_Image = .STORAGE_IMAGE,
}

_shader_stage_to_vk_shader_stage_array := [common.Shader_Stage_Flag]vk.ShaderStageFlag {
    .Vertex                  = .VERTEX,
    .Fragment                = .FRAGMENT,
    .Compute                 = .COMPUTE,
    .Tessellation_Control    = .TESSELLATION_CONTROL,
    .Tessellation_Evaluation = .TESSELLATION_EVALUATION,
    .Geometry                = .GEOMETRY,
    .Ray_Generation          = .RAYGEN_KHR,
    .Ray_Intersection        = .INTERSECTION_KHR,
    .Ray_Any_Hit             = .ANY_HIT_KHR,
    .Ray_Closest_Hit         = .CLOSEST_HIT_KHR,
    .Ray_Miss                = .MISS_KHR,
    .Ray_Callable            = .CALLABLE_KHR,
}


_to_vk_descriptor_type :: proc(resource_type: common.Gpu_Resource_Type) -> vk.DescriptorType {
    return _gpu_resource_to_vk_descriptor_type_array[resource_type]
}

_to_vk_shader_stage :: proc(shader_stage: common.Shader_Stage_Flag) -> vk.ShaderStageFlag {
    return _shader_stage_to_vk_shader_stage_array[shader_stage]
}


descriptor_set_layout_create :: proc(r: ^Renderer_Impl, stage: common.Shader_Stage_Flag, description: ^common.Gpu_Resource_Set) -> (layout: vk.DescriptorSetLayout, result: Result) {
    bindings := make([]vk.DescriptorSetLayoutBinding, len(description.bindings))
    defer delete(bindings)
    
    for binding, i in description.bindings {
        bindings[i] = {
            binding         = binding.binding,
            descriptorCount = 1,
            descriptorType  = _to_vk_descriptor_type(binding.resource_type),
            stageFlags      = { _to_vk_shader_stage(stage), },
        }
    }

    create_info := vk.DescriptorSetLayoutCreateInfo {
        sType        = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        // pNext     = pNext,
        pBindings    = raw_data(bindings),
        bindingCount = u32(len(bindings)),
        flags        = {}
    }

    vk_res := vk.CreateDescriptorSetLayout(r.device, &create_info, nil, &layout)
    check_result(vk_res) or_return

    return layout, .Ok
}


descriptor_allocator_create :: proc(r: ^Renderer_Impl, max_sets: u32, pool_ratios: []Pool_Size_Ratio) -> (desc_allocator: Descriptor_Allocator, res: Result) {
    pool_sizes := make([dynamic]vk.DescriptorPoolSize, len(pool_ratios))
    defer delete(pool_sizes)

    for ratio, i in pool_ratios {
        pool_sizes[i] = vk.DescriptorPoolSize {
            type = ratio.type,
            descriptorCount = u32(ratio.ratio * f32(max_sets)),
        }
    }

    pool_info := vk.DescriptorPoolCreateInfo {
        sType = .DESCRIPTOR_POOL_CREATE_INFO,
        flags = {},
        maxSets = max_sets,
        poolSizeCount = u32(len(pool_sizes)),
        pPoolSizes = raw_data(pool_sizes),
    }


    vk_res :=vk.CreateDescriptorPool(r.device, &pool_info, nil, &desc_allocator.pool)
    check_result(vk_res) or_return

    return desc_allocator, .Ok
}

descriptor_allocator_clear :: proc(r: ^Renderer_Impl, desc_allocator: ^Descriptor_Allocator) {
    vk.ResetDescriptorPool(r.device, desc_allocator.pool, {})
}

descriptor_allocator_destroy :: proc(r: ^Renderer_Impl, desc_allocator: ^Descriptor_Allocator) {
    vk.DestroyDescriptorPool(r.device, desc_allocator.pool, nil)
}

descriptor_allocator_allocate :: proc(r: ^Renderer_Impl, desc_allocator: ^Descriptor_Allocator, layout: vk.DescriptorSetLayout) -> (set: vk.DescriptorSet, res: Result) {
    layout := layout 

    alloc_info := vk.DescriptorSetAllocateInfo {
        sType = .DESCRIPTOR_SET_ALLOCATE_INFO,
        descriptorPool = desc_allocator.pool,
        descriptorSetCount = 1,
        pSetLayouts = &layout,
    }

    vk_res := vk.AllocateDescriptorSets(r.device, &alloc_info, &set)
    check_result(vk_res) or_return

    return set, .Ok
}
