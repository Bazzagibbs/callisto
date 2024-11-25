package callisto

import "base:runtime"
import "core:log"
import "core:io"
import "core:os"
import "core:os/os2"
import "core:path/filepath"
import "core:fmt"

Callisto_Logger_Data :: struct {
        file_handle_a      : os.Handle,
        file_handle_b      : os.Handle,
        dev_console_writer : io.Writer,
        file_write_size    : int,
        internal_allocator : runtime.Allocator,
}


// Initialize a logger that writes to the in-game console, stdout (if available), and a file (if provided).
// The file is stored in `%localappdata%/COMPANY_NAME/APP_NAME/<file_name>.txt`.
// Allocates using context allocator.
callisto_logger_init :: proc (runner: ^Runner, logger: ^log.Logger, file_name: string, level: log.Level, opts: log.Options) -> (res: Result) {
        // // Log file  
        // dir := get_persistent_directory(context.temp_allocator) or_return
        // os2.make_directory_all(dir)
        //
        // log_a := fmt.tprintf("%s_a.txt", file_name)
        // log_b := fmt.tprintf("%s_b.txt", file_name)
        //
        // path_a := filepath.join({dir, log_a}, context.temp_allocator)
        // path_b := filepath.join({dir, log_b}, context.temp_allocator)

        // handle_a, err_a := os.open(path_a, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
        // if err_a != os.ERROR_NONE {
        //         return .File_Invalid
        // }
        // defer if res != .Ok {
        //         os.close(handle_a)
        // }
        // 
        // handle_b, err_b := os.open(path_b, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
        // if err_b != os.ERROR_NONE {
        //         return .File_Invalid
        // }
        // defer if res != .Ok {
        //         os.close(handle_b)
        // }

        data := new(Callisto_Logger_Data)
        // data.file_handle_a = handle_a
        // data.file_handle_b = handle_b
        data.dev_console_writer = {}
        
        logger.data         = data
        logger.procedure    = runner.logger_proc
        logger.lowest_level = level
        logger.options      = opts

        return .Ok
}

callisto_logger_destroy :: proc (logger: ^log.Logger) {
        data := (^Callisto_Logger_Data)(logger.data)
        os.close(data.file_handle_a)
        os.close(data.file_handle_b)
        free(data, data.internal_allocator)
}

callisto_logger_proc :: proc (logger_data: rawptr, level: log.Level, options: log.Options, location := #caller_location){
        data := (^Callisto_Logger_Data)(logger_data)
}

// @(private)
// _callisto_logger_do_
