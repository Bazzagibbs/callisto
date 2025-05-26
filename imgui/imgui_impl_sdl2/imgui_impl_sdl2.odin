package imgui_impl_sdl2

import sdl "vendor:sdl2"

when      ODIN_OS == .Windows { foreign import lib "../imgui_windows_x64.lib" }
else when ODIN_OS == .Linux   { foreign import lib "../imgui_linux_x64.a" }
else when ODIN_OS == .Darwin  {
	when ODIN_ARCH == .amd64 { foreign import lib "../imgui_darwin_x64.a" } else { foreign import lib "../imgui_darwin_arm64.a" }
}

// imgui_impl_sdl2.h
// Last checked `v1.91.1-docking` (6df1a0)
GamepadMode :: enum i32 {
	AutoFirst,
	AutoAll,
	Manual,
}

@(link_prefix="ImGui_ImplSDL2_")
foreign lib {
	InitForOpenGL      :: proc(window: ^sdl.Window, sdl_gl_context: rawptr) -> bool ---
	InitForVulkan      :: proc(window: ^sdl.Window) -> bool ---
	InitForD3D         :: proc(window: ^sdl.Window) -> bool ---
	InitForMetal       :: proc(window: ^sdl.Window) -> bool ---
	InitForSDLRenderer :: proc(window: ^sdl.Window, renderer: ^sdl.Renderer) -> bool ---
	InitForOther       :: proc(window: ^sdl.Window) -> bool ---
	Shutdown           :: proc() ---
	NewFrame           :: proc() ---
	ProcessEvent       :: proc(event: ^sdl.Event) -> bool ---

	// Gamepad selection automatically starts in AutoFirst mode, picking first available SDL_Gamepad. You may override this.
	// When using manual mode, caller is responsible for opening/closing gamepad.
	SetGamepadMode :: proc(mode: GamepadMode, manual_gamepads_array: [^]^sdl.GameController, manual_gamepads_count := i32(-1)) ---
}
