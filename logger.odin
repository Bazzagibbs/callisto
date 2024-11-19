package callisto

import "core:log"
import "core:io"
import "core:os"

Callisto_Logger_Data :: struct {
        // console_writer     : io.Writer, // Write to virtual console (tilde)
        file_handle           : os.Handle,
        write_to_stdout       : bool,
}


// Initialize a logger that writes to the in-game console, stdout (if available), and a file (if provided).
// The file is stored in `%localappdata%/COMPANY_NAME/APP_NAME/<file_name>.txt`.
// Allocates using context allocator.
callisto_logger_init :: proc (logger: ^log.Logger, file_name: string) {
        
}

callisto_logger_destroy :: proc (logger: ^log.Logger) {

}

callisto_logger_proc :: proc (logger_data: rawptr, level: log.Level, options: log.Options, location := #caller_location){
        data := (^Callisto_Logger_Data)(logger_data)
}

// @(private)
// _callisto_logger_do_
