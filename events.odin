package callisto

Event :: union {
        Window_Event,
        Input_Event,
}


Window_Event :: struct {
        window: ^Window,
        type: Window_Event_Type,
        data: struct #raw_union {
                position: [2]i32,
                size: [2]i32,
        }
}


Window_Event_Type :: enum {
        Moved,
        Resized,
        Closed,
        Minimized,
        Maximized,
        Fullscreen_Enter,
        Fullscreen_Exit,
        Focus_Gained,
        Focus_Lost,
}


Input_Event :: struct {
        device_id : i32,
        source : Input_Source,
        motion : Input_Motion,
        data : struct #raw_union {
                text: rune,

                vector1: struct {
                        delta   : f32,
                        absolute: f32,
                },

                vector2: struct {
                        delta   : [2]f32,
                        absolute: [2]f32,
                },

                vector3: struct {
                        delta   : [3]f32,
                        absolute: [3]f32,
                },
        },
}


Input_Motion :: enum {
        Button_Down,
        Button_Held,
        Button_Up,
        Vector,
        Text,
}



Input_Source :: enum {
        Mouse_Left,
        Mouse_Right,
        Mouse_Middle,
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
        Shift_Left,
        Shift_Right,
        Ctrl_Left,
        Ctrl_Right,
        Alt_Left,
        Alt_Right,
        Super_Left,
        Super_Right,
        Caps_Lock,
        Num_Lock,
        Scroll_Lock,
        Escape,

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

        _0,
        _1,
        _2,
        _3,
        _4,
        _5,
        _6,
        _7,
        _8,
        _9,

        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z,

        F1,
        F2,
        F3,
        F4,
        F5,
        F6,
        F7,
        F8,
        F9,
        F10,
        F11,
        F12,
        F13,
        F14,
        F15,
        F16,
        F17,
        F18,
        F19,
        F20,
        F21,
        F22,
        F23,
        F24,

        Exclamation,
        At,
        Hash,
        Dollar,
        Percent,
        Carat,
        Ampersand,
        Asterix,
        Parenthesis_Open,
        Parenthesis_Close,
        Dash,
        Underscore,
        Plus,
        Equals,
        Bracket_Open,
        Bracket_Close,
        Brace_Open,
        Brace_Close,
        Backward_Slash,
        Vertical_Bar,
        Semicolon,
        Colon,
        Quote,
        Double_Quote,
        Comma,
        Period,
        Angled_Bracket_Open,
        Angled_Bracket_Close,
        Forward_Slash,
        Question,
        Backtick,
        Tilde,
       
        Numpad_Enter,
        Numpad_Slash,
        Numpad_Asterix,
        Numpad_Dash,
        Numpad_Plus,
        Numpad_Period,

        Numpad_0,
        Numpad_1,
        Numpad_2,
        Numpad_3,
        Numpad_4,
        Numpad_5,
        Numpad_6,
        Numpad_7,
        Numpad_8,
        Numpad_9,

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

