package callisto_runner

// `memory_init`: Called only the first time the game is started, or on a hard reset. 
// Callback should return an allocated struct containing the game's memory.
// Use this procedure to set up persistent systems such as window, input, renderer etc.
//
// `memory_load`: Called after a hot reload, when gameplay code has changed but the game state is identical. 
//
// `memory_reset`: Called if the runner requests the game to be reset.
// Callback should return a struct containing the game's state after a reset.
// Callback may reuse the old memory allocation if desired, or create a new allocation and free the old one.
//
// `memory_shutdown`: Called when the game is closed.
// Callback should free the game's memory as allocated in `memory_init` or `memory_reset`.
//
// `game_init`: Called after `memory_init` and `memory_reset`.
// Use this procedure to set up gameplay state using the game memory. Persistent systems should be set up in `memory_init` instead.
//
// `game_render`: Called when the platform is ready to process a frame. 
Runner_Callbacks :: struct {
        memory_init         : #type proc() -> (game_memory: rawptr),
        memory_load         : #type proc(game_memory: rawptr),
        memory_reset        : #type proc(old_memory: rawptr) -> (new_memory: rawptr),
        memory_shutdown     : #type proc(game_memory: rawptr),
        game_init           : #type proc(),
        game_render         : #type proc() -> Runner_Control,
}

Runner_Control :: enum {
        Ok,
        Shutdown,
        Reset_Soft,
        Reset_Hard,
}
