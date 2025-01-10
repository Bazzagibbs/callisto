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
        Swapchain_Rebuilt,
        Synchronization_Error,
}


Engine :: struct {
        runner    : ^Runner,
        allocator : runtime.Allocator,
}


Engine_Create_Info :: struct {
        runner            : ^Runner, // required
        app_memory        : rawptr,
        icon              : ^image.Image,
        event_behaviour   : Event_Behaviour,
}


Window :: struct {
        _impl : _Window_Impl,
}

Window_Create_Info :: struct {
        name     : string,
        style    : Window_Style_Flags,
        position : [2]int,
        size     : [2]int,
}

Window_Style_Flags :: bit_set[Window_Style_Flag]

Window_Style_Flag :: enum {
        Border,
        Resize_Edges,
        Menu,
        Minimize_Button,
        Maximize_Button,
}

Window_Style_Flags_DEFAULT :: Window_Style_Flags {.Border, .Resize_Edges, .Menu, .Maximize_Button, .Minimize_Button}
Window_Position_AUTO       :: [2]int{max(int), max(int)}
Window_Size_AUTO           :: [2]int{max(int), max(int)}

