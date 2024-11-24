package callisto_runner

import cal ".."

HOT_RELOAD :: #config(HOT_RELOAD, false)
APP_NAME   :: cal.APP_NAME

Result                     :: cal.Result
Runner                     :: cal.Runner
Dll_Symbol_Table           :: cal.Dll_Symbol_Table

Engine_Init_Info           :: cal.Engine_Init_Info

Event                      :: cal.Event

Window_Event               :: cal.Window_Event
Window_Moved               :: cal.Window_Moved
Window_Resized             :: cal.Window_Resized
Window_Opened              :: cal.Window_Opened
Window_Close_Request       :: cal.Window_Close_Request
Window_Closed              :: cal.Window_Closed
Window_Focus_Gained        :: cal.Window_Focus_Gained
Window_Focus_Lost          :: cal.Window_Focus_Lost
                            
Input_Event                :: cal.Input_Event
Input_Text                 :: cal.Input_Text
Input_Button               :: cal.Input_Button
Input_Vector1              :: cal.Input_Vector1
Input_Vector2              :: cal.Input_Vector2
Input_Vector3              :: cal.Input_Vector3

Input_Hand                 :: cal.Input_Hand
Input_Button_Source        :: cal.Input_Button_Source
Input_Button_Motion        :: cal.Input_Button_Motion
Input_Modifier             :: cal.Input_Modifier
Input_Modifiers            :: cal.Input_Modifiers
Input_Vector1_Source       :: cal.Input_Vector1_Source
Input_Vector2_Source       :: cal.Input_Vector2_Source
Input_Vector3_Source       :: cal.Input_Vector3_Source

Window                     :: cal.Window
Window_Create_Info         :: cal.Window_Create_Info
Window_Style_Flags         :: cal.Window_Style_Flags

Exit_Code                  :: cal.Exit_Code

callisto_context_init      :: cal.callisto_context_init
callisto_context_destroy   :: cal.callisto_context_destroy
get_exe_directory          :: cal.get_exe_directory

default_runner :: proc (ctx := context) -> Runner {
        return Runner {
                ctx              = ctx,
                should_close     = false,
                platform_init    = platform_init,
                platform_destroy = platform_destroy,
                window_create    = window_create,
                window_destroy   = window_destroy,
                event_pump       = event_pump,
        }
}

runner_destroy :: proc(runner: ^Runner) {
}
