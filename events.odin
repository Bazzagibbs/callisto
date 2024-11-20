package callisto


Event :: union {
        Window_Event,
        Input_Event,
}


Window_Event :: struct {
        window : Window,
        type   : Window_Event_Type,
        using additional_info : struct #raw_union {
                resized_type: Window_Resized_Type,
        },
        using data: struct #raw_union {
                position: [2]i32,
                size    : [2]i32,
        },
}


Window_Event_Type :: enum {
        Moved,
        Resized,
        Closed,
        Focus_Gained,
        Focus_Lost,
}

Window_Resized_Type :: enum {
        In_Progress,
        Fullscreen,
        Minimized,
        Maximized,
        Restored,
        Occluded, // Another window has been maximized over this one
        Revealed, // Another window that was maximized has been un-maximized.
}

Text_Event :: struct {
        value       : rune,
        using state : Input_Button_State,
}

Text_Control :: enum {
        Backspace,
        Tab,
        Carriage_Return,
        Linefeed,
        Escape,
}

Input_Event :: struct {
        window    : Window,
        device_id : i32,
        motion    : Input_Motion,
        source    : Input_Source,

        position : union {
                Input_Button_State,
                Input_Vector1,
                Input_Vector2,
                Input_Vector3,
        },
}

Input_Button_State :: struct {
        repeat_count           : i16,
        hand                   : Input_Hand,   // Used for ctrl/alt/super/shift
        modifiers              : Input_Modifiers,
        was_previously_pressed : bool,
        is_being_released      : bool, 
}


Input_Modifiers :: bit_set[Input_Modifier; u8]
Input_Modifier :: enum {
        
}


Input_Vector1 :: struct {
        delta: f32,
        previous: f32,
}

Input_Vector2 :: struct {
        delta   : [2]f32,
        absolute: [2]f32,
}


Input_Vector3 :: struct {
        delta   : [3]f32,
        absolute: [3]f32,
}

Input_Motion :: enum {
        Button_Down,
        Button_Held,
        Button_Up,
        Button_Instant, // e.g. scroll wheel up/down
        Vector,
}

Input_Hand :: enum {
        Left,
        Right,
}

