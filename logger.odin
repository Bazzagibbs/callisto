package callisto

import "base:runtime"
import "core:log"
import "core:io"
import "core:os"
import "core:os/os2"
import "core:path/filepath"
import "core:fmt"

Callisto_Logger_Data :: struct {
        // file_handle_a      : os.Handle,
        // file_handle_b      : os.Handle,
        file_a             : ^os2.File,
        file_b             : ^os2.File,
        dev_console_writer : io.Writer,
        file_write_size    : int,
        internal_allocator : runtime.Allocator,
}


// Initialize a logger that writes to the in-game console, stdout (if available), and two files (if a name is provided).
// The file is stored in `%localappdata%/COMPANY_NAME/APP_NAME/<file_name>.a and <file_name>.b`.
// Allocates using context allocator.
callisto_logger_init :: proc (runner: ^Runner, logger: ^log.Logger, file_name: string, level: log.Level, opts: log.Options) -> (res: Result) {
        // // Log file  
        dir := get_persistent_directory(true, context.temp_allocator)
        
        file_logger_ok := true
        
        log_a := fmt.tprintf("%s.a", file_name)
        log_b := fmt.tprintf("%s.b", file_name)
        
        path_a := filepath.join({dir, log_a}, context.temp_allocator)
        path_b := filepath.join({dir, log_b}, context.temp_allocator)


        // handle_a, err_a := os.open(path_a, os.O_WRONLY|os.O_CREATE|os.O_TRUNC)
        file_a, err_a := os2.open(path_a, {.Write, .Create, .Trunc})
        if err_a != nil {
                file_logger_ok = false
                fmt.eprintf("Failed to open", log_a)
        }
        defer if file_logger_ok == false {
                os2.close(file_a)
        }
        
        file_b, err_b := os2.open(path_b, {.Write, .Create, .Trunc})
        if err_b != nil {
                file_logger_ok = false
                fmt.eprintf("Failed to open", log_b)
        }
        defer if res != .Ok {
                os2.close(file_b)
        }

        data := new(Callisto_Logger_Data)
        data.file_a = file_a
        data.file_b = file_b

        data.dev_console_writer = {}
        
        logger.data         = data
        logger.procedure    = runner.logger_proc
        logger.lowest_level = level
        logger.options      = opts

        return .Ok
}

callisto_logger_destroy :: proc (logger: ^log.Logger) {
        data := (^Callisto_Logger_Data)(logger.data)
        os2.close(data.file_a)
        os2.close(data.file_b)
        free(data, data.internal_allocator)
}

