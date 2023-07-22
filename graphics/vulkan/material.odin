package callisto_graphics_vulkan

import "core:log"
import vk "vendor:vulkan"
import "core:mem"
import "../common"
import "../../config"

create_material_instance :: proc {
    create_material_instance_from_shader,
    // create_material_instance_from_master,
    // create_material_instance_from_variant,
}

create_material_instance_from_shader :: proc(shader: common.Shader, material_instance: ^common.Material_Instance) -> (ok: bool) {
    using bound_state
    cvk_mat_instance, err := new(CVK_Material_Instance); if err != .None {
        log.error("Failed to create material instance:", err)
        return false
    }
    defer if !ok do free(cvk_mat_instance)
    
    cvk_shader := transmute(^CVK_Shader)shader
    uniform_buffer_data_size := size_of(cvk_shader.uniform_buffer_typeid)
    cvk_mat_instance.uniform_buffer_data, err = mem.alloc(uniform_buffer_data_size); if err != .None {
        log.error("Failed to create material instance:", err)
        return false
    }
    defer if !ok do mem.free_with_size(cvk_mat_instance.uniform_buffer_data, uniform_buffer_data_size)

    create_material_uniform_buffers(cvk_shader.uniform_buffer_typeid, cvk_mat_instance) or_return
    
    material_instance^ = transmute(common.Material_Instance)cvk_shader
    defer if !ok do destroy_material_instance(material_instance^)
    
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
    for buf in cvk_mat_instance.uniform_buffers {
        vk.DestroyBuffer(device, buf.buffer, nil)
    }
    delete(cvk_mat_instance.uniform_buffers_mapped)
    delete(cvk_mat_instance.uniform_buffers)
    uniform_buffer_data_size := size_of(cvk_mat_instance.shader.uniform_buffer_typeid)
    mem.free_with_size(cvk_mat_instance.uniform_buffer_data, uniform_buffer_data_size)
    free(material_instance)
}


upload_material_uniforms :: proc(material_instance: common.Material_Instance, data: ^$T) {
    cvk_mat_instance := transmute(^CVK_Material_Instance)material_instance
    assert(cvk_mat_instance.shader.uniform_buffer_typeid == T) // TODO: compile time check?

    // Copy data into uniform_buffer_data
}
