package callisto_runner

HOT_RELOAD :: #config(HOT_RELOAD, false)
GAME_NAME  :: #config(GAME_NAME, "game")

Result :: enum {
        Ok,
        Error,
}

Callbacks :: struct {
        event_handler          : #type proc() -> (),
        memory_manager         : #type proc(command: Memory_Command, game_memory: ^rawptr),
        init                   : #type proc(game_memory: rawptr),
        loop                   : #type proc(game_memory: rawptr) -> Loop_Result,
        shutdown               : #type proc(game_memory: rawptr),
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

