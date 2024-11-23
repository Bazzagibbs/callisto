package callisto

import "core:math/linalg"

// `.Before_Loop` - Every frame, automatically flush all events from the queue.
// `.Before_Loop_Wait` - Only draw a frame when there's an event available. Useful for editors or apps that don't need to be constantly updated.
// `.Manual` - Application code can call `callisto.event_pump()` just before input is needed.
Event_Behaviour :: enum {
        Before_Loop,
        Before_Loop_Wait,
        Manual,
}

Event :: union {
        Window_Event,
        Input_Event,
        // Custom_Event_Dispatch? 
        // Something to signal that extension event queues should pump now
}


Window_Event :: struct {
        window : Window,
        event : union {
                Window_Resized,
                Window_Moved,
                Window_Opened,
                Window_Close_Request,
                Window_Closed,
                Window_Focus_Gained,
                Window_Focus_Lost,
        }
}



Window_Moving :: struct {
        position : [2]i32
}

Window_Moved :: struct {
        position : [2]i32
}

Window_Resized :: struct {
        pixel_size  : [2]i32,
        scaled_size : [2]i32,
        dpi_scale   : f32,
        type : Window_Resized_Type
}

Window_Resized_Type :: enum {
        Fullscreen,
        Minimized,
        Maximized,
        Restored,
        Occluded, // Another window has been maximized over this one
        Revealed, // Another window that was maximized has been un-maximized.
        Dpi_Changed,
}

Window_Opened        :: struct {
        position    : [2]i32,
        pixel_size  : [2]i32,
        scaled_size : [2]i32,
        dpi_scale   : f32,
}

Window_Close_Request :: struct {}
Window_Closed        :: struct {}
Window_Focus_Gained  :: struct {}
Window_Focus_Lost    :: struct {}


Input_Event :: struct {
        window    : Window,
        device_id : i32,

        event : union {
                Input_Text,
                Input_Button,
                Input_Vector1,
                Input_Vector2,
                Input_Vector3,
        },
}


Input_Button :: struct {
        source       : Input_Button_Source,
        hand         : Input_Hand,
        modifiers    : Input_Button_Modifiers,
        motion       : Input_Button_Motion,
}

Input_Text :: struct {
        text         : rune,
        modifiers    : Input_Button_Modifiers,
        motion       : Input_Button_Motion,
}


Input_Vector1 :: struct {
        source   : Input_Vector1_Source,
        delta    : f32,
        absolute : f32,
}

Input_Vector2 :: struct {
        source   : Input_Vector2_Source,
        delta    : [2]f32,
        absolute : [2]f32,
}


Input_Vector3 :: struct {
        source   : Input_Vector3_Source,
        delta    : [3]f32,
        absolute : [3]f32,
}

Input_Button_Modifiers :: bit_set[Input_Button_Modifier; u8]
Input_Button_Modifier :: enum {
        Ctrl,
        Alt,
        Shift,
        Super,
}

Input_Button_Motion :: enum {
        Down,
        Held,
        Up,
        Instant, // e.g. scroll wheel up/down
}

// For keys with no handed-variant, this will be `.Left`
Input_Hand :: enum {
        Left,
        Right,
}

Input_Button_Source :: enum {
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


        // Gamepad_North,
        // Gamepad_South,
        // Gampad_East,
        // Gamepad_West,
        // Gamepad_Up,
        // Gamepad_Down,
        // Gamepad_Left,
        // Gamepad_Right,
        // Gamepad_Start,
        // Gamepad_Select,
        // Gamepad_System,
        // Gamepad_Shoulder_Left,
        // Gamepad_Shoulder_Right,
        // Gamepad_Stick_Button_Left,
        // Gamepad_Stick_Button_Right,
        // Gamepad_Trigger_Click_Left,
        // Gamepad_Trigger_Click_Right,
        
        /*
        VR_A,
        VR_B,
        VR_Menu,
        VR_System,
        VR_Grip_Click,
        VR_Trigger_Click,

        Touch_Position,
        VR_Tracker_Position,
        VR_Tracker_Rotation,
        VR_Touchpad,
        VR_Stick,
        */
}

Input_Vector1_Source :: enum {
        Unknown,
        // Gamepad_Trigger_Left,
        // Gamepad_Trigger_Right,
        // VR_Trigger,
        // VR_Grip,
        // Generic_Axis_0, etc.
}

Input_Vector2_Source :: enum {
        Unknown,
        Mouse_Position,
        // Mouse_Position_Raw,
        // Touch_Position,
        // Gamepad_Stick_Left,
        // Gamepad_Stick_Right,
        // Gamepad_Touch_Position,
        // VR_Touch_Position,
        
        // // Trackpad gestures?
        // Trackpad_Two_Fingers,
        // Trackpad_Three_Fingers,
        // Trackpad_Four_Fingers,
}

Input_Vector3_Source :: enum {
        Unknown,
        // Gamepad_Accelerometer,
        // Gamepad_Gyroscope,
}

// Pumps all events in the event queue, then returns.
// Only required if engine was initialized with `event_behaviour = .Manual`
event_pump :: proc(e: ^Engine) {
        e.runner->event_pump()
}
