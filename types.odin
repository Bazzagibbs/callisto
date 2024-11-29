package callisto

import "core:mem"

import "common"

Result             :: common.Result
Exit_Code          :: common.Exit_Code

Engine             :: common.Engine
Engine_Init_Info   :: common.Engine_Init_Info

Runner             :: common.Runner
Dll_Symbol_Table   :: common.Dll_Symbol_Table

Window             :: common.Window
Window_Init_Info   :: common.Window_Init_Info
Window_Style_Flags :: common.Window_Style_Flags
Window_Style_Flag  :: common.Window_Style_Flag


Event                :: common.Event
Event_Behaviour      :: common.Event_Behaviour

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


check_error :: proc {
        check_error_allocator,
}

check_error_allocator :: proc "contextless" (err: mem.Allocator_Error) -> Result {
        switch err {
        case .None, .Mode_Not_Implemented: 
                return .Ok

        case .Out_Of_Memory: 
                return .Out_Of_Memory

        case .Invalid_Pointer, .Invalid_Argument: 
                return .Argument_Invalid
}

        return .Ok
}
