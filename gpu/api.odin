package callisto_gpu

import "base:runtime"
import "../common"
import "../config"

RHI :: config.RHI

FRAMES_IN_FLIGHT :: 3

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

Rect :: struct {
        x, y          : int,
        width, height : int,
}

Device_Init_Info :: struct {
        runner            : ^Runner,
        required_features : Required_Device_Features,
}

Required_Device_Features :: bit_set[Required_Device_Feature]
Required_Device_Feature :: enum {}

Swapchain_Init_Info :: struct {
        window                        : Window,
        vsync                         : Vsync_Mode,
        force_draw_occluded_fragments : bool, // When part of the window is covered
        // stereo : bool, // FEATURE(Stereo rendering)
        // hdr    : bool, // FEATURE(HDR surface)
}

Vsync_Modes :: bit_set[Vsync_Mode]
Vsync_Mode :: enum {
        Double_Buffered, // Guaranteed to be supported on every device
        Triple_Buffered,
        Off,
}

// Nothing to configure currently
Semaphore_Init_Info :: struct {}

Fence_Init_Info :: struct {
        begin_signaled : bool,
}

Command_Buffer_Init_Info :: struct {
        queue            : Queue_Flag,
        wait_semaphore   : ^Semaphore,
        signal_semaphore : ^Semaphore,
        signal_fence     : ^Fence,
}

Queue_Flags :: bit_set[Queue_Flag]
Queue_Flag :: enum {
        Graphics,
        Compute_Sync = Graphics,
        Compute_Async,
}


Pipeline_Stages :: bit_set[Pipeline_Stage]
Pipeline_Stage :: enum {
        Draw_Indirect,
        Vertex_Input,
        Vertex_Shader,
        Tessellation_Control_Shader,
        Tessellation_Evaluation_Shader,
        Geometry_Shader,
        Fragment_Shader,
        Fragment_Early_Tests,
        Fragment_Late_Tests,
        Color_Target_Output,
        Compute_Shader,
        Transfer,
        Host,
        Copy,
        Resolve,
        Blit,
        Clear,
        Pre_Rasterization_Shaders,
        All_Transfer,
        All_Graphics,
        All_Commands,
        // Task_Shader, // FEATURE(Mesh shading)
        // Mesh_Shader,
        // Acceleration_Structure_Copy, // FEATURE(Ray tracing)
}


Shader_Stages :: bit_set[Shader_Stage]
Shader_Stage :: enum {
        // Graphics
        Vertex,
        Tessellation_Control,
        Tessellation_Evaluation,
        Geometry,
        Fragment,
        // Compute
        Compute,
        // // Ray tracing // FEATURE(Ray tracing)
        // Ray_Generation,
        // Any_Hit,
        // Closest_Hit,
        // Miss,
        // Intersection,
        // Callable,
        // // Mesh // FEATURE(Mesh shaders)
        // Task,
        // Mesh,
}

Shader_Stages_ALL_GRAPHICS :: Shader_Stages {
        .Vertex, 
        .Tessellation_Control, 
        .Tessellation_Evaluation, 
        .Geometry,
        .Fragment,
}

Bind_Point :: enum {
        Graphics,
        Compute,
        // Ray_Tracing // FEATURE(Ray tracing)
}

Texture_Layout :: enum {
        Undefined,
        General,
        Target,
        Input = Target,
        Read_Only,
        Transfer_Src,
        Transfer_Dst,
        Pre_Initialized,
        Present,
}


Access_Flags :: bit_set[Access_Flag]
Access_Flag :: enum {
        Indirect_Read,
        Index_Read,
        Vertex_Attribute_Read,
        Constant_Read,
        Texture_Read,
        Texture_Write,
        Storage_Read,
        Storage_Write,
        Color_Input_Read,
        Color_Target_Write,
        Depth_Stencil_Input_Read,
        Depth_Stencil_Target_Write,
        Transfer_Read,
        Transfer_Write,
        Host_Read,
        Host_Write,
        
        Memory_Read,  // same as setting all `*_Read` bits
        Memory_Write, // same as setting all `*_Write` bits
}

