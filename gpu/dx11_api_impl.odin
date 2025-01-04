#+ private
package callisto_gpu

import "core:strings"
import "core:log"
import dx "vendor:directx/d3d11"
import dxgi "vendor:directx/dxgi"
import win "core:sys/windows"
import "../common"

// when RHI == "d3d11" {

check_result :: proc(hres: dx.HRESULT, message_args: ..any, loc := #caller_location) -> Result {
        if hres >= 0 {
                return .Ok
        }

        log.error(common.parse_hresult(hres), ":", message_args, location = loc)

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
_flush_debug_messages :: proc(d: ^Device, loc := #caller_location) { 
        when ODIN_DEBUG {
                severity_to_log_level := [dx.MESSAGE_SEVERITY]log.Level {
                        .MESSAGE    = .Debug,
                        .INFO       = .Info,
                        .WARNING    = .Warning,
                        .ERROR      = .Error,
                        .CORRUPTION = .Error,
                }

                if d._impl.info_queue == nil {
                        return
                }

                message_count := d._impl.info_queue->GetNumStoredMessages()
                for i in 0..<message_count {
                        msg_size: dx.SIZE_T
                        d._impl.info_queue->GetMessage(i, nil, &msg_size)

                        if msg_size > cap(d._impl.msg_buffer) {
                                resize(&d._impl.msg_buffer, int(msg_size))
                        }

                        msg := (^dx.MESSAGE)(raw_data(d._impl.msg_buffer))
                        d._impl.info_queue->GetMessage(i, msg, &msg_size)

                        level := severity_to_log_level[msg.Severity]
                        desc := strings.string_from_ptr((^u8)(msg.pDescription), int(msg.DescriptionByteLength))
                        log.log(level, desc, location = loc)
                }

                d._impl.info_queue->ClearStoredMessages()
        }
}


_Device_Impl :: struct {
        device        : ^dx.IDevice,
        debug         : ^dx.IDebug,
        info_queue    : ^dx.IInfoQueue,
        gi_info_queue : ^dxgi.IInfoQueue,
        msg_buffer    : [dynamic]u8,

        input_layout_cache : map[Vertex_Attribute_Flags]^dx.IInputLayout,
}


_device_create :: proc(info: ^Device_Create_Info) -> (d: Device, res: Result) {
        defer _flush_debug_messages(&d)

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
        for _, layout in d._impl.input_layout_cache {
                layout->Release()
        }

        delete(d._impl.input_layout_cache)

        d.immediate_command_buffer._impl.ctx->Release()
        d._impl.device->Release()

        when ODIN_DEBUG {
                if d._impl.debug != nil {
                        d._impl.debug->ReportLiveDeviceObjects({.SUMMARY, .DETAIL, .IGNORE_INTERNAL})
                        _flush_debug_messages(d)
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


_Swapchain_Impl :: struct {
        swapchain          : ^dxgi.ISwapChain1,
        render_target_view : ^dx.IRenderTargetView,
}


_swapchain_create :: proc(d: ^Device, create_info: ^Swapchain_Create_Info) -> (sc: Swapchain, res: Result) {
        defer _flush_debug_messages(d)
        device := d._impl.device

        factory: ^dxgi.IFactory2
        {
                gi_device: ^dxgi.IDevice1
                hres := device->QueryInterface(dxgi.IDevice1_UUID, (^rawptr)(&gi_device))
                check_result(hres, "DXGI device interface query failed") or_return
                defer gi_device->Release()

                gi_adapter: ^dxgi.IAdapter
                hres = gi_device->GetAdapter(&gi_adapter)
                check_result(hres, "DXGI adapter interface query failed") or_return
                defer gi_adapter->Release()

                adapter_desc: dxgi.ADAPTER_DESC
                gi_adapter->GetDesc(&adapter_desc)
                log.infof("Graphics device: %s", adapter_desc.Description)

                hres = gi_adapter->GetParent(dxgi.IFactory2_UUID, (^rawptr)(&factory))
                check_result(hres, "Get DXGI Factory failed") or_return
        }
        defer factory->Release()


        // Swapchain
        {
                swapchain_scaling_flag_to_dx := [Swapchain_Scaling_Flag]dxgi.SCALING {
                        .None = .NONE,
                        .Stretch = .STRETCH,
                        .Fit = .ASPECT_RATIO_STRETCH,
                }

                swapchain_desc := dxgi.SWAP_CHAIN_DESC1 {
                        Width = 0,
                        Height = 0,
                        Format = .B8G8R8A8_UNORM_SRGB,
                        SampleDesc = {
                                Count = 1,
                                Quality = 0,
                        },
                        BufferUsage = {.RENDER_TARGET_OUTPUT},
                        BufferCount = 2,
                        Scaling = swapchain_scaling_flag_to_dx[create_info.scaling],
                        AlphaMode = .UNSPECIFIED,
                        Flags = {},
                }

                if create_info.vsync == false {
                        swapchain_desc.Flags += {.ALLOW_TEARING}
                }

                hres := factory->CreateSwapChainForHwnd(
                        pDevice = device, 
                        hWnd = create_info.window^,
                        pDesc = &swapchain_desc,
                        pFullscreenDesc = nil,
                        pRestrictToOutput = nil,
                        ppSwapChain = &sc._impl.swapchain
                )
                check_result(hres, "Create Swapchain failed") or_return
        }

        // Render target view
        {
                framebuffer : ^dx.ITexture2D
                hres := sc._impl.swapchain->GetBuffer(0, dx.ITexture2D_UUID, (^rawptr)(&framebuffer))
                check_result(hres, "Get Framebuffer failed") or_return
                defer framebuffer->Release()

                hres  = device->CreateRenderTargetView(framebuffer, nil, &sc._impl.render_target_view)
                check_result(hres, "Create Render Target View failed") or_return
        }

        return sc, .Ok
}

_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        defer _flush_debug_messages(d)

        sc._impl.render_target_view->Release()
        sc._impl.swapchain->Release()
}


_Input_Descs_ALL := [Vertex_Attribute_Flag]dx.INPUT_ELEMENT_DESC {
        .Position = {
                SemanticName         = "POSITION",
                SemanticIndex        = 0,
                Format               = .R32G32B32_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Color = {
                SemanticName         = "COLOR",
                SemanticIndex        = 0,
                Format               = .R8G8B8A8_UNORM,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Tex_Coord_0 = {
                SemanticName         = "TEXCOORD",
                SemanticIndex        = 0,
                Format               = .R16G16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Tex_Coord_1 = {
                SemanticName         = "TEXCOORD",
                SemanticIndex        = 1,
                Format               = .R16G16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Normal = {
                SemanticName         = "NORMAL",
                SemanticIndex        = 0,
                Format               = .R16G16B16A16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Tangent = {
                SemanticName         = "TANGENT",
                SemanticIndex        = 0,
                Format               = .R16G16B16A16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Joints_0 = {
                SemanticName         = "JOINTS",
                SemanticIndex        = 0,
                Format               = .R16G16B16A16_UINT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Joints_1 = {
                SemanticName         = "JOINTS",
                SemanticIndex        = 1,
                Format               = .R16G16B16A16_UINT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Weights_0 = {
                SemanticName         = "WEIGHTS",
                SemanticIndex        = 0,
                Format               = .R16G16B16A16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        .Weights_1 = {
                SemanticName         = "WEIGHTS",
                SemanticIndex        = 1,
                Format               = .R16G16B16A16_FLOAT,
                // InputSlot         = 0,
                AlignedByteOffset    = 0,
                InputSlotClass       = .VERTEX_DATA,
                InstanceDataStepRate = 0,
        },
        
}

_Vertex_Shader_Impl :: struct {
        shader       : ^dx.IVertexShader,
        input_layout : ^dx.IInputLayout, // Owned by device, don't destroy
}


_vertex_shader_create :: proc(d: ^Device, create_info: ^Vertex_Shader_Create_Info) -> (shader: Vertex_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreateVertexShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppVertexShader  = &shader._impl.shader
        )
        check_result(hres, "Vertex Shader Create failed") or_return


        layout, exists := d._impl.input_layout_cache[create_info.vertex_attributes]
        if !exists {
                // Create input layout from provided attribute flags.
                // When binding vertex buffers, only the required buffers will be bound.
                attribute_count : u32 = 0
                
                input_descs : [len(Vertex_Attribute_Flag)]dx.INPUT_ELEMENT_DESC

                for attrib in create_info.vertex_attributes {
                        input_descs[attribute_count] = _Input_Descs_ALL[attrib]
                        input_descs[attribute_count].InputSlot = attribute_count
                        attribute_count += 1
                }

               
                layout : ^dx.IInputLayout
                hres = d._impl.device->CreateInputLayout(
                        pInputElementDescs = raw_data(&input_descs),
                        NumElements = attribute_count,
                        pShaderBytecodeWithInputSignature = raw_data(create_info.code),
                        BytecodeLength = dx.SIZE_T(len(create_info.code)),
                        ppInputLayout = &layout
                )
                check_result(hres) or_return
                d._impl.input_layout_cache[create_info.vertex_attributes] = layout
        }

        shader._impl.input_layout = layout
        shader.vertex_attributes  = create_info.vertex_attributes

        return shader, .Ok
}

_vertex_shader_destroy :: proc(d: ^Device, shader: ^Vertex_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}


_Fragment_Shader_Impl :: struct {
        shader : ^dx.IPixelShader,
}

_fragment_shader_create :: proc(d: ^Device, create_info: ^Fragment_Shader_Create_Info) -> (shader: Fragment_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreatePixelShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppPixelShader  = &shader._impl.shader
        )
        check_result(hres, "Vertex Shader Create failed") or_return

        return shader, .Ok
}

_fragment_shader_destroy :: proc(d: ^Device, shader: ^Fragment_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}


_Compute_Shader_Impl :: struct {
        shader : ^dx.IComputeShader,
}

_compute_shader_create :: proc(d: ^Device, create_info: ^Compute_Shader_Create_Info) -> (shader: Compute_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreateComputeShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppComputeShader  = &shader._impl.shader
        )
        check_result(hres, "Vertex Shader Create failed") or_return

        return shader, .Ok
}

_compute_shader_destroy :: proc(d: ^Device, shader: ^Compute_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}



_Command_Buffer_Impl :: struct {
        ctx : ^dx.IDeviceContext,
}



// } // when RHI == "d3d11"
