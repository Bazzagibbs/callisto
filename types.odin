package callisto

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
