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
Window_Event_Type          :: cal.Window_Event_Type
Window_Resized_Type        :: cal.Window_Resized_Type

Input_Event                :: cal.Input_Event
Input_Source               :: cal.Input_Source
Input_Motion               :: cal.Input_Motion

Window                     :: cal.Window
Window_Create_Info         :: cal.Window_Create_Info
Window_Style_Flags         :: cal.Window_Style_Flags

callisto_context_init      :: cal.callisto_context_init
callisto_context_destroy   :: cal.callisto_context_destroy
get_exe_directory          :: cal.get_exe_directory

