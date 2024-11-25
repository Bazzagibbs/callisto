package callisto_runner

import win "core:sys/windows"

VKey :: enum u8 {
        UNKNOWN = 0x00,

        // https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
        // Virtual Keys, Standard Set
        LBUTTON  = 0x01,
        RBUTTON  = 0x02,
        CANCEL   = 0x03,
        MBUTTON  = 0x04, // NOT contiguous with L & RBUTTON
        XBUTTON1 = 0x05, // NOT contiguous with L & RBUTTON
        XBUTTON2 = 0x06, // NOT contiguous with L & RBUTTON

        // 0x07 : reserved

        BACK = 0x08,
        TAB  = 0x09,

        // 0x0A - 0x0B : reserved

        CLEAR  = 0x0C,
        RETURN = 0x0D,

        // 0x0E - 0x0F : unassigned

        SHIFT      = 0x10,
        CONTROL    = 0x11,
        MENU       = 0x12,
        PAUSE      = 0x13,
        CAPITAL    = 0x14,
        KANA       = 0x15,
        HANGEUL    = 0x15, // old name - should be here for compatibility
        HANGUL     = 0x15,
        IME_ON     = 0x16,
        JUNJA      = 0x17,
        FINAL      = 0x18,
        HANJA      = 0x19,
        KANJI      = 0x19,
        IME_OFF    = 0x1A,
        ESCAPE     = 0x1B,
        CONVERT    = 0x1C,
        NONCONVERT = 0x1D,
        ACCEPT     = 0x1E,
        MODECHANGE = 0x1F,
        SPACE      = 0x20,
        PRIOR      = 0x21,
        NEXT       = 0x22,
        END        = 0x23,
        HOME       = 0x24,
        LEFT       = 0x25,
        UP         = 0x26,
        RIGHT      = 0x27,
        DOWN       = 0x28,
        SELECT     = 0x29,
        PRINT      = 0x2A,
        EXECUTE    = 0x2B,
        SNAPSHOT   = 0x2C,
        INSERT     = 0x2D,
        DELETE     = 0x2E,
        HELP       = 0x2F,

        _0 = '0',
        _1 = '1',
        _2 = '2',
        _3 = '3',
        _4 = '4',
        _5 = '5',
        _6 = '6',
        _7 = '7',
        _8 = '8',
        _9 = '9',

        // 0x3A - 0x40 : unassigned

        A = 'A',
        B = 'B',
        C = 'C',
        D = 'D',
        E = 'E',
        F = 'F',
        G = 'G',
        H = 'H',
        I = 'I',
        J = 'J',
        K = 'K',
        L = 'L',
        M = 'M',
        N = 'N',
        O = 'O',
        P = 'P',
        Q = 'Q',
        R = 'R',
        S = 'S',
        T = 'T',
        U = 'U',
        V = 'V',
        W = 'W',
        X = 'X',
        Y = 'Y',
        Z = 'Z',

        LWIN = 0x5B,
        RWIN = 0x5C,
        APPS = 0x5D,

        // 0x5E : reserved

        SLEEP     = 0x5F,
        NUMPAD0   = 0x60,
        NUMPAD1   = 0x61,
        NUMPAD2   = 0x62,
        NUMPAD3   = 0x63,
        NUMPAD4   = 0x64,
        NUMPAD5   = 0x65,
        NUMPAD6   = 0x66,
        NUMPAD7   = 0x67,
        NUMPAD8   = 0x68,
        NUMPAD9   = 0x69,
        MULTIPLY  = 0x6A,
        ADD       = 0x6B,
        SEPARATOR = 0x6C,
        SUBTRACT  = 0x6D,
        DECIMAL   = 0x6E,
        DIVIDE    = 0x6F,
        F1        = 0x70,
        F2        = 0x71,
        F3        = 0x72,
        F4        = 0x73,
        F5        = 0x74,
        F6        = 0x75,
        F7        = 0x76,
        F8        = 0x77,
        F9        = 0x78,
        F10       = 0x79,
        F11       = 0x7A,
        F12       = 0x7B,
        F13       = 0x7C,
        F14       = 0x7D,
        F15       = 0x7E,
        F16       = 0x7F,
        F17       = 0x80,
        F18       = 0x81,
        F19       = 0x82,
        F20       = 0x83,
        F21       = 0x84,
        F22       = 0x85,
        F23       = 0x86,
        F24       = 0x87,

        // 0x88 - 0x8F : reserved

        NUMLOCK = 0x90,
        SCROLL  = 0x91,

        // NEC PC-9800 kbd definitions
        OEM_NEC_EQUAL = 0x92, // '=' key on numpad

        // Fujitsu/OASYS kbd definitions
        OEM_FJ_JISHO   = 0x92, // 'Dictionary' key
        OEM_FJ_MASSHOU = 0x93, // 'Unregister word' key
        OEM_FJ_TOUROKU = 0x94, // 'Register word' key
        OEM_FJ_LOYA    = 0x95, // 'Left OYAYUBI' key
        OEM_FJ_ROYA    = 0x96, // 'Right OYAYUBI' key

        // 0x97 - 0x9F : unassigned

        // L* & R* - left and right Alt, Ctrl and Shift virtual keys.
        // Used only as parameters to GetAsyncKeyState() and GetKeyState().
        // No other API or message will distinguish left and right keys in this way.
        LSHIFT   = 0xA0,
        RSHIFT   = 0xA1,
        LCONTROL = 0xA2,
        RCONTROL = 0xA3,
        LMENU    = 0xA4,
        RMENU    = 0xA5,

        BROWSER_BACK        = 0xA6,
        BROWSER_FORWARD     = 0xA7,
        BROWSER_REFRESH     = 0xA8,
        BROWSER_STOP        = 0xA9,
        BROWSER_SEARCH      = 0xAA,
        BROWSER_FAVORITES   = 0xAB,
        BROWSER_HOME        = 0xAC,
        VOLUME_MUTE         = 0xAD,
        VOLUME_DOWN         = 0xAE,
        VOLUME_UP           = 0xAF,
        MEDIA_NEXT_TRACK    = 0xB0,
        MEDIA_PREV_TRACK    = 0xB1,
        MEDIA_STOP          = 0xB2,
        MEDIA_PLAY_PAUSE    = 0xB3,
        LAUNCH_MAIL         = 0xB4,
        LAUNCH_MEDIA_SELECT = 0xB5,
        LAUNCH_APP1         = 0xB6,
        LAUNCH_APP2         = 0xB7,

        // 0xB8 - 0xB9 : reserved

        OEM_1      = 0xBA, // ';:' for US
        OEM_PLUS   = 0xBB, // '+'  any country
        OEM_COMMA  = 0xBC, // ','  any country
        OEM_MINUS  = 0xBD, // '-'  any country
        OEM_PERIOD = 0xBE, // '.'  any country
        OEM_2      = 0xBF, // '/?' for US
        OEM_3      = 0xC0, // '`~' for US

        // 0xC1 - 0xDA : reserved,

        OEM_4 = 0xDB, // '[{' for US
        OEM_5 = 0xDC, // '\|' for US
        OEM_6 = 0xDD, // ']}' for US
        OEM_7 = 0xDE, // ''"' for US
        OEM_8 = 0xDF,

        // 0xE0 : reserved

        // Various extended or enhanced keyboards
        OEM_AX   = 0xE1,  //  'AX' key on Japanese AX kbd
        OEM_102  = 0xE2,  //  "<>" or "\|" on RT 102-key kbd.
        ICO_HELP = 0xE3,  //  Help key on ICO
        ICO_00   = 0xE4,  //  00 key on ICO

        PROCESSKEY = 0xE5,
        ICO_CLEAR  = 0xE6,
        PACKET     = 0xE7,

        // 0xE8 : unassigned

        // Nokia/Ericsson definitions
        OEM_RESET   = 0xE9,
        OEM_JUMP    = 0xEA,
        OEM_PA1     = 0xEB,
        OEM_PA2     = 0xEC,
        OEM_PA3     = 0xED,
        OEM_WSCTRL  = 0xEE,
        OEM_CUSEL   = 0xEF,
        OEM_ATTN    = 0xF0,
        OEM_FINISH  = 0xF1,
        OEM_COPY    = 0xF2,
        OEM_AUTO    = 0xF3,
        OEM_ENLW    = 0xF4,
        OEM_BACKTAB = 0xF5,

        ATTN      = 0xF6,
        CRSEL     = 0xF7,
        EXSEL     = 0xF8,
        EREOF     = 0xF9,
        PLAY      = 0xFA,
        ZOOM      = 0xFB,
        NONAME    = 0xFC,
        PA1       = 0xFD,
        OEM_CLEAR = 0xFE,
}

