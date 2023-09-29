package mikktspace

import "core:math/linalg"
import "core:c"

when ODIN_OS == .Windows {
    foreign import mikktspace "windows/mikktspace.lib"
} else when ODIN_OS == .Linux {
    foreign import mikktspace "linux/mikktspace.a"
} else when ODIN_OS == .Darwin {
    when ODIN_ARCH == .arm64 {
        foreign import mikktspace "macos-arm64/mikktspace.a"
    } else {
        foreign import mikktspace "macos/mikktspace.a"        
    }
} else {
    // TODO: figure out way to use host platform's import for emscripten builds
    foreign import mikktspace "windows/mikktspace.lib"
}



vec2 :: [2]f32
vec3 :: [3]f32

Context :: struct {
    interface : Interface,
    user_data : rawptr,
}

// Implement this interface for any mesh layout
Interface :: struct {
    get_num_faces               : proc(ctx: ^Context) -> int,
    get_num_vertices_of_face    : proc(ctx: ^Context, face: int) -> int,
    get_position                : proc(ctx: ^Context, face, vert: int) -> vec3,
    get_normal                  : proc(ctx: ^Context, face, vert: int) -> vec3,
    get_tex_coord               : proc(ctx: ^Context, face, vert: int) -> vec2,
    set_tangent_space_basic     : proc(ctx: ^Context, tangent: vec3, sign: f32, face, vert: int),
    set_tangent_space           : proc(ctx: ^Context, tangent, bitangent: vec3, mag_s, mag_t: f32, is_orientation_preserving: bool, face, vert: int),
}

generate_tangent_space :: proc {
    generate_tangent_space_default,
    generate_tangent_space_threshold,
}

// =======================================================================================

generate_tangent_space_default :: proc(ctx: ^Context) -> bool {
    return generate_tangent_space_threshold(ctx, 180)
}

generate_tangent_space_threshold :: proc(ctx: ^Context, angular_threshold: f32) -> bool {
    panic("Not implemented")
}

// =======================================================================================

Sub_Group :: struct {
    faces_count     : int,
    tri_members     : ^int,
    // tri_members     : [3]int,
}

Group :: struct {
    faces_count             : int,
    face_indices            : ^int,
    // face_indices            : []int,
    vertex_representative   : int,
    orientation_preserving  : bool,
} 

Tri_Info :: struct {
    o_s, o_t                : vec3,     // normalized first order face derivatives
    mag_s, mag_t            : f32,      // original magnitudes
    org_face_number         : int,      // determines if the current and next triangle are a quad
    flags                   : Tri_Info_Flags,
    tangent_space_offsets   : int,
    vert_num                : u8,
}

Tri_Info_Flags :: bit_set[Tri_Info_Flag]

Tri_Info_Flag :: enum {
    MARK_DEGENERATE,
    QUAD_ONE_DEGENERATE_TRI,
    GROUP_WITH_ANY,
    ORIENTATION_PRESERVING,
}

Tangent_Space :: struct {
    o_s, o_t        : vec3,
    mag_s, mag_t    : f32,
    counter         : int,      // this is to average back into quads
    orientation     : bool,
}

// =======================================================================================
