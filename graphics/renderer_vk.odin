package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"
import "../asset"
import "../debug"
import "../platform"
import vkb "backend_vk"
import vk "vendor:vulkan"

when config.RENDERER_API == .Vulkan {
    Graphics_Context :: vkb.Graphics_Context
    cg_ctx: ^Graphics_Context

    bind_context :: proc(ctx: ^Graphics_Context) {
        cg_ctx = ctx
    }

    init :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
        vkb.create_instance(cg_ctx) or_return
        defer if !ok do vkb.destroy_instance(cg_ctx)

        // TODO: check if running headless in case we need to skip this
        vkb.create_surface(cg_ctx, window_ctx) or_return
        defer if !ok do vkb.destroy_surface(cg_ctx)

        vkb.select_physical_device(cg_ctx) or_return

        vkb.create_swapchain(cg_ctx) or_return
        defer if !ok do vkb.destroy_swapchain(cg_ctx)

        return true
    }

    shutdown :: proc(cg_ctx: ^Graphics_Context) {
        // wait until idle?
        vkb.destroy_surface(cg_ctx)
        vkb.destroy_instance(cg_ctx)
    }
    
    wait_until_idle :: proc() 

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
