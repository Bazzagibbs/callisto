package callisto_editor

import "slang"
import "core:strings"
import "core:log"
import "core:fmt"


Slang_Walker :: struct {
        indent           : int,
        sb               : strings.Builder,
        newline          : bool,

        samplers         : int,
        storage_textures : int,
        storage_buffers  : int,
        uniform_buffers  : int,
}



@(deferred_in=_slang_walker_scoped_end)
slang_walker_scoped :: proc(w: ^Slang_Walker) {
        w.indent += 1
}

_slang_walker_scoped_end :: proc(w: ^Slang_Walker) {
        w.indent -= 1
}

slang_print :: proc(w: ^Slang_Walker, args: ..any) {
        if w.newline {
                for i in 0..<w.indent {
                        fmt.sbprint(&w.sb, "\t")
                }
                w.newline = false
        }
        fmt.sbprint(&w.sb, ..args, sep = "")
}

slang_println :: proc(w: ^Slang_Walker, args: ..any) {
        if w.newline {
                for i in 0..<w.indent {
                        fmt.sbprint(&w.sb, "\t")
                }
        }
        fmt.sbprintln(&w.sb, ..args, sep = "")
        w.newline = true
}

slang_print_endline :: proc(w: ^Slang_Walker) {
        fmt.sbprint(&w.sb, "\n")
        w.newline = true
}


// =================

slang_walk_program :: proc(reflection: ^slang.Reflection) {
        w: Slang_Walker
        w.sb, _ = strings.builder_make()
        defer strings.builder_destroy(&w.sb)

        // Start building descriptor set layout
        // Add global scope parameters
        // Add entry point parameters
        // Finish building descriptor set layout
        // Finish building pipeline layout

        slang_walk_global_scope(&w, slang.Reflection_getGlobalParamsVarLayout(reflection))
        slang_walk_entry_point(&w, slang.Reflection_getEntryPointByIndex(reflection, 0))


        log.debug("REFLECTION:\n\n", strings.to_string(w.sb), sep = "")
        log.debug("\nsamplers:", w.samplers, 
                "\nstorage textures:", w.storage_textures,
                "\nstorage buffers:", w.storage_buffers,
                "\nuniform buffers:", w.uniform_buffers)
}


slang_walk_global_scope :: proc(w: ^Slang_Walker, refl: ^slang.VariableLayoutReflection) {
        var_refl := slang.ReflectionVariableLayout_GetVariable(refl)
        type_layout := slang.ReflectionVariableLayout_GetTypeLayout(refl)

        kind := slang.ReflectionTypeLayout_getKind(type_layout)

        slang_println(w, "__global :: ", kind, " {")
        
        // UNFINISHED
        #partial switch kind {
        case .STRUCT:
                count := slang.ReflectionTypeLayout_GetFieldCount(type_layout)
                for i in 0..<count {
                        field_layout := slang.ReflectionTypeLayout_GetFieldByIndex(type_layout, i)
                        slang_walk_variable_layout(w, field_layout)
                }

        case .CONSTANT_BUFFER:
        case .PARAMETER_BLOCK:
        case: 
        }

        slang_println(w, "}")
}


slang_walk_entry_point :: proc(w: ^Slang_Walker, refl: ^slang.EntryPointReflection) {
}

// slang_walk_ :: proc(w: ^Slang_Walker, refl: ^slang.) {
//
// }

// slang_walk_type :: proc(w: ^Slang_Walker, refl: ^slang.TypeReflection) {
//         slang_walker_scoped(w)
//         kind := slang.ReflectionType_GetKind(refl)
//         slang_println(w, slang.ReflectionType_GetName(refl), " : ", kind, ",")
//         // slang_print(w, slang.ReflectionType_GetName(refl))
//
//         // UNFINISHED
//         #partial switch kind {
//
//         }
// }

slang_walk_variable_layout :: proc(w: ^Slang_Walker, refl: ^slang.VariableLayoutReflection) {
        slang_walker_scoped(w)

        var_refl := slang.ReflectionVariableLayout_GetVariable(refl)
        type := slang.ReflectionVariable_GetType(var_refl)
        
        slang_println(w, slang.ReflectionVariable_GetName(var_refl), " : ", slang.ReflectionType_GetName(type), ",")
}


slang_walk_type_layout :: proc(w: ^Slang_Walker, refl: ^slang.TypeLayoutReflection) {

}
