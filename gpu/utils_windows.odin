package callisto_gpu

import win "core:sys/windows"
import "../common"
import "core:log"


_window_get_size :: proc(window: common.Window) -> [2]u32 {
        rect: win.RECT
        ok := win.GetWindowRect(window, &rect)
        if !ok {
                log.error("Failed to get window size")
                return 0
        }

        return {u32(rect.right - rect.left), u32(rect.bottom - rect.top)}
}
