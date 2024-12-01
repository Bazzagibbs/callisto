package callisto_common

import "base:runtime"
import "core:image"

Result :: enum {
        Ok,
        Unknown_RHI_Error,
        File_Not_Found,
        File_Invalid, // File exists but is not valid
        Argument_Invalid,
        Argument_Not_Supported, // e.g. triple-buffered vsync on some devices
        Parse_Error,
        Permission_Denied,
        No_Suitable_GPU,
        Out_Of_Memory_CPU,
        Out_Of_Memory_GPU,
        Out_Of_Disk_Storage,
        Memory_Map_Failed,
        Device_Not_Responding,
        Device_Disconnected,
        Platform_Error,
}


Engine :: struct {
        runner    : ^Runner,
        allocator : runtime.Allocator,
}


Engine_Init_Info :: struct {
        runner            : ^Runner, // required
        app_memory        : rawptr,
        icon              : ^image.Image,
        event_behaviour   : Event_Behaviour,
}


Window :: _Platform_Window

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


