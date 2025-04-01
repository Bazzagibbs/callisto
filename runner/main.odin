package callisto_runner

import "base:runtime"
import "core:os/os2"
import "core:dynlib"
import "core:strings"
import "core:fmt"
import "core:path/filepath"
import "core:time"
import "core:log"
import "core:mem"

import sdl "vendor:sdl3"
import "../config"
import "../common"


when ODIN_OS == .Windows {
        DLL_ORIGINAL_FMT :: "app.dll"
        DLL_COPY_FMT     :: "app_{0}.dll"
} else when ODIN_OS == .Darwin {
        DLL_ORIGINAL_FMT :: "app.dylib"
        DLL_COPY_FMT     :: "app_{0}.dylib"
} else {
        DLL_ORIGINAL_FMT :: "app.so"
        DLL_COPY_FMT     :: "app_{0}.so"
}


Runner :: common.Runner


main :: proc() {
        // Pass loop control to SDL
        exit_code := sdl.EnterAppMainCallbacks(
                i32(len(runtime.args__)),
                raw_data(runtime.args__),
                runner_init,
                runner_iter,
                runner_event,
                runner_quit
        )

        os2.exit(int(exit_code))
}



runner_init :: proc "c" (runner_state: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
        context = runtime.default_context()
        context.logger = logger_sdl_create()

        runner_state^ = new(Runner)
        r : ^Runner = cast(^Runner)(runner_state^)

        // Tracking allocator
        when ODIN_DEBUG {
                mem.tracking_allocator_init(&r.tracking_allocator, context.allocator, context.allocator)
                context.allocator = mem.tracking_allocator(&r.tracking_allocator)
        }

        
        r.ctx = context

        base_path := string(sdl.GetBasePath())
        r.dll_original_path = filepath.join({base_path, DLL_ORIGINAL_FMT})

       
        // Initial app DLL load
        write_time, err := os2.last_write_time_by_name(r.dll_original_path)
        assert(err == {})
        r.dll_modified = write_time

        loaded: bool
        r.app_dll, loaded = runner_load_app_dll(r.dll_original_path, 0)
        assert(loaded)

        
        

        return r.app_dll.callisto_init(&r.app_data)
}



runner_iter :: proc "c" (runner_state: rawptr) -> sdl.AppResult {
        r : ^Runner = cast(^Runner)(runner_state)
        context = r.ctx

        modified_time, did_change := runner_watch_app_dll(r.dll_original_path, r.dll_modified)
        if did_change {
                r.dll_modified = modified_time
                r.dll_generation += 1
                new_dll, loaded := runner_load_app_dll(r.dll_original_path, r.dll_generation)
                if loaded {
                        r.app_dll = new_dll
                } else {
                        log.error("Failed to load app DLL generation:", r.dll_generation)
                }
        }

        
        return r.app_dll.callisto_loop(r.app_data)
}



runner_event :: proc "c" (runner_state: rawptr, event: ^sdl.Event) -> sdl.AppResult {
        r : ^Runner = cast(^Runner)(runner_state)
        context = r.ctx

        return r.app_dll.callisto_event(r.app_data, event)
}


runner_quit :: proc "c" (runner_state: rawptr, result: sdl.AppResult) {
        r : ^Runner = cast(^Runner)(runner_state)
        context = r.ctx

        r.app_dll.callisto_quit(r.app_data, result)
       
        delete(r.dll_original_path)
        
        
        // ~Tracking allocator
        when ODIN_DEBUG {
                for _, leak in r.tracking_allocator.allocation_map {
                        log.errorf("%v %v leaked %m\n", leak.location, leak.location.procedure, leak.size)
                }

                for bad_free in r.tracking_allocator.bad_free_array {
                        log.errorf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
                }
                
                context.allocator = r.tracking_allocator.backing
                mem.tracking_allocator_destroy(&r.tracking_allocator)
        }

        
        free(r)

        logger_sdl_destroy(context.logger)
}



// when config.HOT_RELOAD {
runner_watch_app_dll :: proc(path: string, last_modified: time.Time) -> (new_last_modified: time.Time, did_change: bool) {
        write_time, err := os2.last_write_time_by_name(path)
        if err != {} {
                return last_modified, false
        }

        if time.diff(last_modified, write_time) > 0 {
                return write_time, true
        }

        return last_modified, false
}



runner_load_app_dll :: proc(original_path: string, generation: int) -> (symbols: common.Callisto_Dll, loaded: bool) {
        copy_path_0 := fmt.tprintf(DLL_COPY_FMT, generation)
        
        base_path := string(sdl.GetBasePath())
        copy_path_1 := filepath.join({base_path, copy_path_0}, context.temp_allocator)

        // Create DLL copy
        err := os2.copy_file(copy_path_1, original_path)
        if err != {} {
                log.error("Failed to create DLL copy:", original_path, "->", copy_path_1, " : ", err)
                return {}, false
        }

        _, loaded = dynlib.initialize_symbols(&symbols, copy_path_1, handle_field_name = "lib")
        if !loaded {
                log.error("Failed to load DLL:", copy_path_1)
        }

        return
}

// } else {
//
// }
