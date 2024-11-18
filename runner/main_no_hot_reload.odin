package callisto_runner
import "base:runtime"
import "core:log"
import "core:dynlib"
import "core:path/filepath"
import "core:fmt"

when !HOT_RELOAD {

        Runner_State_No_Hot_Reload :: struct {
                symbols : Dll_Symbol_Table,
        }

        main :: proc () {
                ctx, track := _callisto_context() 
                defer _callisto_context_end(ctx, track)

                context = ctx

                runner := Runner {
                        ctx = ctx,
                        should_close   = false,
                        platform_init  = platform_init,
                        window_create  = window_create,
                        window_destroy = window_destroy,
                }

                app_dir := get_exe_directory()
                dll_path := fmt.aprintf(DLL_ORIGINAL_FMT, app_dir)

                _, ok := dynlib.initialize_symbols(&runner.symbols, dll_path, handle_field_name="lib")
                assert_messagebox(ok, "Failed to load application dll:", dll_path)

                defer dynlib.unload_library(runner.symbols.lib)
                
                delete(app_dir)
                delete(dll_path)

                // init
                runner.app_data = runner.symbols.callisto_init(&runner)
              
                // main loop
                for !runner.should_close {
                        runner.symbols.callisto_loop(runner.app_data)
                }

                // destroy
                runner.symbols.callisto_destroy(runner.app_data)
        }

}
