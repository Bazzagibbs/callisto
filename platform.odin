package callisto

import "core:strings"
import "core:bytes"
import "core:path/filepath"
import "common"

Exit_Code          :: common.Exit_Code

Window                     :: common.Window
Window_Create_Info         :: common.Window_Create_Info
Window_Style_Flags         :: common.Window_Style_Flags
Window_Style_Flag          :: common.Window_Style_Flag
Window_Style_Flags_DEFAULT :: common.Window_Style_Flags_DEFAULT
Window_Position_AUTO       :: common.Window_Position_AUTO
Window_Size_AUTO           :: common.Window_Size_AUTO


Event                :: common.Event
Event_Behaviour      :: common.Event_Behaviour

Runner_Event         :: common.Runner_Event

Window_Event         :: common.Window_Event
Window_Moved         :: common.Window_Moved
Window_Resized       :: common.Window_Resized
Window_Resized_Type  :: common.Window_Resized_Type
Window_Opened        :: common.Window_Opened
Window_Close_Request :: common.Window_Close_Request
Window_Closed        :: common.Window_Closed
Window_Focus_Gained  :: common.Window_Focus_Gained
Window_Focus_Lost    :: common.Window_Focus_Lost

Input_Event          :: common.Input_Event
Input_Button         :: common.Input_Button
Input_Text           :: common.Input_Text
Input_Modifiers      :: common.Input_Modifiers
Input_Modifier       :: common.Input_Modifier
Input_Button_Motion  :: common.Input_Button_Motion
Input_Button_Source  :: common.Input_Button_Source
Input_Hand           :: common.Input_Hand
Input_Vector1        :: common.Input_Vector1
Input_Vector2        :: common.Input_Vector2
Input_Vector3        :: common.Input_Vector3

copy_directory :: common.copy_directory

get_exe_directory        :: common.get_exe_directory
get_persistent_directory :: common.get_persistent_directory

window_create :: proc(e: ^Engine, create_info: ^Window_Create_Info, location := #caller_location) -> (window: Window, res: Result) {
        return e.runner->window_create(create_info)
}

window_destroy :: proc(e: ^Engine, window: ^Window) {
        e.runner->window_destroy(window)
}


// Pumps all events in the event queue, then returns.
// Only required if engine was initialized with `event_behaviour = .Manual`
event_pump :: proc(e: ^Engine) {
        e.runner->event_pump()
}


exit :: proc(exit_code: Exit_Code) {
        _exit(exit_code)
}

