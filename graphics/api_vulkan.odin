//+private
package callisto_graphics

import "../config"
import backend "backend_vk"

when config.RENDERER_API == .Vulkan {
   

    _renderer_create :: proc(description: ^Engine_Description, window: Window) -> (r: Renderer, res: Result) {
        r_vk := new(backend.Renderer_Impl)
        r = to_handle(r_vk)

        defer if res != .Ok do _renderer_destroy(r)

        backend.instance_create(r_vk, description) or_return
        backend.surface_create(r_vk, window) or_return
        backend.physical_device_select(r_vk) or_return
        backend.device_create(r_vk, description) or_return
        backend.swapchain_create(r_vk, description) or_return
        backend.command_structures_create(r_vk) or_return
        backend.sync_structures_create(r_vk) or_return

        return r, .Ok
    }

    _renderer_destroy :: proc(r: Renderer) {
        r_vk := from_handle(r)

        backend.device_wait_idle(r_vk)

        backend.sync_structures_destroy(r_vk)
        backend.command_structures_destroy(r_vk)
        backend.swapchain_destroy(r_vk)
        backend.device_destroy(r_vk)
        backend.surface_destroy(r_vk)
        backend.instance_destroy(r_vk)

        free(r_vk)
    }

    _gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Description) -> (gpu_image: Gpu_Image, res: Result) {
        unimplemented()
    }

    _gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
        unimplemented()
    }

    _gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Description) -> (gpu_buffer: Gpu_Buffer, res: Result) {
        unimplemented()
    }

    _gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Description) -> (res: Result) {
        unimplemented()
    }

    _gpu_buffer_destroy :: proc(r: Renderer, gpu_buffer: Gpu_Buffer) {
        unimplemented()
    }


    _cmd_record_begin :: proc(r: Renderer) {
        unimplemented()
    }

    _cmd_record_end :: proc(r: Renderer) {
        unimplemented()
    }
    
    // _cmd_draw :: proc(r: Renderer /*, some gpu resources or description */) {
    // }
    //
    // _cmd_present :: proc(r: Renderer) { 
    //     unimplemented()
    // }

}
