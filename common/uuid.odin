package callisto_common

import "core:math/rand"
import "core:fmt"
import "core:strings"
import "core:strconv"


Uuid :: u128be


// Generate a 128-bit Universally Unique Identifier (v4). 
//
// If no random number generator is provided, the global generator will be used.
//
generate_uuid :: proc(r: ^rand.Rand = nil) -> Uuid {
    // Algorithm from https://datatracker.ietf.org/doc/html/rfc4122#section-4.4

    out_uuid := transmute([16]byte)rand.uint128(r)
    // Little endian representation in memory

    // Big endian string output
    out_uuid[6] = (out_uuid[6] & 0b00001111) | 0b01000000
    out_uuid[8] = (out_uuid[8] & 0b00111111) | 0b10000000

    return transmute(Uuid)out_uuid
}


// Parses a UUID string in `8-4-4-4-12` hexadecimal form, or as a 32-digit hexadecimal number, into a binary UUID.
// 
// ```
// foo_uuid, ok1 := parse_uuid("00112233-4455-6677-8899-aabbccddeeff")
// bar_uuid, ok2 := parse_uuid("00112233445566778899aabbccddeeff")
// ```
//
parse_uuid :: proc(id_string: string) -> (value: Uuid, ok: bool) {
    switch len(id_string) {
        case 36:
            return _parse_uuid_hyphenated(id_string)
        case 32:
            return _parse_uuid_contiguous(id_string)
    }
    return {}, false
}

@(private)
_parse_uuid_hyphenated :: proc(id_string: string) -> (value: Uuid, ok: bool){
    first  := cast(Uuid)strconv.parse_u128_of_base(id_string[0:8],   16) or_return 
    second := cast(Uuid)strconv.parse_u128_of_base(id_string[9:13],  16) or_return
    third  := cast(Uuid)strconv.parse_u128_of_base(id_string[14:18], 16) or_return
    fourth := cast(Uuid)strconv.parse_u128_of_base(id_string[19:23], 16) or_return
    fifth  := cast(Uuid)strconv.parse_u128_of_base(id_string[24:36], 16) or_return

    value = (first  << 96) | (second << 80) | (third  << 64) | (fourth << 48) | fifth
    return value, true
}

@(private)
_parse_uuid_contiguous :: proc(id_string: string) -> (value: Uuid, ok: bool){
    value_le, ok1 := strconv.parse_u128_of_base(id_string, 16)
    return cast(Uuid)value_le, ok1
}

// Returns the UUID as a string in hexadecimal form.
// 
// Hex digits are formatted as `8-4-4-4-12` when `hyphenated` is true, otherwise as a 32-character string of only hexadecimal digits.
// 
// Allocates using provided allocator.
//
uuid_to_string :: proc(id: Uuid, hyphenated := true, allocator := context.allocator) -> string {
    bytes := transmute([16]byte)id
    ascii := make([]byte, 36, allocator)

    j := 0
    for id_byte, i in bytes {
        if hyphenated && (i == 4 || i == 6 || i == 8 || i == 10) {
            ascii[j] = '-'
            j += 1
        }

        ascii_octet := _byte_to_hex_octet(id_byte)
        ascii[j]     = ascii_octet[0]
        ascii[j + 1] = ascii_octet[1]
        j += 2
    }

    return string(ascii)
}

@(private)
_HEX_LOOKUP := [16]byte {
    '0', '1', '2', '3', 
    '4', '5', '6', '7',
    '8', '9', 'a', 'b',
    'c', 'd', 'e', 'f',
}

@(private)
_byte_to_hex_octet :: proc(val: byte) -> [2]byte {
    most_significant  := val >> 4
    least_significant := val & 0xF

    return [2]byte {_HEX_LOOKUP[most_significant], _HEX_LOOKUP[least_significant]}
}

/*
main :: proc() {
        // Generate UUID
        generated_uuid := generate_uuid()
        fmt.printf("generated binary: %32x\n", generated_uuid)
        generated_uuid_str := uuid_to_string(generated_uuid)
        defer delete(generated_uuid_str)
        fmt.printf("generated string: %v\n", generated_uuid_str)

        // Parse and serialize existing UUID
        example_uuid_str_hyph := "D952EB9F-7AD2-4B1B-B3CE-386735205990"
        fmt.printf("example string:   %v\n", example_uuid_str_cont)
        parsed_uuid, ok1 := parse_uuid(example_uuid_str_cont)
        fmt.printf("parsed binary:    %32x\n", parsed_uuid)
        parsed_uuid_str := uuid_to_string(parsed_uuid)
        defer delete(parsed_uuid_str)
        fmt.printf("parsed string:    %v\n", parsed_uuid_str)
        
        example_uuid_str_cont := "cb4a1d1672434f80bbddc85e9ba20dfc"
        parsed_uuid, ok2 := parse_uuid(example_uuid_str_cont)
        fmt.printf("parsed binary:    %32x\n", parsed_uuid)
        parsed_uuid_str := uuid_to_string(parsed_uuid)
        defer delete(parsed_uuid_str)
        fmt.printf("parsed string:    %v\n", parsed_uuid_str)
}
*/