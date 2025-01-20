package callisto

import "core:encoding/uuid"
import "core:math/linalg"
import "common"
import "gpu"

Reference :: struct($T: typeid) {
        uuid       : uuid.Identifier,
        // Non-serialized
        runtime_id : int,
}

Mesh_Flags :: bit_set[Mesh_Flag]
Mesh_Flag :: enum {
        // Enable_Armature,
        // Enable_Blend_Shapes,
}

Mesh :: struct {
        submeshes : []Submesh,
        bounds    : Bounds3D,
        flags     : Mesh_Flags,
}

Submesh :: struct {
        attributes     : gpu.Vertex_Attribute_Flags,
        vertex_buffers : [gpu.Vertex_Attribute_Flag][]u8,
        index_buffer   : []u8,
        armature       : Construct,
        // blend_shapes : []Blend_Shape,
}

Shader_Pipeline :: struct {
        vertex_shader   : gpu.Vertex_Shader,
        fragment_shader : gpu.Fragment_Shader,
}

Texture_Flags :: bit_set[Texture_Flag]
Texture_Flag :: enum {
        Cpu_Readable,
}

Texture2D :: struct {
        // data: ,
        flags: Texture_Flags,
        // Non-serialized
        gpu_texture: gpu.Texture2D,
}

Material :: struct {
        shader_pipeline: Reference(Shader_Pipeline),
        textures: []Reference(Texture2D),
        // constants: 
}

Mesh_Renderer :: struct {
        mesh            : Reference(Mesh),
        materials       : []Reference(Material), // len == len(mesh.submeshes)
        transform_index : i32,
}

Attachment :: union {
        Mesh_Renderer,
        // Collider,
        // Hardpoint, // Allows other constructs to be attached to a transform within this construct
}


Construct :: struct {
        transforms     : []Transform,
        attachments    : []Attachment, // Attachments aren't "components" - they describe another asset's reference to a transform in this construct.
        // Non-serialized
        local_matrices : []matrix[4,4]f32,
        world_matrices : []matrix[4,4]f32,
}

Transform_Flags :: bit_set[Transform_Flag]
Transform_Flag :: enum {
        Dirty, // When a transform is modified, its matrix and all children are invalidated. They will be recomputed just before they are drawn.
}

Transform :: struct {
        name           : string,
        parent_index   : i32, // -1 when this is root node
        child_index    : i32,
        child_count    : i32, // 0 when this is a leaf node
        flags          : Transform_Flags,
        local_position : [3]f32,
        local_rotation : quaternion128,
        local_scale    : [3]f32,
}


// When a transform within this construct is modified, it is marked as 'dirty' as well as all its children and must be recalculated.
construct_resolve :: proc(c: ^Construct) {
        for &t, i in c.transforms {
                if .Dirty not_in t.flags {
                        continue
                }

                t.flags -= {.Dirty}

                c.local_matrices[i] = linalg.matrix4_from_trs_f32(t.local_position, t.local_rotation, t.local_scale)
                if t.parent_index == -1 {
                        c.world_matrices[i] = c.local_matrices[i]
                } else {
                        c.world_matrices[i] = c.world_matrices[t.parent_index] * c.local_matrices[i]
                }
        }
}

