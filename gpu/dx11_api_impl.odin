#+ private
package callisto_gpu

import "core:strings"
import "core:log"
import dx "vendor:directx/d3d11"
import dxgi "vendor:directx/dxgi"
import win "core:sys/windows"
import "../common"

import "core:fmt"

// when RHI == "d3d11" {

check_result :: proc(d: ^Device, hres: dx.HRESULT, message: string = "", loc := #caller_location) -> Result {
        if hres >= 0 {
                return .Ok
        }        
        
        log.error(message, "-", common.parse_hresult(hres), location = loc)
        
        _flush_debug_messages(d, loc = loc)

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
// There has to be a better way to do this - it loses any messages upon crash unless running through a debugger.
// Is there a way to register a debug messenger callback? Or to intercept the debug output strings?
_flush_debug_messages :: proc(d: ^Device, loc := #caller_location) { 
        when ODIN_DEBUG {
                severity_to_log_level := [dx.MESSAGE_SEVERITY]log.Level {
                        .MESSAGE    = .Debug,
                        .INFO       = .Info,
                        .WARNING    = .Warning,
                        .ERROR      = .Error,
                        .CORRUPTION = .Error,
                }

                gi_severity_to_log_level := [dxgi.INFO_QUEUE_MESSAGE_SEVERITY]log.Level {
                        .MESSAGE    = .Debug,
                        .INFO       = .Info,
                        .WARNING    = .Warning,
                        .ERROR      = .Error,
                        .CORRUPTION = .Error,
                }

                // D3D11 messages
                if d._impl.info_queue != nil {
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

                // DXGI messages
                if d._impl.gi_info_queue != nil {
                        message_count := d._impl.gi_info_queue->GetNumStoredMessages(dxgi.DEBUG_ALL)
                        for i in 0..<message_count {
                                msg_size: dx.SIZE_T
                                d._impl.gi_info_queue->GetMessage(dxgi.DEBUG_ALL, i, nil, &msg_size)

                                if msg_size > cap(d._impl.msg_buffer) {
                                        resize(&d._impl.msg_buffer, int(msg_size))
                                }

                                msg := (^dxgi.INFO_QUEUE_MESSAGE)(raw_data(d._impl.msg_buffer))
                                d._impl.gi_info_queue->GetMessage(dxgi.DEBUG_ALL, i, msg, &msg_size)

                                level := gi_severity_to_log_level[msg.Severity]
                                desc := strings.string_from_ptr((^u8)(msg.pDescription), int(msg.DescriptionByteLength))
                                log.log(level, desc, location = loc)
                        }

                        d._impl.gi_info_queue->ClearStoredMessages(dxgi.DEBUG_ALL)
                }
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

        check_result(&d, hres) or_return

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
                                d._impl.info_queue->SetBreakOnSeverity(.CORRUPTION, false)
                                d._impl.info_queue->SetBreakOnSeverity(.ERROR, false)
                                d._impl.info_queue->SetBreakOnSeverity(.WARNING, false)
                                d._impl.info_queue->SetBreakOnSeverity(.INFO, false)
                                d._impl.info_queue->SetBreakOnSeverity(.MESSAGE, false)

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
                        d._impl.gi_info_queue->SetBreakOnSeverity(dxgi.DEBUG_ALL, .CORRUPTION, false)
                        d._impl.gi_info_queue->SetBreakOnSeverity(dxgi.DEBUG_ALL, .ERROR, false)
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
                check_result(d, hres, "DXGI device interface query failed") or_return
                defer gi_device->Release()

                gi_adapter: ^dxgi.IAdapter
                hres = gi_device->GetAdapter(&gi_adapter)
                check_result(d, hres, "DXGI adapter interface query failed") or_return
                defer gi_adapter->Release()

                adapter_desc: dxgi.ADAPTER_DESC
                gi_adapter->GetDesc(&adapter_desc)
                log.infof("Graphics device: %s", adapter_desc.Description)

                hres = gi_adapter->GetParent(dxgi.IFactory2_UUID, (^rawptr)(&factory))
                check_result(d, hres, "Get DXGI Factory failed") or_return
        }
        defer factory->Release()


        // Swapchain
        {
                swapchain_scaling_flag_to_dx := [Swapchain_Scaling_Flag]dxgi.SCALING {
                        .None    = .NONE,
                        .Stretch = .STRETCH,
                        .Fit     = .ASPECT_RATIO_STRETCH,
                }

                swapchain_desc := dxgi.SWAP_CHAIN_DESC1 {
                        Width  = u32(create_info.resolution.x),
                        Height = u32(create_info.resolution.y),
                        Format = .B8G8R8A8_UNORM,
                        SampleDesc = {
                                Count   = 1,
                                Quality = 0,
                        },
                        BufferUsage = {.RENDER_TARGET_OUTPUT},
                        BufferCount = 2,
                        Scaling     = swapchain_scaling_flag_to_dx[create_info.scaling],
                        SwapEffect  = .FLIP_DISCARD,
                        AlphaMode   = .UNSPECIFIED,
                        Flags       = {},
                }

                if create_info.vsync == false {
                        swapchain_desc.Flags += {.ALLOW_TEARING}
                }

                hres := factory->CreateSwapChainForHwnd(
                        pDevice           = device,
                        hWnd              = create_info.window^,
                        pDesc             = &swapchain_desc,
                        pFullscreenDesc   = nil,
                        pRestrictToOutput = nil,
                        ppSwapChain       = &sc._impl.swapchain
                )
                check_result(d, hres, "Create Swapchain failed") or_return
        }

        // Render target view
        {
                framebuffer : ^dx.ITexture2D
                hres := sc._impl.swapchain->GetBuffer(0, dx.ITexture2D_UUID, (^rawptr)(&framebuffer))
                check_result(d, hres, "Get Framebuffer failed") or_return
                defer framebuffer->Release()

                hres  = device->CreateRenderTargetView(framebuffer, nil, &sc._impl.render_target_view)
                check_result(d, hres, "Create Render Target View failed") or_return

                fb_desc : dx.TEXTURE2D_DESC
                framebuffer->GetDesc(&fb_desc)

                sc.resolution = {int(fb_desc.Width), int(fb_desc.Height)}
        }

        sc.render_target_view = {{
                view = sc._impl.render_target_view,
        }}

        return sc, .Ok
}

_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        defer _flush_debug_messages(d)

        sc._impl.render_target_view->Release()
        sc._impl.swapchain->Release()
}

_swapchain_resize :: proc(d: ^Device, sc: ^Swapchain, resolution: [2]int) -> (res: Result) {
        defer _flush_debug_messages(d)


        d.immediate_command_buffer._impl.ctx->OMSetRenderTargets(
                NumViews            = 0,
                ppRenderTargetViews = nil,
                pDepthStencilView   = nil
        )

        sc.render_target_view._impl.view->Release()

        hres := sc._impl.swapchain->ResizeBuffers(
                BufferCount    = 0,
                Width          = u32(resolution.x),
                Height         = u32(resolution.y),
                NewFormat      = .UNKNOWN,
                SwapChainFlags = {}
        )

        check_result(d, hres, "Swapchain resize failed") or_return

        framebuffer: ^dx.ITexture2D
        hres = sc._impl.swapchain->GetBuffer(
                Buffer    = 0,
                riid      = dx.ITexture2D_UUID,
                ppSurface = (^rawptr)(&framebuffer)
        )
        
        check_result(d, hres, "Get Framebuffer failed")

        defer framebuffer->Release()

        hres = d._impl.device->CreateRenderTargetView(
                pResource = framebuffer,
                pDesc     = nil,
                ppRTView  = &sc._impl.render_target_view
        )

        check_result(d, hres, "Create RenderTargetView failed") or_return

        sc.render_target_view = {{
                view = sc._impl.render_target_view,
        }}


        fb_desc : dx.TEXTURE2D_DESC
        framebuffer->GetDesc(&fb_desc)

        sc.resolution = {int(fb_desc.Width), int(fb_desc.Height)}

        log.info("Swapchain resized")

        return .Ok
}


_swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        flags := dxgi.PRESENT {}
        // if sc.vsync == false {
        //         flags += { .DO_NOT_WAIT, .ALLOW_TEARING }
        // }
        hres := sc._impl.swapchain->Present(
                SyncInterval = 1,
                Flags        = flags
        )
        check_result(d, hres) or_return

        return .Ok
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
        
        hres := d._impl.device->CreateVertexShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppVertexShader  = &shader._impl.shader
        )
        check_result(d, hres, "Vertex Shader Create failed") or_return


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

               
                hres = d._impl.device->CreateInputLayout(
                        pInputElementDescs = raw_data(&input_descs),
                        NumElements = attribute_count,
                        pShaderBytecodeWithInputSignature = raw_data(create_info.code),
                        BytecodeLength = dx.SIZE_T(len(create_info.code)),
                        ppInputLayout = &layout
                )
                check_result(d, hres) or_return
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
        check_result(d, hres, "Vertex Shader Create failed") or_return

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
        check_result(d, hres, "Vertex Shader Create failed") or_return

        return shader, .Ok
}

