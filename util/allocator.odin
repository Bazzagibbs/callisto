package callisto_util

import "core:mem"
import "core:log"

create_tracking_allocator :: proc(backing_allocator: mem.Allocator = context.allocator) -> (track: mem.Tracking_Allocator) {
    mem.tracking_allocator_init(&track, backing_allocator)
    return
}

destroy_tracking_allocator :: proc(track: ^mem.Tracking_Allocator) {
    for _, leak in track.allocation_map {
        log.errorf("%v leaked %v bytes\n", leak.location, leak.size)
    }
    for bad_free in track.bad_free_array {
        log.errorf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
    }

    mem.tracking_allocator_destroy(track)
}