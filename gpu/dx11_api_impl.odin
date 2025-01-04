#+ private
package callisto_gpu

import "core:strings"
import "core:log"
import dx "vendor:directx/d3d11"
import dxgi "vendor:directx/dxgi"
import win "core:sys/windows"
import "../common"

// when RHI == "d3d11" {

check_result :: proc(hres: dx.HRESULT, message_args: ..any) -> Result {
        if hres >= 0 {
                return .Ok
        }

        log.error(common.parse_hresult(hres), ":", message_args)

        switch u32(hres) {
        case 0x887C0001: return .Out_Of_Memory_GPU      // Too many unique state objects
        case 0x887C0002: return .File_Not_Found
        case 0x887C0003: return .Out_Of_Memory_GPU      // Too many unique view objects
        case 0x887C0004: return .Memory_Map_Failed      // Attempt to map memory without discard
        case 0x887A0001: return .Argument_Invalid
        case 0x887A000A: return .Synchronization_Error  // "Was still drawing"
        case 0x80004005: return .No_Suitable_GPU        // Debug layer requested but not installed
        case 0x80070057: return .Argument_Invalid
        case 0x8007000E: return .Out_Of_Memory_GPU
        case 0x80004001: return .Argument_Not_Supported // Procedure not implemented for the provided argument combination
        }

        return .Unknown_RHI_Error
}

hres_succeeded :: proc(hres: dx.HRESULT) -> bool {
        return hres >= 0
}

// defer _flush_debug_messages() // at the top of calls
_flush_debug_messages :: proc(di: ^_Device_Impl, loc := #caller_location) { 
        when ODIN_DEBUG {
                severity_to_log_level := [dx.MESSAGE_SEVERITY]log.Level {
                        .MESSAGE    = .Debug,
                        .INFO       = .Info,
                        .WARNING    = .Warning,
                        .ERROR      = .Error,
                        .CORRUPTION = .Error,
                }

                if di.info_queue == nil {
                        return
                }

                message_count := di.info_queue->GetNumStoredMessages()
                for i in 0..<message_count {
                        msg_size: dx.SIZE_T
                        di.info_queue->GetMessage(i, nil, &msg_size)

                        if msg_size > cap(di.msg_buffer) {
                                resize(&di.msg_buffer, int(msg_size))
                        }

                        msg := (^dx.MESSAGE)(raw_data(di.msg_buffer))
                        di.info_queue->GetMessage(i, msg, &msg_size)

                        level := severity_to_log_level[msg.Severity]
                        desc := strings.string_from_ptr((^u8)(msg.pDescription), int(msg.DescriptionByteLength))
                        log.log(level, desc, location = loc)
                }
        }
}


_Device_Impl :: struct {
        device        : ^dx.IDevice,
        debug         : ^dx.IDebug,
        info_queue    : ^dx.IInfoQueue,
        gi_info_queue : ^dxgi.IInfoQueue,
        msg_buffer    : [dynamic]u8,
}


_device_create :: proc(info: ^Device_Create_Info) -> (d: Device, res: Result) {
        defer _flush_debug_messages(&d._impl)

        feature_levels := []dx.FEATURE_LEVEL { ._11_1 }

        creation_flags := dx.CREATE_DEVICE_FLAGS {}

        when ODIN_DEBUG {
                creation_flags += {.DEBUG}
        }

        hres := dx.CreateDevice(
                pAdapter           = nil,
                DriverType         = .HARDWARE,
                Software           = nil,
                Flags              = creation_flags,
                pFeatureLevels     = raw_data(feature_levels),
                FeatureLevels      = len32(feature_levels),
                SDKVersion         = dx.SDK_VERSION,
                ppDevice           = &d._impl.device,
                pFeatureLevel      = nil,
                ppImmediateContext = &d.immediate_command_buffer._impl.ctx,
        )

        check_result(hres) or_return

        // Debug layer
        when ODIN_DEBUG {
                ok := hres_succeeded(d._impl.device->QueryInterface(dx.IDebug_UUID, (^rawptr)(&d._impl.debug)))
                if !ok {
                        log.warn("No D3D11 debug layer available")
                } else {
                        ok = hres_succeeded(d._impl.debug->QueryInterface(dx.IInfoQueue_UUID, (^rawptr)(&d._impl.info_queue)))
                        if !ok {
                                log.warn("No D3D11 debug info queue available")
                                d._impl.debug->Release()
                                d._impl.debug = nil
                        } else {
                                d._impl.info_queue->SetBreakOnSeverity(.CORRUPTION, true)
                                d._impl.info_queue->SetBreakOnSeverity(.ERROR, true)

                                hide := []dx.MESSAGE_ID {
                                        .SETPRIVATEDATA_CHANGINGPARAMS,
                                }

                                filter: dx.INFO_QUEUE_FILTER 
                                filter.DenyList.NumIDs = len32(hide)
                                filter.DenyList.pIDList = raw_data(hide)
                                
                                d._impl.info_queue->AddStorageFilterEntries(&filter)
                        }
                }

                ok = hres_succeeded(dxgi.DXGIGetDebugInterface1(0, dxgi.IInfoQueue_UUID, (^rawptr)(&d._impl.gi_info_queue)))
                if !ok {
                        log.warn("No DXGI debug layer available")
                } else {
                        d._impl.gi_info_queue->SetBreakOnSeverity(dxgi.DEBUG_ALL, .CORRUPTION, true)
                        d._impl.gi_info_queue->SetBreakOnSeverity(dxgi.DEBUG_ALL, .ERROR, true)
                }
        }

        d._impl.msg_buffer = make([dynamic]u8, 1024, context.allocator)

        return d, .Ok
}

_device_destroy :: proc(d: ^Device) {
        d.immediate_command_buffer._impl.ctx->Release()
        d._impl.device->Release()

        when ODIN_DEBUG {
                if d._impl.debug != nil {
                        d._impl.debug->ReportLiveDeviceObjects({.SUMMARY, .DETAIL, .IGNORE_INTERNAL})
                        _flush_debug_messages(&d._impl)
                        log.info("Expected ID3D11Device Refcount == 3. Ignore previous warning if this is the case.")
                        d._impl.debug->Release()
                }

                if d._impl.gi_info_queue != nil {
                        d._impl.gi_info_queue->Release()
                }
                if d._impl.info_queue != nil {
                        d._impl.info_queue->Release()
                }
        }


        delete(d._impl.msg_buffer)
}




_Command_Buffer_Impl :: struct {
        ctx : ^dx.IDeviceContext,
}



// } // when RHI == "d3d11"