_compute_shader_destroy :: proc(d: ^Device, shader: ^Compute_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}


_Buffer_Impl :: struct {
        buffer: ^dx.IBuffer,
}

_Usage_Access_Pair :: struct {
        usage  : dx.USAGE,
        access : dx.CPU_ACCESS_FLAGS,
}

_Resource_Access_To_Dx11 := [Resource_Access_Flag]_Usage_Access_Pair {
        .Device_General   = { .DEFAULT, {} },
        .Device_Immutable = { .IMMUTABLE, {} },
        .Host_To_Device   = { .DYNAMIC, {.WRITE} },
        .Device_To_Host   = { .STAGING, {.READ} },
}

_Buffer_Usage_To_Dx11 := [Buffer_Usage_Flag]dx.BIND_FLAG {
        .Vertex           = .VERTEX_BUFFER,
        .Index            = .INDEX_BUFFER,
        .Constant         = .CONSTANT_BUFFER,
        .Shader_Resource  = .SHADER_RESOURCE,
        .Unordered_Access = .UNORDERED_ACCESS,
}

_buffer_create :: proc(d: ^Device, create_info: ^Buffer_Create_Info) -> (buffer: Buffer, res: Result) {
        defer _flush_debug_messages(d)

        ua := _Resource_Access_To_Dx11[create_info.access]

        bind_flags := dx.BIND_FLAGS {}
        for usage in create_info.usage {
                bind_flags += {_Buffer_Usage_To_Dx11[usage]}
        }

        buffer_desc := dx.BUFFER_DESC {
                ByteWidth              = u32(create_info.size),
                Usage                  = ua.usage,
                CPUAccessFlags         = ua.access,
                BindFlags              = bind_flags,
                MiscFlags              = {}, // FEATURE(Indirect) // Structured
                // StructureByteStride = 0,
        }

        subresource_data := dx.SUBRESOURCE_DATA {
                pSysMem             = create_info.initial_data,
                // SysMemPitch      = 0,
                // SysMemSlicePitch = 0,
        }

        hres := d._impl.device->CreateBuffer(
                pDesc        = &buffer_desc,
                pInitialData = &subresource_data,
                ppBuffer     = &buffer._impl.buffer
        )
        check_result(d, hres, "Create Buffer failed") or_return

        buffer.size   = create_info.size
        buffer.stride = create_info.stride
        buffer.length = create_info.size / create_info.stride
        buffer.access = create_info.access
        buffer.usage  = create_info.usage

        return buffer, .Ok
}

