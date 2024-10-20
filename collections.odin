package callisto

import "core:mem"

Ring_Buffer :: struct(T: typeid) {
        begin: int,
        len: int,
        backing: []T,
}

ring_buffer_make :: proc ($T: typeid, len: int, allocator := context.allocator) -> (rb: Ring_Buffer(T), error: mem.Allocator_Error) #optional_allocator_error  {
        rb = Ring_Buffer(T) {
                begin = 0,
                len = 0,
        }

        rb.backing, error = make_slice([]T, len, allocator)
        return rb, error
}

ring_buffer_delete :: proc(rb: ^Ring_Buffer($T)) {
        delete_slice(rb.backing)
}

ring_buffer_len :: #force_inline proc(rb: ^Ring_Buffer($T)) -> int {
        return rb.len
}

ring_buffer_capacity :: #force_inline proc(rb: ^Ring_Buffer($T)) -> int {
        return len(rb.backing)
}

// Fill the buffer to capacity with value `val`. Existing elements are preserved.
ring_buffer_fill :: proc(rb: ^Ring_Buffer($T), val: T) {
        empty_elems := len(rb.backing) - rb.len
        rb.len = len(rb.backing)

        #no_bounds_check for i in 0..<empty_elems {
                real_index := (rb.begin + i) % len(rb.backing)
                rb.backing[real_index] = val
        }
}

ring_buffer_clear :: proc(rb: ^Ring_Buffer($T)) {
        rb.begin = 0
        rb.len = 0
}

// Set all entries in the ring buffer to value `val`, and reset the length.
ring_buffer_clear_with_value :: proc(rb: ^Ring_Buffer($T), val: T) {
        rb.begin = 0
        rb.len = 0
        #no_bounds_check for i in 0..<len(rb.backing) {
                rb.backing[i] = value
        }
}

ring_buffer_append :: proc(rb: ^Ring_Buffer($T), elem: T) {
        #no_bounds_check if rb.len >= len(rb.backing) {
                rb.backing[rb.begin] = elem
                rb.begin = (rb.begin + 1) % len(rb.backing)
        } else {
                index := (rb.begin + rb.len) % len(rb.backing)
                rb.backing[index] = elem
                rb.len += 1
        }
}

ring_buffer_copy :: proc(dst: ^Ring_Buffer($T), src: ^Ring_Buffer(T)) {
        assert(len(dst.backing) == len(src.backing), "Ring buffer copy failed: buffer size does not match")
        mem.copy(raw_data(dst.backing), raw_data(src.backing), size_of(T) * len(src.backing))
        dst.begin = src.begin
        dst.len = src.len
}

ring_buffer_iter :: proc(rb: ^Ring_Buffer($T), counter: ^int) -> (val: ^T, has_val: bool) {
        if counter^ >= rb.len {
                return nil, false
        }

        index := (rb.begin + counter^) % len(rb.backing)
        counter^ += 1
        #no_bounds_check return &rb.backing[index], true
}
