package callisto_gpu

import "../common"

Result :: common.Result
Runner :: common.Runner
Window :: common.Window


Device_Init_Info :: struct {
        runner            : ^Runner, // required
        required_features : Required_Device_Features,
}

Required_Device_Features :: bit_set[Required_Device_Feature]
Required_Device_Feature :: enum {}

Swapchain_Init_Info :: struct {
        window : Window,
        vsync  : Vsync_Mode,
        size   : Maybe([2]i32), // nil to use full window size
        // hdr    : bool,
}

Vsync_Modes :: bit_set[Vsync_Mode]
Vsync_Mode :: enum {
        Double_Buffered, // Guaranteed to be supported on every device
        Triple_Buffered,
        No_Sync,
}

Queue_Init_Info :: struct {}

Command_Buffer_Init_Info :: struct {}

Buffer_Init_Info :: struct {}

Buffer_Transfer_Info :: struct {}

Texture_Init_Info :: struct {}

Sampler_Init_Info :: struct {}

Shader_Init_Info :: struct {}



// Implement this interface for all RHI backends
/*

device_init              :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result)
device_destroy           :: proc(d: ^Device)

swapchain_init
swapchain_destroy
swapchain_resize

swapchain_set_vsync
swapchain_get_vsync
swapchain_get_available_vsync

buffer_init              :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy           :: proc(d: ^Device, b: ^Buffer)
buffer_transfer          :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init             :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy          :: proc(d: ^Device, t: ^Texture)

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

command_buffer_init      :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result)
command_buffer_destroy   :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_submit    :: proc(d: ^Device, cb: ^Command_Buffer)

cmd_clear                :: proc(cb: ^Command_Buffer, color: [4]f32)

cmd_bind_vertex_shader   :: proc(cb: ^Command_Buffer, vs: ^Shader)
cmd_bind_fragment_shader :: proc(cb: ^Command_Buffer, fs: ^Shader)

cmd_draw                 :: proc(cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)
cmd_present              :: proc(cb: ^Command_Buffer)
*/
