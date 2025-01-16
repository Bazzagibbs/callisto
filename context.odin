package callisto

import "base:runtime"
import "core:mem"
import "core:log"
import "core:fmt"
import "config"

callisto_context_init :: proc "contextless" (ctx: ^runtime.Context, track: ^mem.Tracking_Allocator) -> Result {
        ctx^ = runtime.default_context()
        context = ctx^


        when ODIN_DEBUG {
                // Tracking allocator
                mem.tracking_allocator_init(track, context.allocator, context.allocator)
                context.allocator = mem.tracking_allocator(track)
        }

        return .Ok
}


callisto_context_destroy :: proc "contextless" (ctx: ^runtime.Context, track: ^mem.Tracking_Allocator) {
        context = ctx^

        when ODIN_DEBUG {
                for _, leak in track.allocation_map {
                        log.errorf("%v %v leaked %m\n", leak.location, leak.location.procedure, leak.size)
                }
                for bad_free in track.bad_free_array {
                        log.errorf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
                }

                mem.tracking_allocator_destroy(track)
        }

        log.destroy_console_logger(ctx.logger)
        // callisto_logger_destroy(&ctx.logger)
}



Logger_Options_DEFAULT :: log.Options {
        .Terminal_Color,
        .Level,
        .Time,
        .Line,
        // .Procedure,
        .Short_File_Path,
}

when config.VERBOSE {
        Logger_Level_DEFAULT :: log.Level.Debug
} else {
        Logger_Level_DEFAULT :: log.Level.Info
}
