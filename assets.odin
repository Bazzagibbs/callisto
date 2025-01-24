package callisto

import "base:intrinsics"
import "core:math/linalg"
import "core:path/filepath"
import "core:strings"
import "common"
import "gpu"

// Serializable reference to an asset on disk. Once loaded, can be resolved to a `Reference(T)`.
Reference_Info :: struct($T: typeid) {
        asset_id : Uuid,
}

Construct_Create_Info :: struct {
        transforms : []Transform,
        attachments : []Attachment_Info,
}

Attachment_Info :: struct {
        transform_index: int,
        // Some other data that refers to this transform
}


// On reload this will be reacquired.
@(private) 
_exe_dir_buffer : [4096]byte // Linux length, windows is ~256
@(private)
_exe_dir : string

get_asset_path :: proc(filename: string, allocator := context.allocator) -> string {
        if _exe_dir == {} {
                sb := strings.builder_from_bytes(_exe_dir_buffer[:])
                strings.write_string(&sb, get_exe_directory(context.temp_allocator))
                _exe_dir = strings.to_string(sb)
        }
        
        return filepath.join({_exe_dir, "data", "assets", filename}, allocator)
}

// Convert a Reference into a struct pointer of an element in `collection`.
reference_resolve :: proc(collection: ^$A, ref: $R/Reference($T)) -> ^T 
                where intrinsics.type_is_indexable(A) && intrinsics.type_elem_type(A) == T
        {

        return &collection[ref.runtime_id]
}

// When a transform within this construct is modified, it is marked as 'dirty' as well as all its children and must be recalculated.
construct_recalculate_matrices :: proc(c: ^Construct) -> (changed: bool) {
        changed = false

        for &t, i in c.transforms {
                if .Dirty not_in t.flags {
                        continue
                }

                c.local_matrices[i] = linalg.matrix4_from_trs_f32(t.local_position, t.local_rotation, t.local_scale)
                if t.parent_index == -1 {
                        c.world_matrices[i] = c.local_matrices[i]
                } else {
                        c.world_matrices[i] = c.world_matrices[t.parent_index] * c.local_matrices[i]
                }
                t.flags -= {.Dirty}
                changed = true
        }

        return changed
}

Uuid          :: common.Uuid
uuid_generate :: common.uuid_generate
