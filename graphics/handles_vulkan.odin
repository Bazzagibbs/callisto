//+private
package callisto_graphics

import "../common"
import "../config"
import backend "backend_vk"

when config.RENDERER_API == .Vulkan {

    Renderer_Impl   :: backend.Renderer_Impl
    Shader_Impl     :: backend.Shader_Impl
    Gpu_Image_Impl  :: backend.Gpu_Image_Impl
    Gpu_Buffer_Impl :: backend.Gpu_Buffer_Impl

    to_handle :: proc {
        to_handle_renderer,
        to_handle_gpu_image,
        to_handle_gpu_buffer,
        to_handle_shader,
    }

    to_handle_renderer :: proc "contextless" (renderer_vk: ^Renderer_Impl) -> (Renderer) {
        return transmute(Renderer)renderer_vk
    }
    
    to_handle_shader :: proc "contextless" (shader_vk: ^Shader_Impl) -> (Shader) {
        return transmute(Shader)shader_vk
    }

    to_handle_gpu_image :: proc "contextless" (gpu_img_vk: ^Gpu_Image_Impl) -> (Gpu_Image) {
        return transmute(Gpu_Image)gpu_img_vk
    }

    to_handle_gpu_buffer :: proc "contextless" (gpu_buf_vk: ^Gpu_Buffer_Impl) -> (Gpu_Buffer) {
        return transmute(Gpu_Buffer)gpu_buf_vk
    }

    from_handle :: proc {
        from_handle_renderer,
        from_handle_gpu_image,
        from_handle_gpu_buffer,
        from_handle_shader,
    }

    from_handle_renderer :: proc "contextless" (handle: Renderer) -> (^Renderer_Impl) {
        return transmute(^Renderer_Impl)handle;
    }
    
    from_handle_shader :: proc "contextless" (handle: Shader) -> (^Shader_Impl) {
        return transmute(^Shader_Impl)handle;
    }

    from_handle_gpu_image :: proc "contextless" (handle: Gpu_Image) -> (^Gpu_Image_Impl) {
        return transmute(^Gpu_Image_Impl)handle;
    }

    from_handle_gpu_buffer :: proc "contextless" (handle: Gpu_Buffer) -> (^Gpu_Buffer_Impl) {
        return transmute(^Gpu_Buffer_Impl)handle;
    }

}