Texture_Aspect_Flags :: bit_set[Texture_Aspect_Flag]
Texture_Aspect_Flag :: enum {
        Color,
        Depth,
        Stencil,
}


Texture_Transition_Info :: struct {
        texture_aspect    : Texture_Aspect_Flags,
        after_src_stages  : Pipeline_Stages, // Ensure these stages are complete before starting transition (earlier is better)
        before_dst_stages : Pipeline_Stages, // Wait at these stages until transition is complete (later is better)
        src_layout        : Texture_Layout,
        dst_layout        : Texture_Layout,
        src_access        : Access_Flags,
        dst_access        : Access_Flags,
}

Texture_Init_Info :: struct {
        format             : Texture_Format,
        usage              : Texture_Usage_Flags,
        queue_usage        : Queue_Flags,
        memory_access_type : Memory_Access_Type,
        dimensions         : Texture_Dimensions,
        extent             : [3]u32,
        mip_count          : u32,
        layer_count        : u32,
        multisample        : Texture_Multisample,
        // initial_layout     : Texture_Layout,
        sampler_info       : Sampler_Info,
}

Texture_Format :: enum {
        Undefined,
        R8G8B8A8_UNORM,
        R16G16B16A16_SFLOAT,
}

Texture_Usage_Flags :: bit_set[Texture_Usage_Flag]
Texture_Usage_Flag :: enum {
        Transfer_Src,
        Transfer_Dst,
        Sampled,
        Storage,
        Color_Target,
        Color_Input = Color_Target,
        Depth_Stencil_Target,
        Depth_Stencil_Input = Depth_Stencil_Target,
        Transient_Target,
}

Texture_Dimensions :: enum {
        _1D,
        _2D,
        _3D,
        Cube,
        _1D_Array,
        _2D_Array,
        Cube_Array,
}

Texture_Multisample :: enum {
        None,
        _2,
        _4,
        _8,
        _16,
        _32,
        _64,
}

Memory_Access_Type :: enum {
        Device_Read_Only,
        Device_Read_Write,
        Staging,
        Host_Readback,
}

Sampler_Info :: struct {
        minify_filter         : Filter,
        magnify_filter        : Filter,
        mip_filter            : Filter,
        mip_lod_bias          : f32,

        wrap_mode             : Sampler_Wrap_Mode,
        border_color          : Sampler_Border_Color,
        sample_by_pixel_index : bool, // when true, use [0, pixel_width) instead of [0, 1)
        anisotropy            : Anisotropy,

        min_lod               : f32,
        max_lod               : f32,

}

Sampler_Info_DEFAULT :: Sampler_Info {
        wrap_mode             = .Clamp_To_Border,
        minify_filter         = .Linear,
        magnify_filter        = .Linear,
        mip_filter            = .Linear,
        mip_lod_bias          = 0,
        anisotropy            = ._8,
        min_lod               = 0,
        max_lod               = 0,
        border_color          = .Transparent_Black_Float,
        sample_by_pixel_index = false,
}


Filter :: enum {
        Nearest,
        Linear,
}

Sampler_Wrap_Mode :: enum {
        Repeat,
        Mirror,
        Clamp_To_Edge,
        Clamp_To_Border,
}

Sampler_Border_Color :: enum {
        Transparent_Black_Float,
        Transparent_Black_Int,
        Opaque_Black_Float,
        Opaque_Black_Int,
        Opaque_White_Float,
        Opaque_White_Int,
}

Anisotropy :: enum {
        None,
        _1,
        _2,
        _4,
        _8,
        _16,
}

Compare_Op :: enum {
	Never,
	Less,
	Equal,
	Less_Or_Equal,
	Greater,
	Not_Equal,
	Greater_Or_Equal,
	Always,
}

