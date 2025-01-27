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

Asset_Database :: struct {
        runtime_data : map[Uuid]Asset_Runtime_Data,
        meshes : Asset_List(Mesh)
}

Asset_Runtime_Data :: struct {
        runtime_id : int,
        refcount   : int,
}

// A list of assets 
Asset_List :: struct($T: typeid) {
        entries    : [dynamic]Asset_List_Entry(T), // TODO: chunked?
        free_queue : queue.Queue(int), // All indices in `entries` to be reused before allocating more indices.
        allocator  : runtime.Allocator,
}

Asset_List_Entry :: struct($T: typeid) {
        data: T,
        tombstone : bool, // if true, this entry has been freed and may be reused.
}

asset_list_create :: proc($T: typeid, capacity: int = -1, allocator := context.allocator) -> (list: Asset_List(T), res: Result) {
        list: Asset_List
        err: runtime.Allocator_Error

        list.allocator = allocator
        if capacity < 0 {
                list.entries, err = make([dynamic]Asset_List_Entry(T), len = capacity, allocator = allocator)
                check_result(err) or_return
        }
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
        shader_pipeline : Reference(Shader_Pipeline),
        textures        : []Reference(Texture2D),
        // Non-serialized
        constants       : gpu.Buffer,
}

Mesh_Renderer :: struct {
        mesh            : Reference(Mesh),
        materials       : []Reference(Material), // len == len(mesh.submeshes)
        construct       : Reference(Construct),
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


// On reload this will be reacquired.
@(private) 
_exe_dir_buffer : [4096]byte // Linux length, windows is ~256
@(private)
_exe_dir : string

get_asset_path :: proc(filename: string, allocator := context.allocator) -> string {
        if _exe_dir == {} {
                sb := strings.builder_from_bytes(_exe_dir_buffer[:])
                strings.write_string(&sb, get_exe_directory(context.temp_allocator))
                _exe_dir = strings.to_string(sb)
        }
        
        return filepath.join({_exe_dir, "data", "assets", filename}, allocator)
}

// Convert a Reference into a struct pointer of an element in `collection`.
reference_resolve :: proc(collection: ^$A, ref: $R/Reference($T)) -> ^T 
                where intrinsics.type_is_indexable(A) && intrinsics.type_elem_type(A) == T
        {

        return &collection[ref.runtime_id]
}

// When a transform within this construct is modified, it is marked as 'dirty' as well as all its children and must be recalculated.
construct_recalculate_matrices :: proc(c: ^Construct) -> (changed: bool) {
        changed = false

        for &t, i in c.transforms {
                if .Dirty not_in t.flags {
                        continue
                }

                c.local_matrices[i] = linalg.matrix4_from_trs_f32(t.local_position, t.local_rotation, t.local_scale)
                if t.parent_index == -1 {
                        c.world_matrices[i] = c.local_matrices[i]
                } else {
                        c.world_matrices[i] = c.world_matrices[t.parent_index] * c.local_matrices[i]
                }
                t.flags -= {.Dirty}
                changed = true
        }

        return changed
}

