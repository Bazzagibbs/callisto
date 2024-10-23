package callisto
import "core:prof/spall"
import "core:sync"
import "core:mem"
import "core:container/"

Profiler :: struct {
        ctx : spall.Context,
        buffer : spall.Buffer,
        backing : []u8,
}


profiler_init :: proc(p: ^Profiler) -> (res: Result) {
        when PROFILER {
                p.ctx = spall.context_create(PROFILER_FILE)
                p.backing = make([]u8, spall.BUFFER_DEFAULT_SIZE)
                p.buffer, _ = spall.buffer_create(p.backing)
        }
        return .Ok
}

profiler_destroy :: proc(p: ^Profiler) {
        when PROFILER {
                spall.buffer_destroy(&p.ctx, &p.buffer)
                spall.context_destroy(&p.ctx)
                delete(p.backing)
        }
}


@(deferred_in=_profile_scope_end)
profile_scope :: proc(p: ^Profiler, loc := #caller_location) {
        when PROFILER {
                spall._buffer_begin(&p.ctx, &p.buffer, loc.procedure, "", loc)
        }
}

_profile_scope_end :: proc(p: ^Profiler, loc := #caller_location) {
        when PROFILER {
                spall._buffer_end(&p.ctx, &p.buffer)
        }
}