Cull_Mode :: enum {
        Never,
        Counter_Clockwise,
        Clockwise,
        Always,
}

Shader_Init_Info :: struct {
        code              : []u8,
        stage             : Shader_Stage,
        // vertex_attributes : Vertex_Attribute_Flags,
        cull_mode         : Cull_Mode,
        depth_test        : Compare_Op,
        depth_write       : bool,
        depth_bias        : f32,
        // stencil_test   : Compare_Op,
        // stencil_write  : bool,
}

Shader_Init_Info_DEFAULT :: Shader_Init_Info {
        // code              = {},
        // stage             = {},
        // vertex_attributes = {},
        cull_mode            = .Counter_Clockwise,
        depth_test           = .Greater,
        depth_write          = true,
        depth_bias           = 0,
        // stencil_test      = .Always,
        // stencil_write     = false,
}



Constant_Buffer_Set_Info :: struct {
        slot             : Constant_Buffer_Slot,
        buffer_reference : Buffer_Reference,
}

Constant_Buffer_Slot :: enum {
        Scene    = 0,
        Camera   = 1,
        Pass     = 2,
        Material = 3,
        Instance = 4,
}


Vertex_Attribute_Flags :: bit_set[Vertex_Attribute_Flag]
Vertex_Attribute_Flag :: enum {
        Position,
        Normal,
        Tangent,
        Color_0,
        Color_1,
        Tex_Coord_0,
        Tex_Coord_1,
        Tex_Coord_2,
        Tex_Coord_3,
        Joints_0,
        Joints_1,
        Weights_0,
        Weights_1,
}

Vertex_Attribute_Stride := [Vertex_Attribute_Flag]int {
        .Position    = size_of([3]f32),
        .Normal      = size_of([3]f16),
        .Tangent     = size_of([4]f16),
        .Color_0     = size_of([4]u8),
        .Color_1     = size_of([4]u8),
        .Tex_Coord_0 = size_of([2]f16),
        .Tex_Coord_1 = size_of([2]f16),
        .Tex_Coord_2 = size_of([2]f16),
        .Tex_Coord_3 = size_of([2]f16),
        .Joints_0    = size_of([4]u16),
        .Joints_1    = size_of([4]u16),
        .Weights_0   = size_of([4]f16),
        .Weights_1   = size_of([4]f16),
}

Vertex_Buffer_Bind_Info :: struct {
        attribute : Vertex_Attribute_Flag,
        buffer    : Buffer_Reference,
}

Buffer_Init_Info :: struct {
        size               : int,
        usage              : Buffer_Usage_Flags,
        queue_usage        : Queue_Flags,
        memory_access_type : Memory_Access_Type,
}


Buffer_Usage_Flags :: bit_set[Buffer_Usage_Flag]
Buffer_Usage_Flag :: enum {
        Transfer_Src,
        Transfer_Dst,
        Storage,
        Index,
        Vertex,
        Addressable,
}

Buffer_Upload_Info :: struct {
        size       : int,
        src_offset : int,
        dst_offset : int,
        data       : rawptr,
}

Buffer_Transfer_Info :: struct {
        size       : int,
        src_offset : int,
        dst_offset : int,
}

Texture_Upload_Info :: struct {
        size           : int,
        data           : rawptr,
}

Texture_Transfer_Info :: struct {
        size           : int,
        src_offset     : int,
        texture_aspect : Texture_Aspect_Flag,
}

/*
Depth_Stencil_Set_Info :: struct {
        depth_test   : Compare_Op,
        depth_write  : bool,
        depth_bias   : f32,
        stencil_test : bool,
}

Cull_Set_Info :: struct {
        cull_mode    : Cull_Mode,
}

Cull_Mode :: enum {
        Never,
        Counter_Clockwise,
        Clockwise,
        Always,
}

Viewport_Scissor_Set_Info :: struct {
        
}
*/

