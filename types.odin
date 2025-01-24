package callisto

import "core:mem"

import "common"
import "gpu"

Result             :: common.Result
Exit_Code          :: common.Exit_Code

Engine             :: common.Engine
Engine_Create_Info   :: common.Engine_Create_Info

Runner             :: common.Runner
Dll_Symbol_Table   :: common.Dll_Symbol_Table

Window                     :: common.Window
Window_Create_Info         :: common.Window_Create_Info
Window_Style_Flags         :: common.Window_Style_Flags
Window_Style_Flag          :: common.Window_Style_Flag
Window_Style_Flags_DEFAULT :: common.Window_Style_Flags_DEFAULT
Window_Position_AUTO       :: common.Window_Position_AUTO
Window_Size_AUTO           :: common.Window_Size_AUTO


Event                :: common.Event
Event_Behaviour      :: common.Event_Behaviour

Runner_Event         :: common.Runner_Event

Window_Event         :: common.Window_Event
Window_Moved         :: common.Window_Moved
Window_Resized       :: common.Window_Resized
Window_Resized_Type  :: common.Window_Resized_Type
Window_Opened        :: common.Window_Opened
Window_Close_Request :: common.Window_Close_Request
Window_Closed        :: common.Window_Closed
Window_Focus_Gained  :: common.Window_Focus_Gained
Window_Focus_Lost    :: common.Window_Focus_Lost

Input_Event          :: common.Input_Event
Input_Button         :: common.Input_Button
Input_Text           :: common.Input_Text
Input_Modifiers      :: common.Input_Modifiers
Input_Modifier       :: common.Input_Modifier
Input_Button_Motion  :: common.Input_Button_Motion
Input_Button_Source  :: common.Input_Button_Source
Input_Hand           :: common.Input_Hand
Input_Vector1        :: common.Input_Vector1
Input_Vector2        :: common.Input_Vector2
Input_Vector3        :: common.Input_Vector3
Bounds2D             :: common.Bounds2D
Bounds3D             :: common.Bounds3D

Reference :: struct($T: typeid) {
        asset_id   : Uuid,
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

