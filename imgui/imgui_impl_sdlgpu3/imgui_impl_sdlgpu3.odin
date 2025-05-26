package imgui_impl_sdlgpu3

import imgui "../"
import sdl "vendor:sdl3"

when      ODIN_OS == .Windows { foreign import lib "../imgui_windows_x64.lib" }
else when ODIN_OS == .Linux   { foreign import lib "../imgui_linux_x64.a" }
else when ODIN_OS == .Darwin  {
	when ODIN_ARCH == .amd64 { foreign import lib "../imgui_darwin_x64.a" } else { foreign import lib "../imgui_darwin_arm64.a" }
}

// Implemented features:
//  [X] Renderer: User texture binding. Use simply cast a reference to your SDL_GPUTextureSamplerBinding to ImTextureID.
//  [X] Renderer: Large meshes support (64k+ vertices) with 16-bit indices.
// Missing features:
//  [ ] Renderer: Multi-viewport support (multiple windows).

// imgui_impl_sdlgpu3.h
// Last checked `v1.91.9-docking` (126d004)
InitInfo :: struct {
        Device            : ^sdl.GPUDevice,
        ColorTargetFormat : sdl.GPUTextureFormat,
        MSAASamples       : sdl.GPUSampleCount,
}

// Follow "Getting Started" link and check examples/ folder to learn about using backends!
@(link_prefix="ImGui_ImplSDLGPU3_")
foreign lib {
        Init                 :: proc(info: ^InitInfo) -> bool ---
        Shutdown             :: proc() ---
        NewFrame             :: proc() ---
        PrepareDrawData :: proc(draw_data: ^imgui.DrawData, command_buffer: ^sdl.GPUCommandBuffer) --- // < typo in source (lowercase G)
        RenderDrawData       :: proc(draw_data: ^imgui.DrawData, command_buffer: ^sdl.GPUCommandBuffer, render_pass: ^sdl.GPURenderPass, pipeline: ^sdl.GPUGraphicsPipeline = nil) ---

        CreateDeviceObjects  :: proc() ---
        DestroyDeviceObjects :: proc() ---
        CreateFontsTexture   :: proc() ---
        DestroyFontsTexture  :: proc() ---
}
