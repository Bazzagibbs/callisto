package callisto_common
import "core:prof/spall"
import "core:sync"
import "core:mem"
import "../config"

// TODO: maybe roll my own that's better suited for realtime?
Profiler :: struct {
        ctx : spall.Context,
        buffer : spall.Buffer,
        backing : []u8,
}


profiler_init :: proc(p: ^Profiler) -> (res: Result) {
        when config.PROFILER_ENABLED {
                p.ctx = spall.context_create(config.PROFILER_FILE)
                p.backing = make([]u8, spall.BUFFER_DEFAULT_SIZE)
                p.buffer, _ = spall.buffer_create(p.backing)
        }
        return .Ok
}

profiler_destroy :: proc(p: ^Profiler) {
        when config.PROFILER_ENABLED {
                spall.buffer_destroy(&p.ctx, &p.buffer)
                spall.context_destroy(&p.ctx)
                delete(p.backing)
        }
}

profile_scope :: proc {
        profile_scope_runner,
        profile_scope_profiler,
}


@(deferred_in=_profile_scope_runner_end)
profile_scope_runner :: proc(r: ^Runner, loc := #caller_location) {
        when config.PROFILER_ENABLED {
                spall._buffer_begin(&r.profiler.ctx, &r.profiler.buffer, loc.procedure, "", loc)
        }
}

_profile_scope_runner_end :: proc(r: ^Runner, loc := #caller_location) {
        when config.PROFILER_ENABLED {
                spall._buffer_end(&r.profiler.ctx, &r.profiler.buffer)
        }
}


@(deferred_in=_profile_scope_profiler_end)
profile_scope_profiler :: proc(p: ^Profiler, loc := #caller_location) {
        when config.PROFILER_ENABLED {
                spall._buffer_begin(&p.ctx, &p.buffer, loc.procedure, "", loc)
        }
}

_profile_scope_profiler_end :: proc(p: ^Profiler, loc := #caller_location) {
        when config.PROFILER_ENABLED {
                spall._buffer_end(&p.ctx, &p.buffer)
        }
}

