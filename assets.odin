package callisto

import "base:intrinsics"
import "base:runtime"
import "core:container/queue"
import "core:math/linalg"
import "core:path/filepath"
import "core:strings"
import "common"
import "gpu"

Uuid          :: common.Uuid
uuid_generate :: common.uuid_generate

Reference :: struct($T: typeid) {
        runtime_id : int,
}

Bounds2D             :: common.Bounds2D
Bounds3D             :: common.Bounds3D

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
        // armature       : Construct,
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
        shader_pipeline : Reference(Shader_Pipeline),
        textures        : []Reference(Texture2D),
        // Non-serialized
        constants       : gpu.Buffer,
}