_buffer_destroy :: proc(d: ^Device, buffer: ^Buffer) {
        defer _flush_debug_messages(d)

        buffer._impl.buffer->Release()
}

_Render_Target_View_Impl :: struct {
        view : ^dx.IRenderTargetView,
}

// _render_target_view_create :: proc()
// _render_target_view_destroy :: proc()

_Depth_Stencil_View_Impl :: struct {
        view : ^dx.IDepthStencilView,
}

// _depth_stencil_view_create :: proc()
// _depth_stencil_view_destroy :: proc()

_Command_Buffer_Recording_State_Flag :: enum {
        Ready,
        Recording,
        Pending_Submission,
}

_Command_Buffer_Impl :: struct {
        ctx                : ^dx.IDeviceContext,
        is_immediate       : bool,
        recording_state    : _Command_Buffer_Recording_State_Flag,
        bound_index_count  : u32,
        bound_input_layout : ^dx.IInputLayout,
}

// _command_buffer_create :: proc(d: ^Device, create_info: ^Command_Buffer_Create_Info) -> (cb: Command_Buffer, res: Result) {
// }
//
// _command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
// }


_command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        defer _flush_debug_messages(d)

        if cb._impl.recording_state != .Ready {
                log.error("command_buffer_begin called while not in Ready state. Current state:", cb._impl.recording_state)
                return .Synchronization_Error
        }

        cb._impl.ctx->IASetPrimitiveTopology(.TRIANGLELIST)
        cb._impl.bound_index_count = 0
        cb._impl.bound_input_layout = nil


        cb._impl.recording_state = .Recording
        return .Ok
}

