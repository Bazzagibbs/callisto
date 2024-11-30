package callisto_common
import "base:intrinsics"
import "base:runtime"
import "core:reflect"
import "core:strconv"
import "core:log"
import "core:fmt"

NO_INFO_VALIDATION :: #config(CALLISTO_NO_VALIDATION, false)

Validation_Rule :: union {
        Valid_Not_Nil,
        Valid_Range_Int,
        Valid_Range_Float,
}

Valid_Not_Nil :: struct {
        name  : string,
        value : rawptr,
}

Valid_Range_Int :: struct {
        name  : string,
        value : int,
        min   : Maybe(int),
        max   : Maybe(int),
}

Valid_Range_Float :: struct {
        name  : string,
        value : f32,
        min   : Maybe(f32),
        max   : Maybe(f32),
}

validate_info :: #force_inline proc (loc: runtime.Source_Code_Location, rules: ..Validation_Rule) -> (res: Result) {
        res = .Ok
        when !NO_INFO_VALIDATION {
                for rule in rules {
                        if _validate_rule(rule, loc) == false {
                                res = .Argument_Invalid
                        }
                }
        }

        return res
}


@(private)
_validate_rule :: proc(rule: Validation_Rule, loc: runtime.Source_Code_Location) -> bool {
        switch r in rule {
        case Valid_Not_Nil:
                if r.value == nil {
                        log.errorf("[VALIDATION] Required argument \"%v\" is nil", r.name, location = loc)
                        return false
                }
        case Valid_Range_Int:
                min_val := r.min.(int) or_else min(int)
                max_val := r.max.(int) or_else max(int)
                if r.value < min_val || r.value > max_val {
                        log.errorf("[VALIDATION] Argument \"%v\"(%v) is out of range %v..=%v", r.name, min_val, max_val, location = loc)
                        return false
                }
                
        case Valid_Range_Float:
                min_val := r.min.(f32) or_else min(f32)
                max_val := r.max.(f32) or_else max(f32)
                if r.value < min_val || r.value > max_val {
                        log.errorf("[VALIDATION] Argument \"%v\"(%v) is out of range %v..=%v", r.name, min_val, max_val)
                        return false
                }
                return false
        }

        return true
}
