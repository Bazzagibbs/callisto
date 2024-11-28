package callisto_serial

import "base:intrinsics"
import "core:relative"
import "core:io"


Relative_String :: struct($Backing: typeid) 
        where intrinsics.type_is_integer(Backing) {

        slice : relative.Slice([]u8, Backing),
}

@(require_results)
relative_string_get :: proc "contextless" (p: Relative_String($Backing)) -> string {
        return string(relative.slice_get(p.slice))
}


relative_string_set :: proc "contextless" (p: ^Relative_String($Backing), str: string) {
        relative.slice_set(&p.slice, transmute([]u8)str)
}

@(require_results)
relative_string_set_safe :: proc "contextless" (p: ^Relative_String($Backing), str: string) -> relative.Set_Safe_Error {
        return relative.slice_set_safe(&p.slice, transmute([]u8)str)
}



Inline_String :: struct($Backing: typeid) 
        where intrinsics.type_is_integer(Backing) {

        length: Backing
}

@(require_results)
inline_string_get :: proc "contextless" (p: Inline_String($Backing), cursor: ^int = nil) -> string {
        if cursor != nil {
                cursor += p.length
        }

        return string {
                data = (uintptr)(&p) + size_of(Backing),
                len  = int(p.length),
        }
}

inline_string_write :: proc "contextless" ($T: typeid/Inline_String($Backing), w: io.Writer, str: string) -> io.Error {
        length := Backing(len(str))
        io.write_ptr(w, &length, size_of(Backing)) or_return
        return io.write_string(w, str)
}
