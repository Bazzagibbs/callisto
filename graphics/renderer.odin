package callisto_graphics

import "core:log"
import "core:intrinsics"
import "../config"
import "../asset"
import "../debug"
import "renderer_vulkan"

when config.RENDERER_API == .Vulkan {
    Renderer_Context :: renderer_vulkan.Renderer_Context
} else {
    Renderer_Context :: rawptr
    _ :: renderer_vulkan // suppress vet unused imports
}

// Common API for all renderer backends

init :: proc(ctx: ^Renderer_Context) -> (ok: bool) 

shutdown :: proc(ctx: ^Renderer_Context)

wait_until_idle :: proc(ctx: ^Renderer_Context) 

create_shader :: proc(ctx: ^Renderer_Context, shader_description: ^Shader_Description) -> (shader: Shader, ok: bool)

destroy_shader :: proc(ctx: ^Renderer_Context, shader: Shader) 

create_material_from_shader :: proc(ctx: ^Renderer_Context, shader: Shader) -> (material: Material, ok: bool)

destroy_material :: proc(ctx: ^Renderer_Context, material: Material)

create_static_mesh :: proc(ctx: ^Renderer_Context, mesh_asset: ^asset.Mesh) -> (mesh: Mesh, ok: bool)

destroy_static_mesh :: proc(ctx: ^Renderer_Context, mesh: Mesh) 

create_texture :: proc(ctx: ^Renderer_Context, texture_asset: ^asset.Texture) -> (texture: ^Texture, ok: bool)

destroy_texture :: proc(ctx: ^Renderer_Context, texture: Texture) 

// ==============================================================================

cmd_record :: proc(ctx: ^Renderer_Context) 
cmd_submit :: proc(ctx: ^Renderer_Context)

cmd_begin_render_pass :: proc(ctx: ^Renderer_Context) 
cmd_end_render_pass :: proc(ctx: ^Renderer_Context) 

cmd_bind_uniforms_scene :: proc(ctx: ^Renderer_Context)
cmd_bind_uniforms_pass :: proc(ctx: ^Renderer_Context)
cmd_bind_uniforms_material :: proc(ctx: ^Renderer_Context, material: Material) 
cmd_bind_uniforms_model :: proc(ctx: ^Renderer_Context)

cmd_draw :: proc(ctx: ^Renderer_Context, mesh: Mesh) 

cmd_present :: proc(ctx: ^Renderer_Context)

// Also need some commands for compute and upload