Input_Source :: enum {
        Unknown,
        Mouse_Left,
        Mouse_Right,
        Mouse_Middle,
        Mouse_Scroll_Up,
        Mouse_Scroll_Down,
        Mouse_Scroll_Left,
        Mouse_Scroll_Right,
        Mouse_3,
        Mouse_4,
        // Mouse_5, // These need win32 Raw Input
        // Mouse_6,
        // Mouse_7,
        // Mouse_8,
        // Mouse_9,
        // Mouse_10,
        // Mouse_11,
        // Mouse_12,
        // Mouse_13,
        // Mouse_14,
        // Mouse_15,
        // Mouse_16,

        // Trackpad gestures?
        // Trackpad_Two_Fingers,
        // Trackpad_Three_Fingers,
        // Trackpad_Four_Fingers,

        Backspace,
        Tab,
        Enter,
        Shift,
        Ctrl,
        Alt,
        Super,
        Caps_Lock,
        Num_Lock,
        Scroll_Lock,
        Esc,

        Space,

        Page_Up,
        Page_Down,
        End,
        Home,
        Insert,
        Delete,

        Up,
        Down,
        Left,
        Right,

        Print_Screen,

        _0 = 0x30,
        _1 = 0x31,
        _2 = 0x32,
        _3 = 0x33,
        _4 = 0x34,
        _5 = 0x35,
        _6 = 0x36,
        _7 = 0x37,
        _8 = 0x38,
        _9 = 0x39,

        // 0x3a..=0x40

        A = 0x41,
        B = 0x42,
        C = 0x43,
        D = 0x44,
        E = 0x45,
        F = 0x46,
        G = 0x47,
        H = 0x48,
        I = 0x49,
        J = 0x4a,
        K = 0x4b,
        L = 0x4c,
        M = 0x4d,
        N = 0x4e,
        O = 0x4f,
        P = 0x50,
        Q = 0x51,
        R = 0x52,
        S = 0x53,
        T = 0x54,
        U = 0x55,
        V = 0x56,
        W = 0x57,
        X = 0x58,
        Y = 0x59,
        Z = 0x5a,

        // 0x5b..=0x5f

        Numpad_0 = 0x60,
        Numpad_1 = 0x61,
        Numpad_2 = 0x62,
        Numpad_3 = 0x63,
        Numpad_4 = 0x64,
        Numpad_5 = 0x65,
        Numpad_6 = 0x66,
        Numpad_7 = 0x67,
        Numpad_8 = 0x68,
        Numpad_9 = 0x69,

        // 0x6a..=0x6f

        F1  = 0x70,
        F2  = 0x71,
        F3  = 0x72,
        F4  = 0x73,
        F5  = 0x74,
        F6  = 0x75,
        F7  = 0x76,
        F8  = 0x77,
        F9  = 0x78,
        F10 = 0x79,
        F11 = 0x7a,
        F12 = 0x7b,
        F13 = 0x7c,
        F14 = 0x7d,
        F15 = 0x7e,
        F16 = 0x7f,
        F17 = 0x80,
        F18 = 0x81,
        F19 = 0x82,
        F20 = 0x83,
        F21 = 0x84,
        F22 = 0x85,
        F23 = 0x86,
        F24 = 0x87,

        // Keycodes for modified inputs are equal to their unmodified version
        Exclamation          = _1,
        At                   = _2,
        Hash                 = _3,
        Dollar               = _4,
        Percent              = _5,
        Carat                = _6,
        Ampersand            = _7,
        Asterix              = _8,
        Parenthesis_Open     = _9,
        Parenthesis_Close    = _0,
        Minus,
        Underscore           = Minus,
        Equals,
        Plus                 = Equals,
        Bracket_Open,
        Brace_Open           = Bracket_Open,
        Bracket_Close,
        Brace_Close          = Bracket_Close,
        Backward_Slash,
        Vertical_Bar         = Backward_Slash,
        Semicolon,
        Colon                = Semicolon,
        Quote,
        Double_Quote         = Quote,
        Comma,
        Angled_Bracket_Open  = Comma,
        Period,
        Angled_Bracket_Close = Period,
        Forward_Slash,
        Question             = Forward_Slash,
        Backtick,
        Tilde                = Backtick,
       
        Numpad_Enter,
        Numpad_Forward_Slash,
        Numpad_Asterix,
        Numpad_Minus,
        Numpad_Plus,
        Numpad_Period,


        // Gamepad 0..?
        Gamepad_North,
        Gamepad_South,
        Gampad_East,
        Gamepad_West,
        Gamepad_Up,
        Gamepad_Down,
        Gamepad_Left,
        Gamepad_Right,
        Gamepad_Start,
        Gamepad_Select,
        Gamepad_System,
        Gamepad_Shoulder_Left,
        Gamepad_Shoulder_Right,
        Gamepad_Stick_Left,
        Gamepad_Stick_Right,
        

        Mouse_Position,        // Vector2
        Gamepad_Trigger_Left,  // Vector1
        Gamepad_Trigger_Right, // Vector1
        Gamepad_Gyroscope,     // Vector3
        Gamepad_Accelerometer, // Vector3
        
        /*
        Touch_Position,

        VR_Tracker_Position,
        VR_Tracker_Rotation,
        VR_Touchpad,
        VR_Stick,
        VR_Trigger,
        VR_Capacitive_Finger_Thumb,
        VR_Capacitive_Finger_Index,
        VR_Capacitive_Finger_Middle,
        VR_Capacitive_Finger_Ring,
        VR_Capacitive_Finger_Pinky,
        */
}


// Implemented in events_*.odin
// ============================

// _input_source_translate_* :: proc (int) -> Input_Source

