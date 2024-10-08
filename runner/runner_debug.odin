package callisto_runner

import "core:dynlib"
import "core:os"

DLL_BASE :: "game"

when ODIN_OS == .Windows {
        DLL_EXT :: ".dll"
} else when ODIN_OS == .Darwin {
        DLL_EXT :: ".dylib"
} else {
        DLL_EXT :: ".so"
}


game_callbacks: Runner_Callbacks = {}
game_state        : rawptr


main :: proc() {
        // game_dll_load(0)
        game_state = game_callbacks.memory_init()

        for {
                flags := game_callbacks.poll_runner_control()
                if flags != {} {
                        if .Shutdown in flags do break
                        if .Reset_Hard in flags { 
                                game_callbacks.memory_shutdown(game_state)
                                game_state = game_callbacks.memory_init()
                        }
                        if .Reset_Soft in flags {
                                game_state = game_callbacks.memory_reset(game_state)
                        } 
                }

                game_callbacks.render()

                // watch dll for changes
                // if watch_dll_changed() {
                // game_dll_load()
                // game_callbacks.memory_load(game_state)
                // }
        }
        
        game_callbacks.memory_shutdown(game_state)
        game_dll_unload()
}


// copy_file :: proc(dst_path, src_path: string) -> (ok: bool) {
// 	src := os.open(src_path) or_return
// 	defer os.close(src)
//
// 	info := os.fstat(src, file_allocator()) or_return
// 	defer file_info_delete(info, file_allocator())
// 	if info.is_directory {
// 		return .Invalid_File
// 	}
//
// 	dst := open(dst_path, {.Read, .Write, .Create, .Trunc}, info.mode & File_Mode_Perm) or_return
// 	defer close(dst)
//
// 	_, err := io.copy(to_writer(dst), to_reader(src))
// 	return err
// }


game_dll_load :: proc(version_number: int) {
        // Probably need a way to fence the game dll if it's multithreaded 
        // to avoid corrupting game state

        // First make a copy of the actual dll so we can overwrite it later
        // copy_file(DLL_BASE + {version_number} + DLL_EXT, DLL_BASE + DLL_EXT)
        
        // dynlib.unload_library(game_dll)
        dynlib.load_library(DLL_BASE + DLL_EXT)
}


game_dll_unload :: proc() {

}
