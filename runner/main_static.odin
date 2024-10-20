package callisto_runner
import "base:runtime"

// The main game loop for standalone builds
run :: proc "contextless" (callbacks: Callbacks) {
        ctx, track := _callisto_context() 
        defer _callisto_context_end(ctx, track)
        context = ctx

        game_mem: rawptr

        callbacks.memory_manager(.Allocate, &game_mem)
        callbacks.init(game_mem)

        // init platform

        gameloop:
        for {
                ctl := callbacks.loop(game_mem)
                #partial switch ctl {
                case .Shutdown, .Reset_Hard: 
                        break gameloop
                case .Reset_Soft:
                        callbacks.memory_manager(.Reset, &game_mem)
                        callbacks.init(game_mem)
                }
        }

        callbacks.shutdown(game_mem)
        callbacks.memory_manager(.Free, &game_mem)
}
