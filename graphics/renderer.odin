package callisto_graphics

import "core:log"
import "core:intrinsics"
import "common"
import "../config"

when config.RENDERER_API == .Vulkan {
    import impl "vulkan"
}

built_in: Built_In

init :: proc () -> (ok: bool) {
    impl.init() or_return
    defer if !ok do impl.shutdown()

    _create_built_ins() or_return
    defer if !ok do _destroy_built_ins()

    return true
}

shutdown :: proc() {
    _destroy_built_ins()
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

create_texture :: #force_inline proc(texture_description: ^Texture_Description, texture: ^Texture) -> (ok: bool) {
    return impl.create_texture(texture_description, texture) 
}

destroy_texture :: #force_inline proc(texture: Texture) {
    impl.destroy_texture(texture)
}

// ==============================================================================

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

// =============

_create_built_ins :: proc() -> (ok: bool) {
    common.built_in = &built_in

    white_texture_desc          := Texture_Description {image_path = "callisto/assets/textures/white.png"}
    black_texture_desc          := Texture_Description {image_path = "callisto/assets/textures/black.png"}
    transparent_texture_desc    := Texture_Description {image_path = "callisto/assets/textures/transparent.png"}
    create_texture(&white_texture_desc, &built_in.texture_white) or_return
    defer if !ok do destroy_texture(built_in.texture_white)
    create_texture(&black_texture_desc, &built_in.texture_black)
    defer if !ok do destroy_texture(built_in.texture_black)
    create_texture(&transparent_texture_desc, &built_in.texture_transparent)
    defer if !ok do destroy_texture(built_in.texture_transparent)

    return true
}

_destroy_built_ins :: proc() {
    destroy_texture(built_in.texture_white)
    destroy_texture(built_in.texture_black)
    destroy_texture(built_in.texture_transparent)
}
