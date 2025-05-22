package callisto

import "base:runtime"
import "core:math/linalg"
import sa "core:container/small_array"
import sdl "vendor:sdl3"
import "config"

MESH_RENDERER_PUSH_CAMERA :: 0
MESH_RENDERER_PUSH_MODEL :: 1

// The mesh render api handles 3D optimisation, depth sorting and material batching.
// - Create a command buffer
// - Start a pass, providing camera values and options
// - Add render commands
// - End the pass. This sorts the render commands and translates them to GPU draws.
// - Reuse the command buffer

// Iterate over mesh renderers and add commands to the command buffer

Mesh_Render_Command_Buffer :: struct {
        pass_info      : Mesh_Render_Pass_Info,
        bound_material : ^Material,
        buffer         : [dynamic]Mesh_Render_Command,
}

Mesh_Render_Command :: struct {
        index_buffer  : ^sdl.GPUBuffer,
        vertex_buffer : ^sdl.GPUBuffer,
        submesh       : ^Submesh,
        material      : ^Material,
        transform     : matrix[4,4]f32,
}

Mesh_Render_Options :: bit_set[Mesh_Render_Option]
Mesh_Render_Option :: enum {
        // Depth_Prepass,      // < Draw only to the depth buffer. Use this with large, opaque meshes.
        // Shadow_Map,
        // Sort_Front_To_Back, // < For opaque/alpha cutout
        // Sort_Back_To_Front, // < For transparent/alpha blended
}


Mesh_Render_Pass_Info :: struct {
        options              : Mesh_Render_Options,
        gpu_command_buffer   : ^sdl.GPUCommandBuffer,
        camera               : ^Camera,
        color_targets        : []sdl.GPUColorTargetInfo,
        depth_stencil_target : Maybe(sdl.GPUDepthStencilTargetInfo), // Optional
        sampler_anisotropic  : ^sdl.GPUSampler,
        sampler_trilinear    : ^sdl.GPUSampler,
}


mesh_render_command_buffer_create :: proc(allocator := context.allocator) -> (b: Mesh_Render_Command_Buffer, ok: bool) {
        err: runtime.Allocator_Error
        b.buffer, err = make([dynamic]Mesh_Render_Command, 4096, allocator)
        return 
}

mesh_render_command_buffer_destroy :: proc(b: ^Mesh_Render_Command_Buffer) {
        delete(b.buffer)
}

mesh_render_begin :: proc(b: ^Mesh_Render_Command_Buffer, info: ^Mesh_Render_Pass_Info) {
        b.pass_info = info^
        clear(&b.buffer)
}

