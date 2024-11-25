package callisto_runner

import "base:runtime"
import "core:dynlib"
import "core:os"
import "core:os/os2"
import "core:io"
import "core:fmt"
import "core:time"
import "core:path/filepath"
import "core:log"
import "core:mem"

when HOT_RELOAD {

        main :: proc() {

                ctx: runtime.Context
                track: mem.Tracking_Allocator
                callisto_context_init(&ctx, &track)
                defer callisto_context_destroy(&ctx, &track)
                context = ctx
                
                runner := default_runner() 

                opts, level := callisto_logger_options()
                fmt.println(level, opts)
                callisto_logger_init(&runner, &ctx.logger, "log", level, opts)
                defer callisto_logger_destroy(&ctx.logger)
                runner.ctx = ctx
                context    = ctx


                exe_dir, _ := get_exe_directory()
                defer delete(exe_dir)

                original_dll_path := fmt.aprintf(DLL_ORIGINAL_FMT, exe_dir)
                defer delete(original_dll_path)


                res := app_dll_load(0, exe_dir, &runner.symbols, &runner.last_modified)
                assert_messagebox(res == .Ok, "DLL load failed:", res)



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

                        // watch dll for changes
                        if timestamp, changed := watch_dll_changed(&runner, original_dll_path); changed {
                                new_runner_symbols : Dll_Symbol_Table
                                new_runner_timestamp : os.File_Time
                                new_runner_version := runner.version + 1


                                reload_res := app_dll_load(runner.version + 1, exe_dir, &new_runner_symbols, &new_runner_timestamp)
                                if reload_res == .Ok {
                                        runner.symbols       = new_runner_symbols
                                        runner.last_modified = new_runner_timestamp
                                        runner.version       = new_runner_version

                                } else {
                                        log.error("DLL reload failed", new_runner_version, ":", reload_res)
                                        runner.last_modified = timestamp
                                }
                        }
                }
               
                // destroy
                runner.symbols.callisto_destroy(runner.app_memory)
                
                if runner.exit_code != .Ok {
                        log.error("Exiting with exit code:", runner.exit_code)
                        os.exit(int(runner.exit_code))
                }
        }


        watch_dll_changed :: proc(runner: ^Runner, file_name: string) -> (timestamp: os.File_Time, changed: bool) {
                watched_modified, res := os.last_write_time_by_name(file_name)
                if res != os.ERROR_NONE  {
                        return watched_modified, false
                }

                return watched_modified, watched_modified > runner.last_modified 
        }


        // Logic from core:os/os2 - will replace with os2 version when it's stable
        copy_file :: proc(dst_path, src_path: string) -> (res: Dll_Result) {

                src, res0 := os.open(src_path)
                check_result_os(res0) or_return
                defer os.close(src)

                info, res1 := os.fstat(src)
                check_result_os(res1) or_return
                defer os.file_info_delete(info)
                if info.is_dir {
                        return .Invalid_File
                }

                dst, res2 := os.open(dst_path, os.O_RDWR | os.O_CREATE | os.O_TRUNC, int(info.mode) & 0o777)
                check_result_os(res2) or_return
                defer os.close(dst)
                
                _, io_res := io.copy(io.to_writer(os.stream_from_handle(dst)), io.to_reader(os.stream_from_handle(src)))
                if io_res != .None {
                        log.error("IO stream copy failed:", res)
                        return .IO_Error
                }
                return .Ok
        }


        app_dll_load :: proc(version_number: int, directory: string, symbols: ^Dll_Symbol_Table, timestamp: ^os.File_Time) -> (res: Dll_Result) {

                dll_copy_name := fmt.tprintf(DLL_COPY_FMT, directory, version_number)
                dll_original_name := fmt.tprintf(DLL_ORIGINAL_FMT, directory)
                log.info("Loading DLL:", dll_copy_name)

                copy_file(dll_copy_name, dll_original_name) or_return
                
                last_mod_time, err0 := os.last_write_time_by_name(dll_original_name)
                check_result_os(err0) or_return
                
                timestamp^ = last_mod_time

                _, ok := dynlib.initialize_symbols(symbols, dll_copy_name, handle_field_name="lib")
                if !ok do return .Initialize_Symbols_Failed

                return .Ok
        }


} // when HOT_RELOAD