VKey_Flag :: enum {
        Extended  = 8,
        Dlg_Mode  = 11,
        Menu_Mode = 12,
        Alt_Down  = 13,
        Repeat    = 14,
        Up        = 15,
}

VKey_Flags :: bit_set[VKey_Flag; u16]

Button_Hand_Pair :: struct #packed {
        button : Input_Button_Source,
        hand   : Input_Hand,
}

VKEY_MAPPING := #sparse [VKey]Button_Hand_Pair {
        .UNKNOWN    = {},

        .LBUTTON    = { .Mouse_Left, .Left },
        .RBUTTON    = { .Mouse_Right, .Left },
        .MBUTTON    = { .Mouse_Middle, .Left },
        .XBUTTON1   = { .Mouse_3, .Left },
        .XBUTTON2   = { .Mouse_4, .Left },
        
        .CANCEL = {},
        .CLEAR = {},
        .PAUSE = {},

        VKey(0x15)..=
        VKey(0x1A)  = {},

        VKey(0x1C)..=
        VKey(0x1F)  = {},
        
        .PRINT = {},
        .EXECUTE = {},
        .SELECT = {},
        .HELP = {},
        .APPS = {},
        .SLEEP = {},

        VKey(0x92)..=
        VKey(0x96)  = {},
       
        VKey(0xA6)..=
        VKey(0xB7)  = {},

        VKey(0xE1)..=
        VKey(0xFE)  = {},

        .BACK       = { .Backspace, .Left },
        .TAB        = { .Tab, .Left },
        .RETURN     = { .Enter, .Left },

        .SHIFT      = { .Shift, .Left },
        .LSHIFT     = { .Shift, .Left },
        .RSHIFT     = { .Shift, .Right },

        .CONTROL    = { .Ctrl, .Left },
        .LCONTROL   = { .Ctrl, .Left },
        .RCONTROL   = { .Ctrl, .Right },

        .MENU       = {.Alt, .Left },
        .LMENU      = {.Alt, .Left },
        .RMENU      = { .Alt, .Right },
        .CAPITAL    = { .Caps_Lock, .Left },
        .ESCAPE     = { .Esc, .Left },

        .SPACE      = { .Space, .Left },
        .PRIOR      = { .Page_Up, .Left },
        .NEXT       = { .Page_Down, .Left },
        .END        = { .End, .Left },
        .HOME       = { .Home, .Left },
        .LEFT       = { .Left, .Left },
        .UP         = { .Up, .Left },
        .RIGHT      = { .Right, .Left },
        .DOWN       = { .Down, .Left },
        .SNAPSHOT   = { .Print_Screen, .Left },
        .INSERT     = { .Insert, .Left },
        .DELETE     = { .Delete, .Left },

        ._0         = { ._0, .Left },
        ._1         = { ._1, .Left },
        ._2         = { ._2, .Left },
        ._3         = { ._3, .Left },
        ._4         = { ._4, .Left },
        ._5         = { ._5, .Left },
        ._6         = { ._6, .Left },
        ._7         = { ._7, .Left },
        ._8         = { ._8, .Left },
        ._9         = { ._9, .Left },

        .A          = { .A, .Left },
        .B          = { .B, .Left },
        .C          = { .C, .Left },
        .D          = { .D, .Left },
        .E          = { .E, .Left },
        .F          = { .F, .Left },
        .G          = { .G, .Left },
        .H          = { .H, .Left },
        .I          = { .I, .Left },
        .J          = { .J, .Left },
        .K          = { .K, .Left },
        .L          = { .L, .Left },
        .M          = { .M, .Left },
        .N          = { .N, .Left },
        .O          = { .O, .Left },
        .P          = { .P, .Left },
        .Q          = { .Q, .Left },
        .R          = { .R, .Left },
        .S          = { .S, .Left },
        .T          = { .T, .Left },
        .U          = { .U, .Left },
        .V          = { .V, .Left },
        .W          = { .W, .Left },
        .X          = { .X, .Left },
        .Y          = { .Y, .Left },
        .Z          = { .Z, .Left },

        .LWIN       = { .Super, .Left },
        .RWIN       = { .Super, .Right },

        .NUMPAD0    = { .Numpad_0, .Left },
        .NUMPAD1    = { .Numpad_1, .Left },
        .NUMPAD2    = { .Numpad_2, .Left },
        .NUMPAD3    = { .Numpad_3, .Left },
        .NUMPAD4    = { .Numpad_4, .Left },
        .NUMPAD5    = { .Numpad_5, .Left },
        .NUMPAD6    = { .Numpad_6, .Left },
        .NUMPAD7    = { .Numpad_7, .Left },
        .NUMPAD8    = { .Numpad_8, .Left },
        .NUMPAD9    = { .Numpad_9, .Left },

        .F1 = { .F1, .Left },
        .F2 = { .F2, .Left },
        .F3 = { .F3, .Left },
        .F4 = { .F4, .Left },
        .F5 = { .F5, .Left },
        .F6 = { .F6, .Left },
        .F7 = { .F7, .Left },
        .F8 = { .F8, .Left },
        .F9 = { .F9, .Left },
        .F10 = { .F10, .Left },
        .F11 = { .F11, .Left },
        .F12 = { .F12, .Left },
        .F13 = { .F13, .Left },
        .F14 = { .F14, .Left },
        .F15 = { .F15, .Left },
        .F16 = { .F16, .Left },
        .F17 = { .F17, .Left },
        .F18 = { .F18, .Left },
        .F19 = { .F19, .Left },
        .F20 = { .F20, .Left },
        .F21 = { .F21, .Left },
        .F22 = { .F22, .Left },
        .F23 = { .F23, .Left },
        .F24 = { .F24, .Left },

        .MULTIPLY   = { .Numpad_Multiply, .Left },
        .ADD        = { .Numpad_Add, .Left },
        .SEPARATOR  = { .Numpad_Separator, .Left },
        .SUBTRACT   = { .Numpad_Subtract, .Left },
        .DECIMAL    = { .Numpad_Decimal, .Left },
        .DIVIDE     = { .Numpad_Divide, .Left },

        .NUMLOCK    = { .Num_Lock, .Left },
        .SCROLL     = { .Scroll_Lock, .Left },
        .OEM_1      = { .Semicolon, .Left },
        .OEM_PLUS   = { .Equals, .Left },
        .OEM_COMMA  = { .Comma, .Left },
        .OEM_MINUS  = { .Minus, .Left },
        .OEM_PERIOD = { .Period, .Left },
        .OEM_2      = { .Forward_Slash, .Left },
        .OEM_3      = { .Back_Tick, .Left },
        .OEM_4      = { .Bracket_Open, .Left },
        .OEM_5      = { .Back_Slash, .Left },
        .OEM_6      = { .Bracket_Close, .Left },
        .OEM_7      = { .Quote, .Left },
        .OEM_8      = { .Unknown, .Left },
}
