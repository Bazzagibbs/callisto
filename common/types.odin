package callisto_common

import "base:runtime"
import "core:image"

Result :: enum {
        Ok,
        File_Not_Found,
        File_Invalid, // File exists but is not valid
        Argument_Invalid,
        Parse_Error,
        Permission_Denied,
        Hardware_Not_Suitable,
        Out_Of_Memory,
        Out_Of_Disk_Storage,
        Device_Not_Responding,
        Device_Disconnected,
        Platform_Error,
}


Engine :: struct {
        runner    : ^Runner,
        allocator : runtime.Allocator,
}


Engine_Init_Info :: struct {
        runner            : ^Runner,
        app_memory        : rawptr,
        icon              : ^image.Image,
        event_behaviour   : Event_Behaviour,
}


Window :: struct {
        _platform : Platform_Window,
}

Window_Init_Info :: struct {
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


