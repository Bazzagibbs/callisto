package callisto_runner

HOT_RELOAD :: #config(HOT_RELOAD, false)
GAME_NAME  :: #config(GAME_NAME, "game")
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
Callbacks :: struct {
        memory_manager      : #type proc(command: Memory_Command, game_memory: ^rawptr),
        init                : #type proc(game_memory: rawptr),
        loop                : #type proc(game_memory: rawptr) -> Loop_Result,
        shutdown            : #type proc(game_memory: rawptr),
}

Memory_Command :: enum {
        Allocate,
        Reset,
        Free,
}

Loop_Result :: enum {
        Ok,
        Shutdown,
        Reset_Soft,
        Reset_Hard,
}


