package callisto_runner

import game_pkg "../../"
import "base:runtime"


when !HOT_RELOAD {

main :: proc() {
        game := game_pkg.callisto_runner_callbacks()
        game_mem, ctx := game.memory_init()
        if ctx != {} {
                context = ctx
        }
        game.game_init()

        gameloop:
        for {
                ctl := game.game_render()
                switch ctl {
                case .Ok:
                case .Shutdown:
                        break gameloop
                case .Reset_Soft:
                case .Reset_Hard:
                }
        }

        game.memory_shutdown(game_mem)
}


} // when !HOT_RELOAD
