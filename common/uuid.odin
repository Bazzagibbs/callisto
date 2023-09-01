package callisto_common

import "core:math/rand"
import "core:fmt"
import "core:strings"
import "core:strconv"


Uuid :: u128be


// Generate a 128-bit Universally Unique Identifier (v4). 
// If no random number generator is provided, the global generator will be used.
generate_uuid :: proc(r: ^rand.Rand = nil) -> Uuid {
    // Algorithm from https://datatracker.ietf.org/doc/html/rfc4122#section-4.4
    // Generate random bits, then set specific bits that represent UUID version and type.
    out_uuid := transmute(Uuid)rand.uint128(r)
    
    out_uuid &= ~Uuid(0b111100000000000011 << 62) // clear bits
    out_uuid |=       0b010000000000000010 << 62  // set bits

    return out_uuid
}


// Returns the UUID as a string in `8-4-4-4-12` hexadecimal form.
// Allocates using provided allocator.
uuid_to_string :: proc(id: Uuid, allocator := context.allocator) -> string {
    bytes := transmute([16]byte)id
    ascii := make([]byte, 36, allocator)

    j := 0
    for id_byte, i in bytes {
        // Add hyphens at the correct spots
        if i == 4 || i == 6 || i == 8 || i == 10 {
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


// Parses a UUID string in `8-4-4-4-12` hexadecimal form into a binary UUID (u128be).
string_to_uuid :: proc(id_string: string) -> (id: Uuid, ok: bool) {
    (len(id_string) == 36) or_return
    first  := cast(Uuid)strconv.parse_u128_of_base(id_string[0:8],   16) or_return 
    second := cast(Uuid)strconv.parse_u128_of_base(id_string[9:13],  16) or_return
    third  := cast(Uuid)strconv.parse_u128_of_base(id_string[14:18], 16) or_return
    fourth := cast(Uuid)strconv.parse_u128_of_base(id_string[19:23], 16) or_return
    fifth  := cast(Uuid)strconv.parse_u128_of_base(id_string[24:36], 16) or_return

    id = (first  << 96) | (second << 80) | (third  << 64) | (fourth << 48) | fifth
    ok = true
    return
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






main :: proc() {
        // Generate UUID
        generated_uuid := generate_uuid()
        fmt.printf("generated binary: %128b\n", generated_uuid)
        
        generated_uuid_str := uuid_to_string(generated_uuid)
        defer delete(generated_uuid_str)
        fmt.printf("generated string: %v\n", generated_uuid_str)

        // Parse and serialize existing UUID
        example_uuid_str := "cb4a1d16-7243-4f80-bbdd-c85e9ba20dfc"
        fmt.printf("example string:   %v\n", example_uuid_str)

        parsed_uuid, ok := string_to_uuid(example_uuid_str)
        fmt.printf("parsed binary:    %128b\n", parsed_uuid)
        parsed_uuid_str := uuid_to_string(parsed_uuid)
        defer delete(parsed_uuid_str)
        fmt.printf("parsed string:    %v\n", parsed_uuid_str)
}