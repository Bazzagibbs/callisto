//+private
package callisto_graphics

import "../config"
import backend "backend_vk"

when config.RENDERER_API == .Vulkan {
   

    _renderer_create :: proc(description: ^Engine_Description, window: Window) -> (r: Renderer, res: Result) {
        r_vk := new(backend.Renderer_Impl)
        r = to_handle(r_vk)

        defer if res != .Ok do free(r_vk)

        r_vk.instance                   = backend.create_instance(r_vk, description) or_return
        r_vk.surface                    = backend.create_surface(r_vk, window) or_return
        r_vk.physical_device,
        r_vk.physical_device_properties = backend.select_physical_device(r_vk) or_return
        r_vk.device, 
        r_vk.queues                     = backend.create_device(r_vk, description) or_return

        return r, .Ok
    }

    _renderer_destroy :: proc(r: Renderer) {
        r_vk := from_handle(r)

        backend.destroy_device(r_vk, r_vk.device)
        backend.destroy_surface(r_vk, r_vk.surface)
        backend.destroy_instance(r_vk, r_vk.instance)

        free(r_vk)
    }

    _gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Description) -> (gpu_image: Gpu_Image, res: Result) {
        unimplemented();
    }

    _gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
        unimplemented();
    }

    _gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Description) -> (gpu_buffer: Gpu_Buffer, res: Result) {
        unimplemented();
    }

    _gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Description) -> (res: Result) {
        unimplemented();
    }

    _gpu_buffer_destroy :: proc(r: Renderer, gpu_buffer: Gpu_Buffer) {
        unimplemented();
    }


}