Index_Type :: enum {
        U16 = 0,
        U32 = 1,
}

Texture_Clear_Value :: struct #raw_union {
        color   : [4]f32,
        depth   : f32,
        stencil : u32,
}


Texture_Load_Op :: enum {
        Load,
        Clear,
        Dont_Care,
}

Texture_Store_Op :: enum {
        Store,
        Dont_Care,
}


Texture_Attachment_Info :: struct {
        texture_view           : ^Texture_View,
        texture_layout         : Texture_Layout,
        // resolve_mode           : Resolve_Mode, // FEATURE(MSAA)
        // resolve_texture_view   : ^Texture_View,
        // resolve_texture_layout : Texture_Layout,

        load_op                : Texture_Load_Op,
        store_op               : Texture_Store_Op,
        clear_value            : Texture_Clear_Value,
}

Render_Begin_Info :: struct {
        render_area     : Rect,
        layer_count     : int,
        color_textures  : []Texture_Attachment_Info,
        depth_texture   : ^Texture_Attachment_Info,
        stencil_texture : ^Texture_Attachment_Info,
}


Upload_Buffer_Command :: struct {
        size : int,
        data : rawptr,
        dst  : ^Buffer,
}

Upload_Texture_Command :: struct {
        size : int,
        data : rawptr,
        dst  : ^Texture,
}

Upload_Builder :: struct {
        size             : int,
        offset           : int,
        buffer_commands  : [dynamic]Upload_Buffer_Command,
        texture_commands : [dynamic]Upload_Texture_Command,
}

device_init :: proc(d: ^Device, device_init_info: ^Device_Init_Info) -> Result {
        return _device_init(d, device_init_info) 
}

device_destroy :: proc (d: ^Device) {
        _device_destroy(d)
}

device_wait_for_idle :: proc (d: ^Device) {
        _device_wait_for_idle(d)
}

// The immediate command buffer is NOT thread-safe
immediate_command_buffer_get :: proc(d: ^Device, cb: ^^Command_Buffer) -> Result {
        return _immediate_command_buffer_get(d, cb)
}

// Blocks until command buffer is complete
immediate_command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> Result {
        return _immediate_command_buffer_submit(d, cb)
}


swapchain_init :: proc(d: ^Device, sc: ^Swapchain, swapchain_init_info: ^Swapchain_Init_Info, location := #caller_location) -> Result {
        return _swapchain_init(d, sc, swapchain_init_info, location)
}

swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        _swapchain_destroy(d, sc)
}

swapchain_rebuild :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        return _swapchain_recreate(d, sc)
}


swapchain_get_frame_in_flight_index :: proc(d: ^Device, sc: ^Swapchain) -> int {
        return _swapchain_get_frame_in_flight_index(d, sc)
}

swapchain_get_frames_in_flight_count :: proc(d: ^Device, sc: ^Swapchain) -> int {
        return FRAMES_IN_FLIGHT
}

swapchain_get_extent :: proc(d: ^Device, sc: ^Swapchain) -> [2]u32 {
        return _swapchain_get_extent(d, sc)
}

swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        return _swapchain_present(d, sc)
} 

swapchain_wait_for_next_frame :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        return _swapchain_wait_for_next_frame(d, sc)
}

swapchain_acquire_texture :: proc(d: ^Device, sc: ^Swapchain, tex: ^^Texture) -> Result {
        return _swapchain_acquire_texture(d, sc, tex)
}

swapchain_acquire_command_buffer :: proc(d: ^Device, sc: ^Swapchain, cb: ^^Command_Buffer) -> Result {
        return _swapchain_acquire_command_buffer(d, sc, cb)
}



shader_init :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> Result {
        return _shader_init(d, s, init_info)
}

shader_destroy :: proc(d: ^Device, s: ^Shader) {
        _shader_destroy(d, s)
}

texture_init :: proc(d: ^Device, tex: ^Texture, init_info: ^Texture_Init_Info) -> Result {
        return _texture_init(d, tex, init_info)
}