_command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        defer _flush_debug_messages(d)

        if cb._impl.recording_state != .Recording {
                log.error("command_buffer_end called while not in Recording state. Current state:", cb._impl.recording_state)
                return .Synchronization_Error
        }

        cb._impl.recording_state = .Pending_Submission
        return .Ok
}

_command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        if cb._impl.recording_state != .Pending_Submission {
                log.error("command_buffer_submit called while not in Pending_Submission state. Current state:", cb._impl.recording_state)
                return .Synchronization_Error
        }

        cb._impl.recording_state = .Ready
        return .Ok
}

_cmd_set_viewports :: proc(cb: ^Command_Buffer, viewports: []Viewport_Info) {
        MAX_VP :: dx.VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE
        length := clamp_slice_length_and_log(len(viewports), MAX_VP)

        dx_viewports : [MAX_VP]dx.VIEWPORT = --- 

        for i in 0..<length {
                vp := viewports[i]

                dx_viewports[i] = {
                        TopLeftX = f32(vp.rect.x),
                        TopLeftY = f32(vp.rect.y),
                        Width    = f32(vp.rect.width),
                        Height   = f32(vp.rect.height),
                        MinDepth = vp.min_depth,
                        MaxDepth = vp.max_depth,
                }
        }
        
        cb._impl.ctx->RSSetViewports(
                NumViewports = min(MAX_VP, len32(viewports)),
                pViewports   = raw_data(&dx_viewports)
        )
}


_cmd_set_scissor_rects :: proc(cb: ^Command_Buffer, scissor_rects: []Rect_2D) {
        MAX_SCISSOR :: dx.VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE
        length := clamp_slice_length_and_log(len(scissor_rects), MAX_SCISSOR)

        dx_scissors : [MAX_SCISSOR]dx.RECT = ---
        
        for i in 0..<length {
                rect := scissor_rects[i]

                dx_scissors[i] = {
                        left   = i32(rect.x),
                        top    = i32(rect.y),
                        right  = i32(rect.x + rect.width),
                        bottom = i32(rect.y + rect.height),
                }
        }

        cb._impl.ctx->RSSetScissorRects(
                NumRects = min(MAX_SCISSOR, len32(scissor_rects)),
                pRects = raw_data(&dx_scissors)
        )
}

