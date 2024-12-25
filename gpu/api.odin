package callisto_gpu

import "base:runtime"
import "../common"
import "../config"

RHI :: config.RHI

FRAMES_IN_FLIGHT :: 3

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

Location :: runtime.Source_Code_Location


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
        Begin,
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
        End,
        Host,
        Copy,
        Resolve,
        Blit,
        Clear,
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
        initial_layout     : Texture_Layout,
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

Sampler_Init_Info :: struct {
        wrap_mode      : Sampler_Wrap_Mode,
        minify_filter  : Filter,
        magnify_filter : Filter,
        mip_filter     : Filter,
        mip_lod_bias   : f32,

        anisotropy     : bool,
        max_anisotropy : f32,

        min_lod        : f32,
        max_lod        : f32,
        border_color   : Sampler_Border_Color,

        sample_by_pixel_index : bool, // when true, use [0, pixel_width) instead of [0, 1)
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

Shader_Init_Info :: struct {
        code              : []u8,
        stage             : Shader_Stage,
        // vertex_attributes : Vertex_Attribute_Flags,
        resource_ranges   : []Resource_Type,
}


Resource_Type :: enum {
        Buffer,
        Sampled_Texture,
        Storage_Texture,
        // Acceleration_Structure, // FEATURE(Ray tracing)
}

Constant_Slot :: enum {
        Scene    = 0,
        Pass     = 1,
        Material = 2,
        Instance = 3,
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



/*
Texture_View_Init_Info :: struct {
        texture     : ^Texture,
        format : Texture_Format,
        dimensions  : Texture_View_Dimensions,
        mip_base    : u32,
        mip_count   : u32,
        layer_base  : u32,
        layer_count : u32,
}

/*
Buffer_Init_Info :: struct {}

Buffer_Transfer_Info :: struct {}
*/



Color_Target_Info :: struct {
        texture              : ^Texture,
        texture_view         : ^Texture_View,  //optional
        resolve_texture      : ^Texture,
        resolve_texture_view : ^Texture_View,  // optional
        clear_value          : [4]f32,
        load_op              : Load_Op,
        store_op             : Store_Op,
}

Depth_Stencil_Target_Info :: struct {
        texture              : ^Texture,
        texture_view         : ^Texture_View,  // optional
        resolve_texture      : ^Texture,
        resolve_texture_view : ^Texture_View,  // optional
        clear_value          : struct {depth: f32, stencil: u32},
        load_op              : Load_Op,
        store_op             : Store_Op,
}

Load_Op :: enum {
        Load,
        Clear,
        Dont_Care
}

Store_Op :: enum {
        Store,
        Dont_Care,
        Resolve,
        Resolve_And_Store,
}

Resolve_Mode_Flags :: bit_set[Resolve_Mode_Flag]
Resolve_Mode_Flag :: enum {
        Sample_0,
        Average,
        Min,
        Max,
}
*/

device_init :: proc(d: ^Device, device_init_info: ^Device_Init_Info, location := #caller_location) -> Result {
        return _device_init(d, device_init_info, location) 
}

device_destroy :: proc (d: ^Device) {
        _device_destroy(d)
}

device_wait_for_idle :: proc (d: ^Device) {
        _device_wait_for_idle(d)
}

swapchain_init :: proc(d: ^Device, sc: ^Swapchain, swapchain_init_info: ^Swapchain_Init_Info, location := #caller_location) -> Result {
        return _swapchain_init(d, sc, swapchain_init_info, location)
}

swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        _swapchain_destroy(d, sc)
}

// swapchain_rebuild :: proc(d: ^Device, sc: ^Swapchain) -> Result {
//         return _swapchain_rebuild(d, sc)
// }


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


texture_init :: proc(d: ^Device, tex: ^Texture, init_info: ^Texture_Init_Info) -> Result {
        return _texture_init(d, tex, init_info)
}

texture_destroy :: proc(d: ^Device, tex: ^Texture) {
        _texture_destroy(d, tex)
}

shader_init :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> Result {
        return _shader_init(d, s, init_info)
}

shader_destroy :: proc(d: ^Device, s: ^Shader) {
        _shader_destroy(d, s)
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

// TODO: Remove this, use begin_render_pass load_op for clears instead
cmd_clear_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, color: [4]f32) {
        _cmd_clear_color_texture(d, cb, tex, color)
}

cmd_blit_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, src, dst: ^Texture) {
        _cmd_blit_color_texture(d, cb, src, dst)
}

// "Bindless" - bind buffers of all resources at the beginning of the frame.
// Access resources within shaders using buffer indices.
cmd_bind_all :: proc(d: ^Device, cb: ^Command_Buffer, bind_point: Bind_Point) {
        _cmd_bind_all(d, cb, bind_point)
}

cmd_set_constant_buffer :: proc(d: ^Device, cb: ^Command_Buffer, slot: Constant_Slot, buffer: ^Constant_Buffer) {
        _cmd_set_constant_buffer(d, cb, slot, buffer)
}


cmd_draw :: proc(d: ^Device, cb: ^Command_Buffer, vertex_buffer: ^Buffer, index_buffer: ^Buffer)
cmd_dispatch :: proc(d: ^Device, cb: ^Command_Buffer, threads: [3]u32)


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
