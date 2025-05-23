package circular_buffer

import "base:builtin"

Circular_Buffer :: struct($N: int, $T: typeid) where N >= 0 {
        data  : [N]T,
        len   : int,
        begin : int,
}


len :: proc "contextless" (b: $B/Circular_Buffer) -> int {
        return b.len
}


cap :: proc "contextless" (b: $B/Circular_Buffer) -> int {
        return builtin.len(b.data)
}


space :: proc "contextless" (b: $B/Circular_Buffer) -> int {
        return builtin.len(b.data) - b.len
}


get :: proc "contextless" (b: $B/Circular_Buffer($N, $T), index: int) -> T {
        i := _resolve_index(index, b.begin, builtin.len(b.data))
        return b.data[i]
}

get_ptr :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), index: int) -> ^T {
        i := _resolve_index(index, b.begin, builtin.len(b.data))
        return &b.data[i]
}


get_safe :: proc "contextless" (b: $B/Circular_Buffer($N, $T), index: int) -> (value: T, ok: bool) #no_bounds_check {
        if index < 0 || index >= b.len {
                return {}, false
        }

        i := _resolve_index(index, b.begin, builtin.len(b.data))
        return b.data[i], true
}


get_ptr_safe :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), index: int) -> (value: ^T, ok: bool) #no_bounds_check {
        if index < 0 || index >= b.len {
                return nil, false
        }

        i := _resolve_index(index, b.begin, builtin.len(b.data))
        return &b.data[i]
}


push_front :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), item: T) {
        b.len = min(b.len + 1, builtin.len(b.data))

        if b.begin <= 0 {
                b.begin = builtin.len(b.data) - 1
        } else {
                b.begin -= 1
        }

        b.data[b.begin] = item
}


push_back :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), item: T) {
        if b.len < builtin.len(b.data) {
                b.len += 1
        } else {
                b.begin += 1
                if b.begin >= builtin.len(b.data) {
                        b.begin = 0
                }
        }
        
        i := _resolve_index(b.len - 1, b.begin, builtin.len(b.data))
        b.data[i] = item
}


pop_front :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T)) -> (value: T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }

        value = b.data[b.begin]

        b.len -= 1
        b.begin += 1
        if b.begin >= builtin.len(b.data) {
                b.begin = 0
        }
        return value, true
}

pop_back :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T)) -> (value: T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }

        i := _resolve_index(b.len - 1, b.begin, builtin.len(b.data))
        value = b.data[i]
        b.len -= 1

        return value, true
}


peek_front :: proc "contextless" (b: $B/Circular_Buffer($N, $T)) -> (value: T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }

        return b.data[b.begin], true
}

peek_back :: proc "contextless" (b: $B/Circular_Buffer($N, $T)) -> (value: T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }

        i := _resolve_index(b.len - 1, b.begin, builtin.len(b.data))
        return b.data[i]
}


peek_front_ptr :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T)) -> (value: ^T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }

        return &b.data[b.begin]
}

peek_back_ptr :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T)) -> (value: ^T, ok: bool) {
        if b.len <= 0 {
                return {}, false
        }
        
        i := _resolve_index(b.len - 1, b.begin, builtin.len(b.data^))
        return &b.data[i]
}


clear :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T)) { 
        b.len = 0
        b.begin = 0
}

iterate :: proc "contextless" (b: $B/Circular_Buffer($N, $T), cursor: ^int) -> (value: T, has_value: bool) {
        if cursor^ >= b.len {
                return {}, false
        }

        i := _resolve_index(cursor^, b.begin, builtin.len(b.data))
        value = b.data[i]
        has_value = true

        cursor^ += 1
        return
}

iterate_reverse :: proc "contextless" (b: $B/Circular_Buffer($N, $T), cursor: ^int) -> (value: T, has_value: bool) {
        if cursor^ >= b.len {
                return {}, false
        }

        i := (b.begin + (b.len - cursor)) % builtin.len(b.data)
        value = b.data[i]
        has_value = true

        cursor^ += 1
        return
}

iterate_ptr :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), cursor: ^int) -> (value: ^T, has_value: bool) {
        if cursor^ >= b.len {
                return {}, false
        }

        i := _resolve_index(cursor^, b.begin, builtin.len(b.data))
        value = &b.data[i]
        has_value = true

        cursor^ += 1
        return

}


iterate_reverse_ptr :: proc "contextless" (b: ^$B/Circular_Buffer($N, $T), cursor: ^int) -> (value: ^T, has_value: bool) {
        if cursor^ >= b.len {
                return {}, false
        }

        i := (b.begin + (b.len - cursor)) % builtin.len(b.data)
        value = &b.data[i]
        has_value = true

        cursor^ += 1
        return
}


@(private)
_resolve_index :: #force_inline proc "contextless" (index, begin, cap: int) -> int {
        return (begin + index) % cap
}


push   :: push_back
append :: push_back
pop    :: pop_back
