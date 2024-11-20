package callisto

import win "core:sys/windows"


_input_source_translate_windows :: proc "contextless" (#any_int key_code: int) -> Input_Source {
        switch key_code {
        case win.VK_LBUTTON    : return .Mouse_Left
        case win.VK_RBUTTON    : return .Mouse_Right
        case win.VK_MBUTTON    : return .Mouse_Middle
        case win.VK_XBUTTON1   : return .Mouse_3
        case win.VK_XBUTTON2   : return .Mouse_4

        case win.VK_BACK       : return .Backspace
        case win.VK_TAB        : return .Tab
        case win.VK_RETURN     : return .Enter
        case win.VK_SHIFT      : return .Shift
        case    win.VK_CONTROL, 
                win.VK_LCONTROL, 
                win.VK_RCONTROL: return .Ctrl
        case    win.VK_MENU, 
                win.VK_LMENU, 
                win.VK_RMENU   : return .Alt
        case win.VK_CAPITAL    : return .Caps_Lock
        case win.VK_ESCAPE     : return .Esc

        case win.VK_SPACE      : return .Space
        case win.VK_PRIOR      : return .Page_Up
        case win.VK_NEXT       : return .Page_Down
        case win.VK_END        : return .End
        case win.VK_HOME       : return .Home
        case win.VK_LEFT       : return .Left
        case win.VK_UP         : return .Up
        case win.VK_RIGHT      : return .Right
        case win.VK_DOWN       : return .Down
        case win.VK_SNAPSHOT   : return .Print_Screen
        case win.VK_INSERT     : return .Insert
        case win.VK_DELETE     : return .Delete
        case    0x30..=0x39, // numbers, letters
                0x41..=0x5a    : return Input_Source(key_code)
        case    win.VK_LWIN,
                win.VK_RWIN    : return .Super
        case    0x60..=0x69, // numpad, function keys
                0x70..=0x87    : return Input_Source(key_code)

        case win.VK_NUMLOCK    : return .Num_Lock
        case win.VK_SCROLL     : return .Scroll_Lock
        case win.VK_OEM_1      : return .Semicolon
        case win.VK_OEM_PLUS   : return .Plus
        case win.VK_OEM_COMMA  : return .Comma
        case win.VK_OEM_MINUS  : return .Minus
        case win.VK_OEM_PERIOD : return .Period
        case win.VK_OEM_2      : return .Forward_Slash
        case win.VK_OEM_3      : return .Backtick
        case win.VK_OEM_4      : return .Bracket_Open
        case win.VK_OEM_5      : return .Backward_Slash
        case win.VK_OEM_6      : return .Bracket_Close
        case win.VK_OEM_7      : return .Quote
        case win.VK_OEM_8      : return .Unknown
        case win.VK_DECIMAL    : return .Period
        }

        return .Unknown
}