mesh_render_end :: proc(b: ^Mesh_Render_Command_Buffer) {
        // TODO: perform sorting based on pass_info.
        // For now, draw everything in order.
       
        pass := sdl.BeginGPURenderPass(
                command_buffer            = b.pass_info.gpu_command_buffer,
                color_target_infos        = raw_data(b.pass_info.color_targets),
                num_color_targets         = u32(len(b.pass_info.color_targets)),
                depth_stencil_target_info = &b.pass_info.depth_stencil_target.? or_else nil
        )

        // Push camera uniforms for this pass
        camera_info := camera_get_uniform_data(b.pass_info.camera)
        sdl.PushGPUVertexUniformData(b.pass_info.gpu_command_buffer, 
                slot_index = MESH_RENDERER_PUSH_CAMERA,
                data       = &camera_info,
                length     = size_of(camera_info)
        )

        sampler_aniso     := b.pass_info.sampler_anisotropic
        sampler_trilinear := b.pass_info.sampler_trilinear

        // Depth prepass might use a different loop
        for &command in b.buffer {

                bind_pipeline := true
                bind_properties := true

                // Minimise GPU state change
                if b.bound_material != nil {
                        if b.bound_material == command.material {
                                // Share the same material
                                bind_pipeline   = false
                                bind_properties = false
                        } else if b.bound_material.pipeline == command.material.pipeline {
                                // Share the same shader but with different parameters
                                bind_pipeline = false
                        }
                }
                b.bound_material = command.material


                // Bind GPU resources if required
                if bind_pipeline {
                        sdl.BindGPUGraphicsPipeline(pass, command.material.pipeline)
                }

                if bind_properties {
                        if command.material.property_block_vertex != nil {
                                sdl.BindGPUVertexStorageBuffers(pass, 
                                        first_slot      = 0,
                                        storage_buffers = &command.material.property_block_vertex,
                                        num_bindings    = 1
                                )
                        }
                        if command.material.property_block_fragment != nil {
                                sdl.BindGPUFragmentStorageBuffers(pass,
                                        first_slot      = 0,
                                        storage_buffers = &command.material.property_block_fragment,
                                        num_bindings    = 1
                                )
                        }

                        ts_bindings: sa.Small_Array(config.MAX_TEXTURES, sdl.GPUTextureSamplerBinding)
                        
                        if command.material.textures_vertex.len > 0 {
                                for tex in sa.slice(&command.material.textures_vertex) {
                                        // Only use anisotropic filtering if it would make a difference
                                        sampler := sampler_aniso if tex.type in bit_set[Texture_Type]{.Color, .Normal} else sampler_trilinear

                                        binding := sdl.GPUTextureSamplerBinding {
                                                texture = tex.gpu_texture,
                                                sampler = sampler,
                                        }
                                        sa.append(&ts_bindings, binding)
                                }
                                sdl.BindGPUVertexSamplers(pass,
                                        first_slot               = 0,
                                        texture_sampler_bindings = &ts_bindings.data[0],
                                        num_bindings             = u32(ts_bindings.len)
                                )
                                sa.clear(&ts_bindings)
                        }
                        
                        if command.material.textures_fragment.len > 0 {
                                for tex in sa.slice(&command.material.textures_fragment) {
                                        // Only use anisotropic filtering if it would make a difference
                                        sampler := sampler_aniso if tex.type in bit_set[Texture_Type]{.Color, .Normal} else sampler_trilinear

                                        binding := sdl.GPUTextureSamplerBinding {
                                                texture = tex.gpu_texture,
                                                sampler = sampler,
                                        }
                                        sa.append(&ts_bindings, binding)
                                }
                                sdl.BindGPUFragmentSamplers(pass,
                                        first_slot               = 0,
                                        texture_sampler_bindings = &ts_bindings.data[0],
                                        num_bindings             = u32(ts_bindings.len)
                                )
                        }
                }

              
                // Bind vertex buffers
                bindings: sa.Small_Array(len(Vertex_Attribute_Slot), sdl.GPUBufferBinding)
                for input in command.material.vertex_input {
                        desc := sdl.GPUBufferBinding {
                                buffer = command.vertex_buffer,
                                offset = command.submesh.vertex_buffer_offsets[input],
                        }
                        sa.append(&bindings, desc)
                }

                sdl.BindGPUVertexBuffers(pass,
                        first_slot   = 0,
                        bindings     = &bindings.data[0],
                        num_bindings = u32(bindings.len)
                )


                // Bind index buffer
                index_binding := sdl.GPUBufferBinding {
                        buffer = command.index_buffer,
                        offset = command.submesh.index_buffer_offset,
                }

                index_size := sdl.GPUIndexElementSize._16BIT if .U32_Indices not_in command.submesh.flags else ._32BIT

                sdl.BindGPUIndexBuffer(pass,
                        binding = index_binding,
                        index_element_size = index_size
                )

                // Push model uniforms
                sdl.PushGPUVertexUniformData(b.pass_info.gpu_command_buffer, 
                        slot_index = MESH_RENDERER_PUSH_MODEL,
                        data       = &command.transform,
                        length     = size_of(command.transform)
                )

                // Draw
                sdl.DrawGPUIndexedPrimitives(pass,
                        num_indices = command.submesh.index_buffer_len,
                        num_instances = 1,
                        first_index = 0,
                        vertex_offset = 0,
                        first_instance = 0
                )
        }

        sdl.EndGPURenderPass(pass)

        b.pass_info = {}
        b.bound_material = nil
}


mesh_render :: proc {
        mesh_render_matrix,
        mesh_render_trs,
}


mesh_render_trs :: proc(b: ^Mesh_Render_Command_Buffer, renderer: ^Mesh_Renderer, t: [3]f32, r: quaternion128 = linalg.QUATERNIONF32_IDENTITY, s: [3]f32 = {1,1,1}) {
        for &submesh, i in renderer.mesh.submeshes {
                command := Mesh_Render_Command {
                        index_buffer  = renderer.mesh.index_buffer,
                        vertex_buffer = renderer.mesh.vertex_buffer,
                        submesh       = &submesh,
                        material      = sa.slice(&renderer.materials)[i],
                        transform     = linalg.matrix4_from_trs_f32(t, r, s),
                }
                append(&b.buffer, command)
        }
}


mesh_render_matrix :: proc(b: ^Mesh_Render_Command_Buffer, renderer: ^Mesh_Renderer, transform: matrix[4,4]f32) {
        for &submesh, i in renderer.mesh.submeshes {
                command := Mesh_Render_Command {
                        index_buffer  = renderer.mesh.index_buffer,
                        vertex_buffer = renderer.mesh.vertex_buffer,
                        submesh       = &submesh,
                        material      = sa.slice(&renderer.materials)[i],
                        transform     = transform,
                }
                append(&b.buffer, command)
        }
}
