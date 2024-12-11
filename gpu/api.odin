package callisto_gpu

import "base:runtime"
import "../common"
import "../config"

RHI :: config.RHI

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

Location :: runtime.Source_Code_Location


Device_Init_Info :: struct {
        runner            : ^Runner, // required
        required_features : Required_Device_Features,
}

Required_Device_Features :: bit_set[Required_Device_Feature]
Required_Device_Feature :: enum {}

Swapchain_Init_Info :: struct {
        window                        : Window,
        vsync                         : Vsync_Mode,
        force_draw_occluded_fragments : bool,
        // hdr    : bool,
}

Vsync_Modes :: bit_set[Vsync_Mode]
Vsync_Mode :: enum {
        Double_Buffered, // Guaranteed to be supported on every device
        Triple_Buffered,
        Off,
}

Command_Buffer_Init_Info :: struct {
        type             : Command_Buffer_Type,
        wait_semaphore   : ^Semaphore,
        signal_semaphore : ^Semaphore,
        signal_fence     : ^Fence,
}

Command_Buffer_Type :: enum {
        Graphics,
        Compute_Sync,
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
}

Texture_Layout :: enum {
        Undefined,
        General,
        Target_Or_Input,
        Read_Only,
        Transfer_Source,
        Transfer_Dest,
        Pre_Initialized,
        Present,
}


Access_Flags :: bit_set[Access_Flag]
Access_Flag :: enum {
        Indirect_Read,
        Index_Read,
        Vertex_Attribute_Read,
        Uniform_Read,
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

/*
Buffer_Init_Info :: struct {}

Buffer_Transfer_Info :: struct {}

Texture_Init_Info :: struct {
        format      : Texture_Format,
        usage       : Texture_Usage_Flags,
        dimensions  : Texture_View_Dimensions,
        extent      : [3]u32,
        mip_count   : u32,
        layer_count : u32,
}

Texture_Format :: enum {
        R8G8B8A8_UNORM_SRGB,
}

Texture_Usage_Flags :: bit_set[Texture_Usage_Flag]
Texture_Usage_Flag :: enum {
        Sampled,
        Storage,
        Color_Target,
        Depth_Stencil_Target,
        Transient,
}

Texture_View_Init_Info :: struct {
        texture     : ^Texture,
        format : Texture_Format,
        dimensions  : Texture_View_Dimensions,
        mip_base    : u32,
        mip_count   : u32,
        layer_base  : u32,
        layer_count : u32,
}

Texture_View_Dimensions :: enum {
        _1D,
        _2D,
        _3D,
        Cube,
        _1D_Array,
        _2D_Array,
        Cube_Array,
}

Sampler_Init_Info :: struct {}

Shader_Init_Info :: struct {}

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

swapchain_init :: proc(d: ^Device, sc: ^Swapchain, swapchain_init_info: ^Swapchain_Init_Info, location := #caller_location) -> Result {
        return _swapchain_init(d, sc, swapchain_init_info, location)
}

swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        _swapchain_destroy(d, sc)
}

// swapchain_rebuild :: proc(d: ^Device, sc: ^Swapchain) -> Result {
//         return _swapchain_rebuild(d, sc)
// }

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

// TEMPORARY: use begin_render_pass instead
cmd_clear_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, color: [4]f32) {
        _cmd_clear_color_texture(d, cb, tex, color)
}


// cmd_begin_render : proc(^Device, ^Command_Buffer) : _cmd_begin_render
/*
texture_init :: _texture_init
texture_destroy :: _texture_destroy

texture_view_init :: _texture_view_init
texture_view_destroy :: _texture_view_destroy

sampler_init :: _sampler_init
sampler_destroy :: _sampler_destroy

shader_init :: _shader_init
shader_destroy :: _shader_destroy

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
