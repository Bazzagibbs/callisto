package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"

when config.RENDERER_API == .Vulkan {
    import impl "vulkan"
}


init :: #force_inline proc () -> (ok: bool) {
    return impl.init()
}

shutdown :: #force_inline proc() {
    impl.shutdown()
}

create_shader :: #force_inline proc(shader_description: ^Shader_Description, shader: ^Shader) -> (ok: bool) {
    return impl.create_shader(shader_description, shader)
}

destroy_shader :: #force_inline proc(shader: Shader) {
    impl.destroy_shader(shader)
}

create_material_instance :: proc {
    create_material_instance_from_shader,
    // create_material_instance_from_master,
    // create_material_instance_from_variant,
}

create_material_instance_from_shader :: #force_inline proc(shader: Shader, material_instance: ^Material_Instance) -> (ok: bool) {
    return impl.create_material_instance_from_shader(shader, material_instance)
}

// create_material_instance_from_master :: proc() -> (ok: bool) {}
// create_material_instance_from_variant :: proc() -> (ok: bool) {}

destroy_material_instance :: #force_inline proc(material_instance: Material_Instance) {
    impl.destroy_material_instance(material_instance)
}

upload_material_uniforms :: #force_inline proc(material_instance: Material_Instance, data: ^$T) {
    impl.upload_material_uniforms(material_instance, data)
}

create_vertex_buffer :: #force_inline proc(data: $T/[]$E, vertex_buffer: ^Vertex_Buffer) -> (ok: bool) {
    return impl.create_vertex_buffer(data, vertex_buffer)
}

destroy_vertex_buffer :: #force_inline proc(vertex_buffer: Vertex_Buffer) {
    impl.destroy_vertex_buffer(vertex_buffer)
}

create_index_buffer :: #force_inline proc(data: $T/[]$E, index_buffer: ^Index_Buffer) -> (ok: bool) 
        where E == u16 || E == u32 {
    return impl.create_index_buffer(data, index_buffer)
}

destroy_index_buffer :: #force_inline proc(index_buffer: Index_Buffer) {
    impl.destroy_index_buffer(index_buffer)
}

create_mesh :: #force_inline proc(vertices: $U/[]$V, indices: $X/[]$Y, mesh: ^Mesh) -> (ok: bool)
        where Y == u16 || Y == u32 {
    return impl.create_mesh(vertices, indices, mesh)
}

destroy_mesh :: #force_inline proc(mesh: Mesh) {
    impl.destroy_mesh(mesh)
}

cmd_record :: #force_inline proc() {
    impl.cmd_record()
}

cmd_begin_render_pass :: #force_inline proc() {
    impl.cmd_begin_render_pass()
}

cmd_end_render_pass :: #force_inline proc() {
    impl.cmd_end_render_pass()
}

// cmd_bind_shader :: proc(shader: Shader) {
//     impl.cmd_bind_shader(shader)
// }

cmd_bind_material_instance :: #force_inline proc(material_instance: Material_Instance) {
    impl.cmd_bind_material_instance(material_instance)
}

cmd_draw :: #force_inline proc(mesh: Mesh) {
    impl.cmd_draw(mesh)
}

cmd_present :: #force_inline proc() {
    impl.cmd_present()
}