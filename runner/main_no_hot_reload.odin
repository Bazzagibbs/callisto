package callisto_runner

import "base:runtime"
import "core:log"
import "core:dynlib"
import "core:path/filepath"
import "core:fmt"
import "core:os"
import "core:mem"

when !HOT_RELOAD {

        main :: proc () {
                
                ctx : runtime.Context
                track : mem.Tracking_Allocator
                callisto_context_init(&ctx, &track) 
                defer callisto_context_destroy(&ctx, &track)
                context = ctx

                runner := default_runner()
               
                opts, level := callisto_logger_options()
                callisto_logger_init(&runner, &ctx.logger, "log", level, opts)
                defer callisto_logger_destroy(&ctx.logger)
                runner.ctx = ctx
                context    = ctx


                exe_dir, _ := get_exe_directory()
                dll_path := fmt.aprintf(DLL_ORIGINAL_FMT, exe_dir)

                _, ok := dynlib.initialize_symbols(&runner.symbols, dll_path, handle_field_name="lib")
                assert_messagebox(ok, "Failed to load application dll:", dll_path)

                
                delete(exe_dir)
                delete(dll_path)

                // init
                runner.symbols.callisto_init(&runner)
              
                // main loop
                for !runner.should_close {
                        switch runner.event_behaviour {
                        case .Before_Loop:
                                event_pump(&runner)
                        case .Before_Loop_Wait:
                                event_wait(&runner)
                        case .Manual:
                        }

                        runner.symbols.callisto_loop(runner.app_memory)
                }

                // destroy
                runner.symbols.callisto_destroy(runner.app_memory)

                if runner.exit_code != .Ok {
                        log.error("Exiting with exit code:", runner.exit_code)
                        os.exit(int(runner.exit_code))
                }
                
        }

}
