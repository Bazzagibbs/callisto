package callisto_debug

import "core:prof/spall"
import "../config"
import "core:fmt"
import "core:path/filepath"

when config.DEBUG_PROFILER_ENABLED {
    spall_ctx               : spall.Context
    spall_buffer            : spall.Buffer
    spall_buffer_backing    : []u8
}

create_profiler :: proc() {
    when config.DEBUG_PROFILER_ENABLED {
        spall_ctx = spall.context_create(config.DEBUG_PROFILER_OUTPUT_FILE)
        spall_buffer_backing = make([]u8, spall.BUFFER_DEFAULT_SIZE)
        spall_buffer = spall.buffer_create(spall_buffer_backing)
    }
}

destroy_profiler :: proc() {
    when config.DEBUG_PROFILER_ENABLED {
        spall.buffer_destroy(&spall_ctx, &spall_buffer)
        spall.context_destroy(&spall_ctx)
        delete(spall_buffer_backing)
    }
}

// Trace this scope as an event.`
@(deferred_none=_profile_scope_end)
profile_scope :: proc(loc := #caller_location) {
    when config.DEBUG_PROFILER_ENABLED {
        scope_name := fmt.aprint(loc.procedure, ":", filepath.base(loc.file_path))
        spall._buffer_begin(&spall_ctx, &spall_buffer, scope_name, "", loc)
        delete(scope_name)
    }
}

_profile_scope_end :: proc() {
    when config.DEBUG_PROFILER_ENABLED {
        spall._buffer_end(&spall_ctx, &spall_buffer)
    }
}