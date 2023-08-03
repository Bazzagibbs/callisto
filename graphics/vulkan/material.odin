package callisto_graphics_vulkan

import "core:log"
import "core:mem"
import "core:runtime"
import vk "vendor:vulkan"
import "../common"
import "../../config"

create_material_instance :: proc {
    create_material_instance_from_shader,
    // create_material_instance_from_master,
    // create_material_instance_from_variant,
}

create_material_instance_from_shader :: proc(shader: common.Shader, material_instance: ^common.Material_Instance) -> (ok: bool) {  
    using bound_state
    // Get typeid from shader
    cvk_mat_instance, err := new(CVK_Material_Instance); if err != .None {
        log.error("Failed to create material instance:", err)
        return false
    }
    defer if !ok do free(cvk_mat_instance)
    
    cvk_shader := transmute(^CVK_Shader)shader
    cvk_mat_instance.shader = cvk_shader

    cvk_white_tex := transmute(^CVK_Texture)common.built_in.texture_white

    create_material_uniform_buffers(cvk_shader.uniform_buffer_typeid, cvk_mat_instance) or_return
    
    allocate_descriptor_sets(descriptor_pool, cvk_shader.descriptor_set_layout, &cvk_mat_instance.descriptor_sets) or_return

    for desc_set, i in cvk_mat_instance.descriptor_sets {
        descriptor_buffer_info: vk.DescriptorBufferInfo = {
            buffer = cvk_mat_instance.uniform_buffers[i].buffer,
            offset = 0,
            range = vk.DeviceSize(cvk_mat_instance.uniform_buffers[i].size),
        }

        descriptor_image_info := vk.DescriptorImageInfo {
            imageLayout = .SHADER_READ_ONLY_OPTIMAL,
            imageView = cvk_white_tex.image_view,
            sampler = texture_sampler_default,
        }

        write_descriptor_sets := [] vk.WriteDescriptorSet {
            {
                sType = .WRITE_DESCRIPTOR_SET,
                dstSet = desc_set,
                dstBinding = 0,
                dstArrayElement = 0,
                descriptorType = .UNIFORM_BUFFER,
                descriptorCount = 1,
                pBufferInfo = &descriptor_buffer_info,
            },
            {
                sType = .WRITE_DESCRIPTOR_SET,
                dstSet = desc_set,
                dstBinding = 1,
                dstArrayElement = 0,
                descriptorType = .COMBINED_IMAGE_SAMPLER,
                descriptorCount = 1,
                pImageInfo = &descriptor_image_info,
            },
        }

        vk.UpdateDescriptorSets(device, u32(len(write_descriptor_sets)), raw_data(write_descriptor_sets), 0, nil)
    }

    material_instance^ = transmute(common.Material_Instance)cvk_mat_instance
    return true
}

// create_material_instance_from_master :: proc(master: common.Material_Master, instance: ^common.Material_Instance) -> (ok: bool) {

// }

// create_material_instance_from_variant :: proc(variant: common.Material_Variant, instance: ^common.Material_Instance) -> (ok: bool) {

// }

destroy_material_instance :: proc(material_instance: common.Material_Instance) {
    using bound_state
    destroy_material_uniform_buffers(material_instance)
    cvk_mat_instance := transmute(^CVK_Material_Instance)material_instance
    // for buf in cvk_mat_instance.uniform_buffers {
    //     vk.DestroyBuffer(device, buf.buffer, nil)
    // }
    delete(cvk_mat_instance.uniform_buffers_mapped)
    delete(cvk_mat_instance.uniform_buffers)
    delete(cvk_mat_instance.descriptor_sets)
    free(material_instance)
}


upload_material_uniforms :: proc(material_instance: common.Material_Instance, data: ^$T) {
    using bound_state
    cvk_mat_instance := transmute(^CVK_Material_Instance)material_instance
    
    // TODO: replace with compile-time check
    assert(cvk_mat_instance.shader.uniform_buffer_typeid == typeid_of(T), "Material uniform buffer upload error: type mismatch")
    
    mapped_buffer := cvk_mat_instance.uniform_buffers_mapped[flight_frame]
    uniform_buffer_data_size := int(cvk_mat_instance.uniform_buffers[flight_frame].size)

    mem.copy(mapped_buffer, data, uniform_buffer_data_size)
}
