package callisto

Window_Create_Info :: struct {
        name     : string,
        style    : Window_Style_Flags,
        position : Maybe([2]int),
        size     : Maybe([2]int),
}

Window_Style_Flags :: bit_set[Window_Style_Flag]

Window_Style_Flag :: enum {
        Border,
        Resize_Edges,
        Menu,
        Minimize_Button,
        Maximize_Button,
}

window_style_default :: #force_inline proc "contextless" () -> Window_Style_Flags {
        return {.Border, .Resize_Edges, .Menu, .Maximize_Button, .Minimize_Button}
}

