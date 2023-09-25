package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"
import "../asset"
import "../debug"

built_in: Built_In

init :: proc () -> (ok: bool) {
    debug.profile_scope()
    
    _impl_init() or_return
    defer if !ok do _impl_shutdown()

    _create_built_ins() or_return
    defer if !ok do _destroy_built_ins()

    return true
}

shutdown :: proc() {
    debug.profile_scope()

    _destroy_built_ins()
    _impl_shutdown()
}

wait_until_idle :: #force_inline proc() {
    _impl_wait_until_idle()
}

create_shader :: #force_inline proc(shader_description: ^Shader_Description, shader: ^Shader) -> (ok: bool) {
    return _impl_create_shader(shader_description, shader)
}

destroy_shader :: #force_inline proc(shader: Shader) {
    _impl_destroy_shader(shader)
}

create_material_instance :: proc {
    create_material_instance_from_shader,
    // create_material_instance_from_master,
    // create_material_instance_from_variant,
}

create_material_instance_from_shader :: #force_inline proc(shader: Shader, material_instance: ^Material_Instance) -> (ok: bool) {
    return _impl_create_material_instance_from_shader(shader, material_instance)
}

// create_material_instance_from_master :: proc() -> (ok: bool) {}
// create_material_instance_from_variant :: proc() -> (ok: bool) {}

destroy_material_instance :: #force_inline proc(material_instance: Material_Instance) {
    _impl_destroy_material_instance(material_instance)
}

upload_material_uniforms :: #force_inline proc(material_instance: Material_Instance, data: ^$T) {
    _impl_upload_material_uniforms(material_instance, data)
}

// create_vertex_buffer :: #force_inline proc(data: $T/[]$E, vertex_buffer: ^Vertex_Buffer) -> (ok: bool) {
//     return _impl_create_vertex_buffer(data, vertex_buffer)
// }

// destroy_vertex_buffer :: #force_inline proc(vertex_buffer: Vertex_Buffer) {
//     _impl_destroy_vertex_buffer(vertex_buffer)
// }

// create_index_buffer :: #force_inline proc(data: $T/[]$E, index_buffer: ^Index_Buffer) -> (ok: bool) 
//         where E == u16 || E == u32 {
//     return _impl_create_index_buffer(data, index_buffer)
// }

// destroy_index_buffer :: #force_inline proc(index_buffer: Index_Buffer) {
//     _impl_destroy_index_buffer(index_buffer)
// }

// Create a renderable copy of a mesh asset on the GPU. The mesh's vertex data is not readable/writeable.
// The source asset may be unloaded from CPU memory after instantiation.
create_static_mesh :: #force_inline proc(mesh_asset: ^asset.Mesh, mesh: ^Mesh) -> (ok: bool) {
    return _impl_create_static_mesh(mesh_asset, mesh)
}

destroy_static_mesh :: #force_inline proc(mesh: Mesh) {
    _impl_destroy_static_mesh(mesh)
}

create_texture :: #force_inline proc(texture_description: ^Texture_Description, texture: ^Texture) -> (ok: bool) {
    return _impl_create_texture(texture_description, texture) 
}

destroy_texture :: #force_inline proc(texture: Texture) {
    _impl_destroy_texture(texture)
}

set_material_instance_texture :: #force_inline proc(material_instance: Material_Instance, texture: Texture, texture_binding: Texture_Binding) {
    _impl_set_material_instance_texture(material_instance, texture, texture_binding)
}

// ==============================================================================

cmd_record :: #force_inline proc() {
    _impl_cmd_record()
}

cmd_begin_render_pass :: #force_inline proc() {
    _impl_cmd_begin_render_pass()
}

cmd_end_render_pass :: #force_inline proc() {
    _impl_cmd_end_render_pass()
}

// cmd_bind_shader :: #force_inline proc(shader: Shader) {
//     _impl_cmd_bind_shader(shader)
// }

cmd_bind_material_instance :: #force_inline proc(material_instance: Material_Instance) {
    _impl_cmd_bind_material_instance(material_instance)
}

cmd_draw :: #force_inline proc(mesh: Mesh) {
    _impl_cmd_draw(mesh)
}

cmd_present :: #force_inline proc() {
    _impl_cmd_present()
}

// =============

@(private)
_create_built_ins :: proc() -> (ok: bool) {
    white_texture_desc          := Texture_Description {image_path = "callisto/resources/textures/white.png"}
    black_texture_desc          := Texture_Description {image_path = "callisto/resources/textures/black.png"}
    transparent_texture_desc    := Texture_Description {image_path = "callisto/resources/textures/transparent.png"}
    create_texture(&white_texture_desc, &built_in.texture_white) or_return
    defer if !ok do destroy_texture(built_in.texture_white)
    create_texture(&black_texture_desc, &built_in.texture_black)
    defer if !ok do destroy_texture(built_in.texture_black)
    create_texture(&transparent_texture_desc, &built_in.texture_transparent)
    defer if !ok do destroy_texture(built_in.texture_transparent)

    return true
}

@(private)
_destroy_built_ins :: proc() {
    destroy_texture(built_in.texture_white)
    destroy_texture(built_in.texture_black)
    destroy_texture(built_in.texture_transparent)
}