texture_destroy :: proc(d: ^Device, tex: ^Texture) {
        _texture_destroy(d, tex)
}

texture_get_extent :: proc(d: ^Device, tex: ^Texture) -> [3]int {
        return _texture_get_extent(d, tex)
}

texture_get_reference :: proc(d: ^Device, tex: ^Texture) -> Texture_Reference {
        return _texture_get_reference(d, tex)
}

texture_get_reference_render_target :: proc(d: ^Device, tex: ^Texture) -> Render_Target_Reference {
        return _texture_get_reference_render_target(d, tex)
}

texture_get_full_view :: proc(d: ^Device, tex: ^Texture) -> ^Texture_View {
        return _texture_get_full_view(d, tex)
}

buffer_init :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> Result {
        return _buffer_init(d, b, init_info)
}

buffer_destroy :: proc(d: ^Device, b: ^Buffer) {
        _buffer_destroy(d, b)
}

buffer_get_reference :: proc {
        buffer_get_reference_base,
        buffer_get_reference_index,
        buffer_get_reference_offset,
}

buffer_get_reference_base :: proc(d: ^Device, b: ^Buffer) -> Buffer_Reference {
        return _buffer_get_reference_base(d, b)
}


buffer_get_reference_index :: proc(d: ^Device, b: ^Buffer, $T: typeid, index: int) -> Buffer_Reference {
        return _buffer_get_reference(d, b, T, index)
}

buffer_get_reference_offset :: proc(d: ^Device, b: ^Buffer, offset: int) -> Buffer_Reference {
        return _buffer_get_reference_offset(d, b, offset)
}

command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, command_buffer_init_info: ^Command_Buffer_Init_Info, location := #caller_location) -> Result {
        return _command_buffer_init(d, cb, command_buffer_init_info, location) 
}

command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        _command_buffer_destroy(d, cb)
}

command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> Result {
        return _command_buffer_begin(d, cb)
}

command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> Result  {
        return _command_buffer_end(d, cb)
}

command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> Result {
        return _command_buffer_submit(d, cb)
}

cmd_transition_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, transition_info: ^Texture_Transition_Info) {
        _cmd_transition_texture(d, cb, tex, transition_info)
}

cmd_clear_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, color: [4]f32) {
        _cmd_clear_color_texture(d, cb, tex, color)
}

cmd_blit_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, src, dst: ^Texture) {
        _cmd_blit_color_texture(d, cb, src, dst)
}

cmd_upload_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, staging: ^Buffer, tex: ^Texture, upload_info: ^Texture_Upload_Info) {
        _cmd_upload_color_texture(d, cb, staging, tex, upload_info)
}

// Uses cb's internal staging buffer. Prefer `cmd_upload_buffer` and provide a separate staging buffer
// for uploading large resources.
cmd_update_buffer :: proc(d: ^Device, cb: ^Command_Buffer, b: ^Buffer, upload_info: ^Buffer_Upload_Info) {
        _cmd_update_buffer(d, cb, b, upload_info)
}

cmd_upload_buffer :: proc(d: ^Device, cb: ^Command_Buffer, staging, dst: ^Buffer, upload_info: ^Buffer_Upload_Info) {
        _cmd_upload_buffer(d, cb, staging, dst, upload_info)
}

cmd_transfer_buffer :: proc(d: ^Device, cb: ^Command_Buffer, src, dst: ^Buffer, transfer_info: ^Buffer_Transfer_Info) {
        _cmd_transfer_buffer(d, cb, src, dst, transfer_info)
}

// "Bindless" - bind buffers of all resources at the beginning of the frame.
// Access resources within shaders using buffer indices.
cmd_bind_all :: proc(d: ^Device, cb: ^Command_Buffer, bind_point: Bind_Point) {
        _cmd_bind_all(d, cb, bind_point)
}

