package callisto_input

/*
Normal: Desktop-like cursor behaviour.
Hidden: Desktop-like cursor behaviour, but cursor graphic is invisible.
Disabled: Cursor is invisible and is not restricted by the window's bounds. Useful for camera controls.
*/
Cursor_Lock_Mode :: enum {
    Normal          = 0x00034001, 
    Hidden          = 0x00034002, 
    Disabled        = 0x00034003, 
}

Button_Press_Action :: enum {
    Release     = 0,
    Press       = 1,
    Repeat      = 2,
}

Gamepad_Button :: enum {
    // Face
    South           = 0, // A
    East            = 1, // B
    West            = 2, // X
    North           = 3, // Y
    // Shoulder
    Left_Bumper     = 4,
    Right_Bumper    = 5,
    // Menu 
    Back            = 6,  // Select
    Start           = 7,
    Guide           = 8,
    // Sticks
    Left_Thumb      = 9,
    Right_Thumb     = 10,
    // D-Pad
    Dpad_Up         = 11,
    Dpad_Right      = 12,
    Dpad_Down       = 13,
    Dpad_Left       = 14,
}

Gamepad_Axis :: enum {
    Left_X          = 0,
    Left_Y          = 1,
    Right_X         = 2,
    Right_Y         = 3,
    Left_Trigger    = 4,
    Right_Trigger   = 5,
}


Key_Code :: enum {
    /* The unknown key */
    Unknown = 0,

    /** Printable keys **/

    /* Named printable keys */
    Space         = 32,
    Apostrophe    = 39,  /* ' */
    Comma         = 44,  /* , */
    Minus         = 45,  /* - */
    Period        = 46,  /* . */
    Slash         = 47,  /* / */
    Semicolon     = 59,  /* ; */
    Equal         = 61,  /* :: */
    Left_Bracket  = 91,  /* [ */
    Backslash     = 92,  /* \ */
    Right_Bracket = 93,  /* ] */
    Grave_Accent  = 96,  /* ` */
    World_1       = 161, /* non-US #1 */
    World_2       = 162, /* non-US #2 */

    /* Alphanumeric characters */
    Num_0 = 48,
    Num_1 = 49,
    Num_2 = 50,
    Num_3 = 51,
    Num_4 = 52,
    Num_5 = 53,
    Num_6 = 54,
    Num_7 = 55,
    Num_8 = 56,
    Num_9 = 57,

    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    G = 71,
    H = 72,
    I = 73,
    J = 74,
    K = 75,
    L = 76,
    M = 77,
    N = 78,
    O = 79,
    P = 80,
    Q = 81,
    R = 82,
    S = 83,
    T = 84,
    U = 85,
    V = 86,
    W = 87,
    X = 88,
    Y = 89,
    Z = 90,


    /** Function keys **/

    /* Named non-printable keys */
    Escape       = 256,
    Enter        = 257,
    Tab          = 258,
    Backspace    = 259,
    Insert       = 260,
    Delete       = 261,
    Right        = 262,
    Left         = 263,
    Down         = 264,
    Up           = 265,
    Page_Up      = 266,
    Page_Down    = 267,
    Home         = 268,
    End          = 269,
    Caps_Lock    = 280,
    Scroll_Lock  = 281,
    Num_Lock     = 282,
    Print_Screen = 283,
    Pause        = 284,

    /* Function keys */
    F1  = 290,
    F2  = 291,
    F3  = 292,
    F4  = 293,
    F5  = 294,
    F6  = 295,
    F7  = 296,
    F8  = 297,
    F9  = 298,
    F10 = 299,
    F11 = 300,
    F12 = 301,
    F13 = 302,
    F14 = 303,
    F15 = 304,
    F16 = 305,
    F17 = 306,
    F18 = 307,
    F19 = 308,
    F20 = 309,
    F21 = 310,
    F22 = 311,
    F23 = 312,
    F24 = 313,
    F25 = 314,

    /* Keypad numbers */
    Numpad_0 = 320,
    Numpad_1 = 321,
    Numpad_2 = 322,
    Numpad_3 = 323,
    Numpad_4 = 324,
    Numpad_5 = 325,
    Numpad_6 = 326,
    Numpad_7 = 327,
    Numpad_8 = 328,
    Numpad_9 = 329,

    /* Keypad named function keys */
    Numpad_Decimal  = 330,
    Numpad_Divide   = 331,
    Numpad_Multiply = 332,
    Numpad_Subtract = 333,
    Numpad_Add      = 334,
    Numpad_Enter    = 335,
    Numpad_Equal    = 336,

    /* Modifier keys */
    Left_Shift    = 340,
    Left_Control  = 341,
    Left_Alt      = 342,
    Left_Super    = 343,
    Right_Shift   = 344,
    Right_Control = 345,
    Right_Alt     = 346,
    Right_Super   = 347,
    Menu          = 348,
}

Mouse_Button :: enum {
    Left = 0,
    Right = 1,
    Middle = 2,
    M_4 = 3,
    M_5 = 4,
    M_6 = 5,
    M_7 = 6,
    M_8 = 7,

    Wheel_Up = 8,
    Wheel_Down = 9,
}