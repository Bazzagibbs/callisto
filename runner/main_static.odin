package callisto_runner
import "base:runtime"
import "core:log"

// The main game loop for standalone builds
main_static :: proc "contextless" (callbacks: Callbacks) {
        ctx, track := _callisto_context() 
        context = ctx
        _platform_callback_context = ctx
       
        platform: Platform
        res := _platform_init(&platform)
        if res != .Ok {
                log.error("Platform initialization failed:", res)
                return
        }

        game_mem: rawptr

        callbacks.memory_manager(.Allocate, &game_mem)
        callbacks.init(game_mem)

        gameloop:
        for {
                ctl := callbacks.loop(game_mem)
                switch ctl {
                case .Ok:
                        // Do nothing
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
