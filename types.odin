package callisto
import "runner"

Result :: enum {
        Ok,
        File_Not_Found,
        File_Invalid, // File exists but is not valid
        Parse_Error,
        Permission_Denied,
        Hardware_Not_Suitable,
        Out_Of_Memory,
        Out_Of_Disk_Storage,
        Device_Not_Responding,
        Device_Disconnected,
        Platform_Error,
}

// `event_handler`: Called when there is a platform event to be consumed. 
// The default event hander (`callisto.event_handler`) can be used, or events can be passed through a custom dispatcher first.
//
// `memory_manager`: Called when the game memory needs to be modified.
// `command` is an enum that determines what should be done with the parameter `game_memory`.
//      - `.Allocate`: The parameter stores a nil pointer. Allocate a game memory struct, and set the value of `game_memory` to this pointer.
//      - `.Reset`: The parameter stores a pointer to the existing game memory to be reset. Either free and reallocate it, or modify the values manually.
//      - `.Free`: The parameter stores a pointer to the existing game memory which needs to be freed.
//
// `init`: Called when the game is started, and when the game is reset.
//
// `loop`: Called when the platform is ready to process a frame. 
//
// `shutdown`: Called before the game is closed gracefully, either on shutdown or reset.
Callbacks :: runner.Callbacks

Memory_Command :: runner.Memory_Command

Loop_Result :: runner.Loop_Result

Handle :: distinct uintptr
