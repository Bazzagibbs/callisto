package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"
import "../asset"
import "../debug"
import vkb "backend_vk"

when config.RENDERER_API == .Vulkan {
    Graphics_Context :: vkb.Graphics_Context
    cg_ctx: ^Graphics_Context

    bind_context :: proc(ctx: ^Graphics_Context) {
        cg_ctx = ctx
    }

    init :: proc(graphics_ctx: ^Graphics_Context) -> (ok: bool) {
        // vkb.create_instance
        return true
    }

    shutdown :: proc(graphics_ctx: ^Graphics_Context) {
    }
    
    wait_until_idle :: proc() {
    }

    create_shader :: proc(shader_description: ^Shader_Description) -> (shader: Shader, ok: bool)

    destroy_shader :: proc(shader: Shader) 

    create_material_from_shader :: proc(shader: Shader) -> (material: Material, ok: bool)

    destroy_material :: proc(material: Material)

    create_static_mesh :: proc(mesh_asset: ^asset.Mesh) -> (mesh: Mesh, ok: bool)

    destroy_static_mesh :: proc(mesh: Mesh) 

    create_texture :: proc(texture_asset: ^asset.Texture) -> (texture: ^Texture, ok: bool)

    destroy_texture :: proc(texture: Texture) 

    // ==============================================================================

    cmd_record :: proc() 
    cmd_submit :: proc()

    cmd_begin_render_pass :: proc() 
    cmd_end_render_pass :: proc() 

    cmd_bind_uniforms_scene :: proc()
    cmd_bind_uniforms_pass :: proc()
    cmd_bind_uniforms_material :: proc(material: Material) 
    cmd_bind_uniforms_model :: proc()

    cmd_draw :: proc(mesh: Mesh) 

    cmd_present :: proc()

    // Also need some commands for compute and upload
}
