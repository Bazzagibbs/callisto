#+private
package callisto_runner

import "base:runtime"
import "core:mem"
import "core:log"
import "core:fmt"

_callisto_context :: proc "contextless" () -> (ctx: runtime.Context, track: ^mem.Tracking_Allocator) {
        ctx = runtime.default_context()
        context = ctx

        when ODIN_DEBUG {
                // Tracking allocator
                track = new(mem.Tracking_Allocator)
                mem.tracking_allocator_init(track, ctx.allocator, ctx.allocator)
                ctx.allocator = mem.tracking_allocator(track)
        }

        // TODO: File/virtual console logger when !ODIN_DEBUG

        // Console logger
        opts := log.Options {
                .Terminal_Color,
                .Level,
                .Time,
                .Line,
                .Procedure,
                .Short_File_Path,
        }
        ctx.logger = log.create_console_logger(.Debug, opts)


        return ctx, track
}


_callisto_context_end :: proc "contextless" (ctx: runtime.Context, track: ^mem.Tracking_Allocator) {
        context = ctx

        when ODIN_DEBUG {
                for _, leak in track.allocation_map {
                        // fmt.eprintf("%v leaked %m\n", leak.location, leak.size)
                        // fmt.println(leak.location, "leaked", leak.size)
                        fmt.println("leaked", leak.size)
                }
                for bad_free in track.bad_free_array {
                        fmt.eprintf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
                }

                mem.tracking_allocator_destroy(track)
        }

        log.destroy_console_logger(ctx.logger)
}

