package callisto
import "base:intrinsics"
import "base:runtime"
import "core:reflect"
import "core:strconv"
import "core:log"
import "core:fmt"

NO_INFO_VALIDATION :: #config(CALLISTO_NO_VALIDATION, false)

// Not implemented
validate_info :: #force_inline proc (info: ^$T, loc := #caller_location) -> Result {
        return .Ok
}

/*
// Info structs can be annotated with tags to validate correct usage.
// By default, zero values for numbers and pointers are invalid usage.
// - `cal_info:"optional"` - the zero value of the field is valid usage.
// - `cal_range:"[min],[max]" - numbers that fall outside this inclusive range are invalid (unless `cal_info:"allow_zero"` is also set, then zero is always valid).
@(private)
validate_info :: proc (info: ^$T, loc := #caller_location) -> Result 
        where intrinsics.type_is_struct(T) {
        
        result := Result.Ok

        // cbor.marshal_into_encoder()
        when !NO_INFO_VALIDATION {
                result = _validate_struct(info, loc)
        }

        return result
}


@(private)
_validate_struct :: proc (v: any, loc: runtime.Source_Code_Location) -> Result {
        if info == nil {
                log.error("Missing struct", T, location = loc)
                return .Argument_Invalid
        }

        ti := type_info_of(T).variant.(runtime.Type_Info_Struct)
                for i in 0..<ti.field_count {
                        data := rawptr(uintptr(info) + ti.offsets[i])
                        id := ti.types[i].id
                        field_any := any {data, id}

                        #partial switch info in ti.types[i]{
                        case runtime.Type_Info_Pointer:
                        case runtime.Type_Info_Integer:
                        case runtime.Type_Info_Float:
                        case runtime.Type_Info_Array:
                        case runtime.Type_Info_Struct:
                        }
                }
        }

}

@(private)
_validate_pointer :: proc (v: any, loc: runtime.Source_Code_Location) -> Result {}
@(private)
_validate_integer :: proc (v: any, loc: runtime.Source_Code_Location) -> Result {}
@(private)
_validate_float :: proc (v: any, loc: runtime.Source_Code_Location) -> Result {}
*/