_cmd_set_render_targets :: proc(cb: ^Command_Buffer, render_target_views: []^Render_Target_View, depth_stencil_view : ^Depth_Stencil_View) {
        MAX_RT :: dx.SIMULTANEOUS_RENDER_TARGET_COUNT
        length := clamp_slice_length_and_log(len(render_target_views), MAX_RT)

        dx_rts : [MAX_RT]^dx.IRenderTargetView = ---

        for i in 0..<length {
                dx_rts[i] = render_target_views[i]._impl.view
        }

        dx_depth_stencil : ^dx.IDepthStencilView = nil 
        if depth_stencil_view != nil {
                dx_depth_stencil = depth_stencil_view._impl.view
        } 

        cb._impl.ctx->OMSetRenderTargets(
                NumViews = min(MAX_RT, len32(render_target_views)),
                ppRenderTargetViews = raw_data(&dx_rts),
                pDepthStencilView = dx_depth_stencil
        )
}


_cmd_set_vertex_shader :: proc(cb: ^Command_Buffer, shader: ^Vertex_Shader) {
        if shader._impl.input_layout != cb._impl.bound_input_layout {
                cb._impl.bound_input_layout = shader._impl.input_layout
                cb._impl.ctx->IASetInputLayout(cb._impl.bound_input_layout)
        }

        cb._impl.ctx->VSSetShader(
                pVertexShader     = shader._impl.shader,
                ppClassInstances  = nil,
                NumClassInstances = 0
        )
}

_cmd_set_fragment_shader :: proc(cb: ^Command_Buffer, shader: ^Fragment_Shader) {
        cb._impl.ctx->PSSetShader(
                pPixelShader      = shader._impl.shader,
                ppClassInstances  = nil,
                NumClassInstances = 0
        )
}

_cmd_set_compute_shader :: proc(cb: ^Command_Buffer, shader: ^Compute_Shader) {
        cb._impl.ctx->CSSetShader(
                pComputeShader    = shader._impl.shader,
                ppClassInstances  = nil,
                NumClassInstances = 0
        )
}

_cmd_set_vertex_buffers :: proc(cb: ^Command_Buffer, buffers: []^Buffer) {
        MAX_VB :: dx.IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT
        length := clamp_slice_length_and_log(len(buffers), MAX_VB)

        dx_buffers : [MAX_VB]^dx.IBuffer = ---
        strides    : [MAX_VB]u32         = ---
        offsets    : [MAX_VB]u32         = {}

        for i in 0..<length {
                dx_buffers[i] = buffers[i]._impl.buffer
                strides[i]    = u32(buffers[i].stride)
        }

        cb._impl.ctx->IASetVertexBuffers(
                StartSlot       = 0,
                NumBuffers      = u32(length),
                ppVertexBuffers = raw_data(&dx_buffers),
                pStrides        = raw_data(&strides),
                pOffsets        = raw_data(&offsets)
        )
}


_cmd_set_index_buffer :: proc(cb: ^Command_Buffer, buffer: ^Buffer) {
        format := dxgi.FORMAT.R32_UINT if buffer.stride == 4 else dxgi.FORMAT.R16_UINT

        cb._impl.bound_index_count = u32(buffer.length)

        cb._impl.ctx->IASetIndexBuffer(
                pIndexBuffer = buffer._impl.buffer,
                Format       = format,
                Offset       = 0,
        )
}

_cmd_clear_render_target :: proc(cb: ^Command_Buffer, view: ^Render_Target_View, color: [4]f32) {
        color := color
        cb._impl.ctx->ClearRenderTargetView(view._impl.view, &color)
}

_cmd_draw :: proc(cb: ^Command_Buffer) {
        cb._impl.ctx->DrawIndexed(cb._impl.bound_index_count, 0, 0)
}


// } // when RHI == "d3d11"
