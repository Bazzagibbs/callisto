package callisto_renderer

import "core:log"
import "../config"
import cg "../graphics"
when config.RENDERER_API == .Vulkan {
    import impl "vulkan"
}

init :: proc () -> (ok: bool) {
    return impl.init()
}

shutdown :: proc() {
    impl.shutdown()
}


create_shader :: proc(shader_description: ^cg.Shader_Description, shader: ^cg.Shader) -> (ok: bool) {
    return impl.create_shader(shader_description, shader)
}

destroy_shader :: proc(shader: ^cg.Shader) {
    impl.destroy_shader(shader)
}

create_vertex_buffer :: proc(data: []$T, vertex_buffer: ^cg.Vertex_Buffer) -> (ok: bool) {
    return impl.create_vertex_buffer(&impl.state, data, vertex_buffer)
}

destroy_vertex_buffer :: proc(vertex_buffer: ^cg.Vertex_Buffer) {
    impl.destroy_vertex_buffer(&impl.state, vertex_buffer)
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

cmd_bind_shader :: proc(shader: ^cg.Shader) {
    impl.cmd_bind_shader(shader)
}

cmd_bind_buffer :: proc(buffer: ^cg.Vertex_Buffer) {
    impl.cmd_bind_buffer(buffer)
}

cmd_present :: proc() {
    impl.cmd_present()
}