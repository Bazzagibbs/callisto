package callisto_graphics
import "../common"
import "../asset"

Renderer               :: distinct common.Handle
Gpu_Image              :: distinct common.Handle
Gpu_Buffer             :: distinct common.Handle

Renderer_Create_Info   :: struct {}
Gpu_Image_Create_Info  :: struct {}
Gpu_Buffer_Create_Info :: struct {}
Gpu_Buffer_Upload_Info :: struct {}


renderer_create :: proc(description: ^Renderer_Create_Info) -> (r: Renderer, ok: bool) {
    unimplemented();
}

renderer_destroy :: proc(r: Renderer) {
    unimplemented();
}

gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Create_Info) -> (gpu_img: Gpu_Image, ok: bool) {
    unimplemented();
}

gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
    unimplemented();
}

gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Create_Info) -> (gpu_buf: Gpu_Buffer, ok: bool) {
    unimplemented();
}

gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Info) -> (ok: bool) {
    unimplemented();
}

gpu_buffer_destroy :: proc(r: Renderer, gpu_buf: Gpu_Buffer) {
    unimplemented();
}


