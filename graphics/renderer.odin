package callisto_graphics

import "core:log"
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

create_vertex_buffer :: proc(data: []$T, vertex_buffer: ^Vertex_Buffer) -> (ok: bool) {
    return impl.create_vertex_buffer(data, vertex_buffer)
}

destroy_vertex_buffer :: proc(vertex_buffer: Vertex_Buffer) {
    impl.destroy_vertex_buffer(vertex_buffer)
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

cmd_draw :: proc(buffer: Vertex_Buffer) {
    impl.cmd_draw(buffer)
}

cmd_present :: proc() {
    impl.cmd_present()
}