package callisto_importer

import "core:os"
import "core:strings"
import "core:text/scanner"
import "core:bytes"
import "core:strconv"
import "core:unicode"
import "core:log"
import "../asset"

Obj_Token_Kind :: enum {
    comment,            // # -> eol
    continuation,       // \
    number,             // 0.123 or 1
   
    // Vertex data 
    vertex,             // v
    tex_coord,          // vt
    normal,             // vn
    // param_space,        // vp       // NOT SUPPORTED
   
    // Elements 
    face,               // f
    // point,              // p        // NOT SUPPORTED
    // line,               // l        // NOT SUPPORTED
    // curve,              // curv     // NOT SUPPORTED
    // curve_2d,           // curv     // NOT SUPPORTED
    // surface,            // surf     // NOT SUPPORTED
    
    // Free-form curve/surface attributes
    // curve_surf_type,    // cstype   // NOT_SUPPORTED
    // degree,             // deg      // NOT SUPPORTED
    // basis_matrix,       // bmat     // NOT SUPPORTED
    // step_size,          // step     // NOT SUPPORTED

    // Free-form curve/surface body statements
    // param_val,          // parm     // NOT SUPPORTED
    // outer_trim_loop,    // trim     // NOT SUPPORTED
    // inner_trim_loop,    // hole     // NOT SUPPORTED
    // special_curve,      // scrv     // NOT SUPPORTED
    // special_point,      // sp       // NOT SUPPORTED
    // end_statement,      // end      // NOT SUPPORTED

    // Connectivity between free-form surfaces
    // connect,            // con      // NOT SUPPORTED

    // Grouping
    group_name,         // g
    smoothing_group,    // s
    merging_group,      // mg
    object_name,        // o

    // Display/render attributes
    // bevel_interp,               // bevel        // NOT SUPPORTED
    // color_interp,               // c_interp     // NOT SUPPORTED
    // dissolve_interp,            // d_interp     // NOT SUPPORTED
    // level_of_detail,            // lod          // NOT SUPPORTED
    material_name,              // usemtl       
    material_library,           // mtllib       
    // shadow_casting,             // shadow_obj   // NOT SUPPORTED
    // ray_tracing,                // trace_obj    // NOT SUPPORTED
    // curve_approx_technique,     // ctech        // NOT SUPPORTED
    // surface_approx_technique,   // stech        // NOT SUPPORTED
}

 
parse_obj_data :: proc(data: []byte) -> (mesh_asset: asset.Mesh, material_asset: asset.Material, ok: bool) {
    // Faces may be n-gons in the obj file, need to triangulate


    data_str := string(data)
    
    s: scanner.Scanner
    scanner.init(&s, data_str)
    s.flags = {.Scan_Floats, .Scan_Ints, .Scan_Idents}
    s.is_ident_rune = _is_obj_ident_rune
    s.error = _obj_log_error
    log.info("Starting parse")
    for tok := scanner.scan(&s); tok != scanner.EOF; {
        log.info(scanner.token_text(&s), " ")
    }

    return {}, {}, false
}


@(private)
_is_obj_ident_rune :: proc(ch: rune, i: int) -> bool {
    return ch == '_' || unicode.is_letter(ch)
}

@(private)
_obj_log_error :: proc(s: ^scanner.Scanner, message: string) {
    log.error("Error parsing .obj file:", message)
}
