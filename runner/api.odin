package callisto_runner

// `memory_init`: Called the first time the game is started. 
// Callback should return an allocated struct containing the game's memory.
//
// `memory_load`: Called after a hot reload, when gameplay code has changed but the game state is identical. 
//
// `memory_reset`: Called if the runner requests the game to be reset.
// Callback should return a struct containing the game's state after a reset.
// Callback may reuse the old memory allocation if desired, or create a new allocation and free the old one.
//
// `memory_shutdown`: Called when the game is closed.
// Callback should free the game's memory as allocated in `init` or `reset`.
//
// `poll_runner_control`: Called to check if the application wants to control the runner.
// Options include: `.Shutdown`, `.Reset_Soft` (only resets the game memory), `.Reset_Hard` (ends the game, then restarts the game)
//
// `render`: Called when the platform is ready to process a frame. 
Runner_Callbacks :: struct {
        memory_init         : #type proc() -> (game_memory: rawptr),
        memory_load         : #type proc(game_memory: rawptr),
        memory_reset        : #type proc(old_memory: rawptr) -> (new_memory: rawptr),
        memory_shutdown     : #type proc(game_memory: rawptr),
        poll_runner_control : #type proc() -> Runner_Control_Flags,
        render              : #type proc(),
}

Runner_Control_Flag :: enum {
        Shutdown,
        Reset_Soft,
        Reset_Hard,
}

Runner_Control_Flags :: bit_set[Runner_Control_Flag]
