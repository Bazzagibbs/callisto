package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"

when config.RENDERER_API == .Vulkan {
    import impl "vulkan"
}


init :: proc () -> (ok: bool) {
    return impl.init()
}

shutdown :: proc() {
    impl.shutdown()
}

create_shader :: proc(shader_description: ^Shader_Description, shader: ^Shader) -> (ok: bool) {
    return impl.create_shader(shader_description, shader)
}

destroy_shader :: proc(shader: Shader) {
    impl.destroy_shader(shader)
}

create_vertex_buffer :: proc(data: $T/[]$E, vertex_buffer: ^Vertex_Buffer) -> (ok: bool) {
    return impl.create_vertex_buffer(data, vertex_buffer)
}

destroy_vertex_buffer :: proc(vertex_buffer: Vertex_Buffer) {
    impl.destroy_vertex_buffer(vertex_buffer)
}

create_index_buffer :: proc(data: $T/[]$E, index_buffer: ^Index_Buffer) -> (ok: bool) 
        where E == u16 || E == u32 {
    return impl.create_index_buffer(data, index_buffer)
}

destroy_index_buffer :: proc(index_buffer: Index_Buffer) {
    impl.destroy_index_buffer(index_buffer)
}

create_mesh :: proc(vertices: $U/[]$V, indices: $X/[]$Y, mesh: ^Mesh) -> (ok: bool)
        where Y == u16 || Y == u32 {
    return impl.create_mesh(vertices, indices, mesh)
}

destroy_mesh :: proc(mesh: Mesh) {
    impl.destroy_mesh(mesh)
}

cmd_record :: proc() {
    impl.cmd_record()
}

cmd_begin_render_pass :: proc() {
    impl.cmd_begin_render_pass()
}

cmd_end_render_pass :: proc() {
    impl.cmd_end_render_pass()
}

cmd_bind_shader :: proc(shader: Shader) {
    impl.cmd_bind_shader(shader)
}

cmd_draw :: proc(mesh: Mesh) {
    impl.cmd_draw(mesh)
}

cmd_present :: proc() {
    impl.cmd_present()
}