cmd_set_constant_buffer :: proc(d: ^Device, cb: ^Command_Buffer, slot: Constant_Buffer_Slot, buffer: Buffer_Reference) {
        _cmd_set_constant_buffer(d, cb, slot, buffer)
}

cmd_bind_vertex_shader ::  proc(d: ^Device, cb: ^Command_Buffer, shader: ^Shader) {
        _cmd_bind_vertex_shader(d, cb, shader)
}

cmd_bind_fragment_shader ::  proc(d: ^Device, cb: ^Command_Buffer, shader: ^Shader) {
        _cmd_bind_fragment_shader(d, cb, shader)
}

cmd_bind_compute_shader ::  proc(d: ^Device, cb: ^Command_Buffer, shader: ^Shader) {
        _cmd_bind_compute_shader(d, cb, shader)
}

cmd_bind_vertex_buffers :: proc(d: ^Device, cb: ^Command_Buffer, bind_infos: []Vertex_Buffer_Bind_Info) {
        _cmd_bind_vertex_buffers(d, cb, bind_infos)
}

cmd_bind_index_buffer :: proc(d: ^Device, cb: ^Command_Buffer, buffer: Buffer_Reference, count: int, index_type: Index_Type) {
        _cmd_bind_index_buffer(d, cb, buffer, count, index_type)
}

cmd_begin_render :: proc(d: ^Device, cb: ^Command_Buffer, render_begin_info: ^Render_Begin_Info) {
        _cmd_begin_render(d, cb, render_begin_info)
}

cmd_end_render :: proc(d: ^Device, cb: ^Command_Buffer) {
        _cmd_end_render(d, cb)
}

cmd_draw :: proc(d: ^Device, cb: ^Command_Buffer) {
        _cmd_draw(d, cb)
}

cmd_dispatch :: proc(d: ^Device, cb: ^Command_Buffer, groups: [3]u32) {
        _cmd_dispatch(d, cb, groups)
}

upload_builder_init :: proc {
        upload_builder_init_cap,
}

upload_builder_init_cap :: proc(d: ^Device, upload_builder: ^Upload_Builder, buffer_cap: int, texture_cap: int) {

}

upload_builder_init_bytes :: proc(d: ^Device, upload_builder: ^Upload_Builder, buffer_backing: []Upload_Buffer_Command, texture_backing: []Upload_Texture_Command) {

} 

immediate_upload_begin :: proc(d: ^Device, upload_builder: ^Upload_Builder) -> Result {

}

immediate_upload_submit :: proc(d: ^Device, upload_builder: ^Upload_Builder) -> Result {

}

upload_buffer :: proc(d: ^Device, b: ^Upload_Builder, size: int, data: rawptr, out_buffer: ^Buffer) {

}



// cmd_begin_render : proc(^Device, ^Command_Buffer) : _cmd_begin_render
/*
texture_init :: _texture_init
texture_destroy :: _texture_destroy

texture_view_init :: _texture_view_init
texture_view_destroy :: _texture_view_destroy

sampler_init :: _sampler_init
sampler_destroy :: _sampler_destroy


cmd_begin_render :: _cmd_begin_render
cmd_end_render :: _cmd_end_render
cmd_wait_semaphore :: _cmd_wait_semaphore
cmd_signal_semaphore :: _cmd_signal_semaphore
cmd_signal_fence :: _cmd_signal_fence
cmd_transition_texture :: _cmd_transition_texture

cmd_set_scissor :: _cmd_set_scissor
cmd_set_viewport :: _cmd_set_viewport
cmd_set_shaders :: _cmd_set_shaders
cmd_set_render_targets :: _cmd_set_render_targets
cmd_set_uniform_buffers :: _cmd_set_uniform_buffers
cmd_set_storage_buffers :: _cmd_set_storage_buffers
cmd_set_input_layout :: _cmd_set_input_layout

cmd_draw :: _cmd_draw
cmd_dispatch :: _cmd_dispatch
*/
