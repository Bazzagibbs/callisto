#+ private
package callisto_gpu

import "base:runtime"
import "core:strings"
import "core:log"
import "core:mem"

import dx "vendor:directx/d3d11"
import dxgi "vendor:directx/dxgi"
import win "core:sys/windows"
import "../common"

import "core:fmt"

// when RHI_BACKEND == "d3d11" {

check_result :: proc(d: ^Device, hres: dx.HRESULT, message: string, loc: runtime.Source_Code_Location) -> Result {
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

hres_succeeded :: #force_inline proc(hres: dx.HRESULT) -> bool {
        return hres >= 0
}

hres_failed :: #force_inline proc(hres: dx.HRESULT) -> bool {
        return hres < 0
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


_device_create :: proc(info: ^Device_Create_Info, location: runtime.Source_Code_Location) -> (d: Device, res: Result) {
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

        check_result(&d, hres, "Create Device failed", location) or_return

        d.immediate_command_buffer._impl.is_immediate = true

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
                        when RHI_TRACK_RESOURCES {
                                d._impl.debug->ReportLiveDeviceObjects({.SUMMARY, .DETAIL, .IGNORE_INTERNAL})
                                log.info("Expect ID3D11Device Refcount == 3. Ignore the next warning if this is the case.")
                        }
                        _flush_debug_messages(d)
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


_swapchain_create :: proc(d: ^Device, create_info: ^Swapchain_Create_Info, location: runtime.Source_Code_Location) -> (sc: Swapchain, res: Result) {
        defer _flush_debug_messages(d)
        device := d._impl.device

        factory: ^dxgi.IFactory2
        {
                gi_device: ^dxgi.IDevice1
                hres := device->QueryInterface(dxgi.IDevice1_UUID, (^rawptr)(&gi_device))
                check_result(d, hres, "DXGI device interface query failed", location) or_return
                defer gi_device->Release()

                gi_adapter: ^dxgi.IAdapter
                hres = gi_device->GetAdapter(&gi_adapter)
                check_result(d, hres, "DXGI adapter interface query failed", location) or_return
                defer gi_adapter->Release()

                adapter_desc: dxgi.ADAPTER_DESC
                gi_adapter->GetDesc(&adapter_desc)
                log.infof("Graphics device: %s", adapter_desc.Description)

                hres = gi_adapter->GetParent(dxgi.IFactory2_UUID, (^rawptr)(&factory))
                check_result(d, hres, "Get DXGI Factory failed", location) or_return
        }
        defer factory->Release()


        // Swapchain
        {

                swapchain_scaling_flag_to_dx := [Swapchain_Scaling_Flag]dxgi.SCALING {
                        .None    = .NONE,
                        .Stretch = .STRETCH,
                        .Fit     = .ASPECT_RATIO_STRETCH,
                }

                // Don't allow MSAA at swapchain level - create an intermediate render texture and explicitly resolve it.
                sample_desc := dxgi.SAMPLE_DESC {
                        Count   = 1,
                        Quality = 0,
                }

                swapchain_desc := dxgi.SWAP_CHAIN_DESC1 {
                        Width       = u32(create_info.resolution.x),
                        Height      = u32(create_info.resolution.y),
                        Format      = .B8G8R8A8_UNORM,
                        SampleDesc  = sample_desc,
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
                check_result(d, hres, "Create Swapchain failed", location) or_return
        }

        // Render target view
        {
                framebuffer : ^dx.ITexture2D
                hres := sc._impl.swapchain->GetBuffer(0, dx.ITexture2D_UUID, (^rawptr)(&framebuffer))
                check_result(d, hres, "Get Framebuffer failed", location) or_return
                defer framebuffer->Release()

                hres  = device->CreateRenderTargetView(framebuffer, nil, &sc._impl.render_target_view)
                check_result(d, hres, "Create Render Target View failed", location) or_return

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

        check_result(d, hres, "Swapchain resize failed", #location()) or_return

        framebuffer: ^dx.ITexture2D
        hres = sc._impl.swapchain->GetBuffer(
                Buffer    = 0,
                riid      = dx.ITexture2D_UUID,
                ppSurface = (^rawptr)(&framebuffer)
        )
        
        check_result(d, hres, "Get Framebuffer failed", #location())

        defer framebuffer->Release()

        hres = d._impl.device->CreateRenderTargetView(
                pResource = framebuffer,
                pDesc     = nil,
                ppRTView  = &sc._impl.render_target_view
        )

        check_result(d, hres, "Create RenderTargetView failed", #location()) or_return

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
        check_result(d, hres, "Swapchain Present failed", #location()) or_return

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
        .Position2D = {
                SemanticName         = "POSITION",
                SemanticIndex        = 0,
                Format               = .R32G32_FLOAT,
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


_vertex_shader_create :: proc(d: ^Device, create_info: ^Vertex_Shader_Create_Info, location: runtime.Source_Code_Location) -> (shader: Vertex_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreateVertexShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppVertexShader  = &shader._impl.shader
        )
        check_result(d, hres, "Vertex Shader Create failed", location) or_return


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
                check_result(d, hres, "Create Input Layout failed", location) or_return
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

_fragment_shader_create :: proc(d: ^Device, create_info: ^Fragment_Shader_Create_Info, location: runtime.Source_Code_Location) -> (shader: Fragment_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreatePixelShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppPixelShader  = &shader._impl.shader
        )
        check_result(d, hres, "Vertex Shader Create failed", location) or_return

        return shader, .Ok
}

_fragment_shader_destroy :: proc(d: ^Device, shader: ^Fragment_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}


_Compute_Shader_Impl :: struct {
        shader : ^dx.IComputeShader,
}

_compute_shader_create :: proc(d: ^Device, create_info: ^Compute_Shader_Create_Info, location: runtime.Source_Code_Location) -> (shader: Compute_Shader, res: Result) {
        defer _flush_debug_messages(d)
        
        hres := d._impl.device->CreateComputeShader(
                pShaderBytecode = raw_data(create_info.code),
                BytecodeLength  = dx.SIZE_T(len(create_info.code)),
                pClassLinkage   = nil,
                ppComputeShader  = &shader._impl.shader
        )
        check_result(d, hres, "Vertex Shader Create failed", location) or_return

        return shader, .Ok
}

_compute_shader_destroy :: proc(d: ^Device, shader: ^Compute_Shader) {
        defer _flush_debug_messages(d)

        shader._impl.shader->Release()
}


_Buffer_Impl :: struct {
        buffer: ^dx.IBuffer,
}


_buffer_create :: proc(d: ^Device, create_info: ^Buffer_Create_Info, location: runtime.Source_Code_Location) -> (buffer: Buffer, res: Result) {
        defer _flush_debug_messages(d)

        ua := _Resource_Access_To_Dx11[create_info.access]

        buffer_desc := dx.BUFFER_DESC {
                ByteWidth              = u32(create_info.size),
                Usage                  = ua.usage,
                CPUAccessFlags         = ua.access,
                BindFlags              = _buffer_usage_flags_to_dx11(create_info.usage),
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
        check_result(d, hres, "Create Buffer failed", location) or_return

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

_Sampler_Impl :: struct {
        sampler : ^dx.ISamplerState,
}


_sampler_create :: proc(d: ^Device, create_info: ^Sampler_Create_Info, location: runtime.Source_Code_Location) -> (sampler: Sampler, res: Result) {
        defer _flush_debug_messages(d)

        address_mode := _Sampler_Address_Flag_To_Dx11[create_info.address_mode]

        desc := dx.SAMPLER_DESC {
                Filter         = _sampler_filter_to_dx11(create_info.min_filter, create_info.mag_filter, create_info.mip_filter, create_info.max_anisotropy),
                AddressU       = address_mode,
                AddressV       = address_mode,
                AddressW       = address_mode,
                MipLODBias     = create_info.lod_bias,
                MaxAnisotropy  = _sampler_aniso_to_dx11(create_info.max_anisotropy),
                ComparisonFunc = .ALWAYS,
                BorderColor    = _Sampler_Border_Color_Flag_To_Dx11[create_info.border_color],
                MinLOD         = create_info.min_lod,
                MaxLOD         = create_info.max_lod,
        }

        // D3D11 caches identical samplers internally
        hres := d._impl.device->CreateSamplerState(&desc, &sampler._impl.sampler)
        check_result(d, hres, "Create Sampler failed", location) or_return

        return sampler, .Ok
}

_sampler_destroy :: proc(d: ^Device, sampler: ^Sampler) {
        defer _flush_debug_messages(d)

        sampler._impl.sampler->Release()
}


_Blend_State_Impl :: struct {
        state: ^dx.IBlendState,
}

_blend_state_create :: proc(d: ^Device, create_info: ^Blend_State_Create_Info, location: runtime.Source_Code_Location) -> (blend: Blend_State, res: Result) {
        defer _flush_debug_messages(d)

        target_desc: [8]dx.RENDER_TARGET_BLEND_DESC = ---
        for i in 0..<len(create_info.render_target_blends) {
                rt_blend := create_info.render_target_blends[i]
                target_desc[i] = {
                        BlendEnable           = dx.BOOL(rt_blend.blend_enable),
                        SrcBlend              = _Blend_To_Dx11[rt_blend.src_color_blend_factor],
                        DestBlend             = _Blend_To_Dx11[rt_blend.dst_color_blend_factor],
                        BlendOp               = _Blend_Op_To_Dx11[rt_blend.color_blend_op],
                        SrcBlendAlpha         = _Blend_To_Dx11[rt_blend.src_alpha_blend_factor],
                        DestBlendAlpha        = _Blend_To_Dx11[rt_blend.dst_alpha_blend_factor],
                        BlendOpAlpha          = _Blend_Op_To_Dx11[rt_blend.alpha_blend_op],
                        RenderTargetWriteMask = transmute(u8)(rt_blend.color_write_mask),
                }
        }

        blend_desc := dx.BLEND_DESC {
                AlphaToCoverageEnable  = dx.BOOL(create_info.alpha_to_coverage),
                IndependentBlendEnable = dx.BOOL(create_info.independent_blends),
                RenderTarget           = target_desc,
        }

        hres := d._impl.device->CreateBlendState(&blend_desc, &blend._impl.state)
        check_result(d, hres, "Blend State Create failed", location) or_return

        return blend, .Ok
}

_blend_state_destroy :: proc(d: ^Device, blend: ^Blend_State) {
        defer _flush_debug_messages(d)
        blend._impl.state->Release()
}

_Depth_Stencil_State_Impl :: struct {
        state: ^dx.IDepthStencilState,
}

_depth_stencil_state_create :: proc(d: ^Device, create_info: ^Depth_Stencil_State_Create_Info, location: runtime.Source_Code_Location) -> (depth_stencil_state: Depth_Stencil_State, res: Result) {
        defer _flush_debug_messages(d)

        front := dx.DEPTH_STENCILOP_DESC {
                StencilFailOp      = _Stencil_Op_To_Dx11[create_info.stencil_frontface.stencil_fail_op],
                StencilDepthFailOp = _Stencil_Op_To_Dx11[create_info.stencil_frontface.depth_fail_op],
                StencilPassOp      = _Stencil_Op_To_Dx11[create_info.stencil_frontface.stencil_pass_op],
                StencilFunc        = _Compare_Op_To_Dx11[create_info.stencil_frontface.stencil_compare_op],
        }

        back := dx.DEPTH_STENCILOP_DESC {
                StencilFailOp      = _Stencil_Op_To_Dx11[create_info.stencil_backface.stencil_fail_op],
                StencilDepthFailOp = _Stencil_Op_To_Dx11[create_info.stencil_backface.depth_fail_op],
                StencilPassOp      = _Stencil_Op_To_Dx11[create_info.stencil_backface.stencil_pass_op],
                StencilFunc        = _Compare_Op_To_Dx11[create_info.stencil_backface.stencil_compare_op],
        }

        desc := dx.DEPTH_STENCIL_DESC {
                DepthEnable      = dx.BOOL(create_info.depth_enable),
                DepthWriteMask   = .ALL if create_info.depth_write_enable else .ZERO,
                DepthFunc        = _Compare_Op_To_Dx11[create_info.depth_compare_op],
                StencilEnable    = dx.BOOL(create_info.stencil_enable),
                StencilReadMask  = create_info.stencil_read_mask,
                StencilWriteMask = create_info.stencil_write_mask,
                FrontFace        = front,
                BackFace         = back,
        }

        hres := d._impl.device->CreateDepthStencilState(&desc, &depth_stencil_state._impl.state)
        check_result(d, hres, "Create DepthStencil State failed", location) or_return
        return depth_stencil_state, .Ok
}

_depth_stencil_state_destroy :: proc(d: ^Device, depth_stencil_state: ^Depth_Stencil_State) {
        defer _flush_debug_messages(d)
        depth_stencil_state._impl.state->Release()
}

// _texture1d_create :: proc(d: ^Device, create_info: ^Texture1D_Create_Info, location: runtime.Source_Code_Location) -> (tex: Texture1D, res: Result) {
// defer _flush_debug_messages(d)
//
// }
//
// _texture1d_destroy :: proc(d: ^Device, tex: ^Texture1D, location: runtime.Source_Code_Location) {
// defer _flush_debug_messages(d)
//
// }

_Texture2D_Impl :: struct {
        texture : ^dx.ITexture2D,
}

_texture2d_create :: proc(d: ^Device, create_info: ^Texture2D_Create_Info, location: runtime.Source_Code_Location) -> (tex: Texture2D, res: Result) {
        defer _flush_debug_messages(d)

        MAX_MIP :: 16 // actually 14 (d3d11 max texture size is 2^14)

        ua := _Resource_Access_To_Dx11[create_info.access]

        sample_desc := dxgi.SAMPLE_DESC {
                Count = _multisample_to_dx11(create_info.multisample),
                Quality = 0 if create_info.multisample == .None else 0xffffffff, // D3D11_STANDARD_MULTISAMPLE_PATTERN
        }

        desc := dx.TEXTURE2D_DESC {
                Width          = u32(create_info.resolution.x),
                Height         = u32(create_info.resolution.y),
                MipLevels      = u32(create_info.mip_levels),
                ArraySize      = 1,
                Format         = _Format_To_Dx11[create_info.format],
                SampleDesc     = sample_desc,
                Usage          = ua.usage,
                BindFlags      = _texture_usage_flags_to_dx11(create_info.usage),
                CPUAccessFlags = ua.access,
                MiscFlags      = {}
        }

        // Move to separate type
        // if create_info.is_cubemap {
        //         desc.MiscFlags += {.TEXTURECUBE}
        // }

        if create_info.allow_generate_mips {
                desc.BindFlags += {.RENDER_TARGET}
                desc.MiscFlags += {.GENERATE_MIPS}
        }

        subresource_infos: [MAX_MIP]dx.SUBRESOURCE_DATA = ---
       
        for i in 0..<len(create_info.initial_data) {
                subresource_infos[i] = {
                        pSysMem     = raw_data(create_info.initial_data[i].data),
                        SysMemPitch = u32(create_info.initial_data[i].row_size),
                }
        }
        
        p_subresource_data := raw_data(&subresource_infos)
        if create_info.initial_data == nil {
                p_subresource_data = nil
        }

        hres := d._impl.device->CreateTexture2D(&desc, p_subresource_data, &tex._impl.texture)
        check_result(d, hres, "Create Texture 2D failed", location) or_return


        tex.resolution   = create_info.resolution
        tex.mip_levels   = create_info.mip_levels
        tex.format       = create_info.format

        return tex, .Ok
}

_texture2d_destroy :: proc(d: ^Device, tex: ^Texture2D) {
        defer _flush_debug_messages(d)

        tex._impl.texture->Release()
}

// _texture3d_create :: proc(d: ^Device, create_info: ^Texture3D_Create_Info, location: runtime.Source_Code_Location) -> (tex: Texture3D, res: Result) {
// defer _flush_debug_messages(d)
//
// }
//
// _texture3d_destroy :: proc(d: ^Device, tex: ^Texture3D) {
// defer _flush_debug_messages(d)
//
// }


_Render_Target_View_Impl :: struct {
        view : ^dx.IRenderTargetView,
}

// _render_target_view_create :: proc()
// defer _flush_debug_messages(d)

// _render_target_view_destroy :: proc()
// defer _flush_debug_messages(d)

_Depth_Stencil_View_Impl :: struct {
        view : ^dx.IDepthStencilView,
}

// _depth_stencil_view_create :: proc()
// defer _flush_debug_messages(d)

// _depth_stencil_view_destroy :: proc()
// defer _flush_debug_messages(d)

_Texture_View_Impl :: struct {
        view : ^dx.IShaderResourceView,
}

_texture2d_view_create :: proc(d: ^Device, tex: ^Texture2D, create_info: ^Texture2D_View_Create_Info, location: runtime.Source_Code_Location) -> (view: Texture_View, res: Result) {
        defer _flush_debug_messages(d)

        // Nil info is valid usage - create full view
        if create_info == nil {
                hres := d._impl.device->CreateShaderResourceView(tex._impl.texture, nil, &view._impl.view)
                check_result(d, hres, "Texture View Create failed", location) or_return

                return view, .Ok
        }
        // -----
       

        dimension := _texture_view_dimension_to_dx11(._2, create_info.multisample, create_info.array, create_info.cubemap)

        desc := dx.SHADER_RESOURCE_VIEW_DESC {
                Format = _Format_To_Dx11[create_info.format],
                ViewDimension = dimension,
                
        }
        
        #partial switch dimension {

        case .TEXTURE2D:
                desc.Texture2D = {
                        MostDetailedMip = u32(create_info.mip_lowest_level),
                        MipLevels       = u32(create_info.mip_levels),
                }

        case .TEXTURE2DMS:
                desc.Texture2DMS = {}

        case .TEXTURE2DARRAY:
                desc.Texture2DArray = {
                        MostDetailedMip = u32(create_info.mip_lowest_level),
                        MipLevels       = u32(create_info.mip_levels),
                        FirstArraySlice = u32(create_info.array_start_layer),
                        ArraySize       = u32(create_info.array_layers),
                }

        case .TEXTURE2DMSARRAY:
                desc.Texture2DMSArray = {
                        FirstArraySlice = u32(create_info.array_start_layer),
                        ArraySize       = u32(create_info.array_layers),
                }

        case .TEXTURECUBE:
                desc.TextureCube = {
                        MostDetailedMip = u32(create_info.mip_lowest_level),
                        MipLevels       = u32(create_info.mip_levels),
                }

        case .TEXTURECUBEARRAY:
                desc.TextureCubeArray = {
                        MostDetailedMip  = u32(create_info.mip_lowest_level),
                        MipLevels        = u32(create_info.mip_levels),
                        First2DArrayFace = u32(create_info.array_start_layer * 6),
                        NumCubes         = u32(create_info.array_layers),
                }
        }

        hres := d._impl.device->CreateShaderResourceView(tex._impl.texture, &desc, &view._impl.view)
        check_result(d, hres, "Texture View Create failed", location) or_return

        return view, .Ok
}

_texture_view_destroy :: proc(d: ^Device, view: ^Texture_View) {
        defer _flush_debug_messages(d)

        view._impl.view->Release()
}

_Command_Buffer_Recording_State_Flag :: enum {
        Ready,
        Recording,
        Pending_Submission,
}

_Command_Buffer_Impl :: struct {
        ctx                : ^dx.IDeviceContext,
        command_list       : ^dx.ICommandList,
        is_immediate       : bool,
        recording_state    : _Command_Buffer_Recording_State_Flag,
        bound_index_count  : u32,
        bound_input_layout : ^dx.IInputLayout,
}

// _command_buffer_create :: proc(d: ^Device, create_info: ^Command_Buffer_Create_Info, location: runtime.Source_Code_Location) -> (cb: Command_Buffer, res: Result) {
// defer _flush_debug_messages(d)
// }
//
// _command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
// defer _flush_debug_messages(d)
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
        
        if cb._impl.is_immediate == false {
                hres := cb._impl.ctx->FinishCommandList(
                        RestoreDeferredContextState = false,
                        ppCommandList = &cb._impl.command_list
                )

                check_result(d, hres, "command_buffer_end failed", #location()) or_return
        }

        cb._impl.recording_state = .Pending_Submission
        return .Ok
}

_command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        if cb._impl.recording_state != .Pending_Submission {
                log.error("command_buffer_submit called while not in Pending_Submission state. Current state:", cb._impl.recording_state)
                return .Synchronization_Error
        }

        if cb._impl.is_immediate == false {
                d.immediate_command_buffer._impl.ctx->ExecuteCommandList(
                        pCommandList        = cb._impl.command_list,
                        RestoreContextState = false
                )

                cb._impl.command_list->Release()
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


_cmd_set_scissor_rects :: proc(cb: ^Command_Buffer, scissor_rects: []Rect2D) {
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


// _cmd_set_buffer_views :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, views: []^Buffer_View) {
// // copy _cmd_set_texture_views, they're the same
// }

_cmd_set_texture_views :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, views: []^Texture_View) {
        MAX_RES :: dx.COMMONSHADER_INPUT_RESOURCE_REGISTER_COUNT
        dx_views : [MAX_RES]^dx.IShaderResourceView

        length := clamp_slice_length_and_log(len(views), MAX_RES - start_slot)
        for i in 0..<length {
                dx_views[i] = views[i]._impl.view
        }
        
        if .Vertex in stages {
                cb._impl.ctx->VSSetShaderResources(
                        StartSlot             = u32(start_slot),
                        NumViews              = u32(length),
                        ppShaderResourceViews = raw_data(&dx_views)
                )
        }
        
        if .Fragment in stages {
                cb._impl.ctx->PSSetShaderResources(
                        StartSlot             = u32(start_slot),
                        NumViews              = u32(length),
                        ppShaderResourceViews = raw_data(&dx_views)
                )
        }
        
        if .Compute in stages {
                cb._impl.ctx->CSSetShaderResources(
                        StartSlot             = u32(start_slot),
                        NumViews              = u32(length),
                        ppShaderResourceViews = raw_data(&dx_views)
                )
        }
}

_cmd_set_samplers :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, samplers: []^Sampler) {
        MAX_SAMPLERS :: dx.COMMONSHADER_SAMPLER_SLOT_COUNT
        dx_samplers : [MAX_SAMPLERS]^dx.ISamplerState

        length := clamp_slice_length_and_log(len(samplers), MAX_SAMPLERS - start_slot)
        for i in 0..<length {
                dx_samplers[i] = samplers[i]._impl.sampler
        }
        
        if .Vertex in stages {
                cb._impl.ctx->VSSetSamplers(
                        StartSlot   = u32(start_slot),
                        NumSamplers = u32(length),
                        ppSamplers  = raw_data(&dx_samplers)
                )
        }
        
        if .Fragment in stages {
                cb._impl.ctx->PSSetSamplers(
                        StartSlot   = u32(start_slot),
                        NumSamplers = u32(length),
                        ppSamplers  = raw_data(&dx_samplers)
                )
        }
        
        if .Compute in stages {
                cb._impl.ctx->CSSetSamplers(
                        StartSlot   = u32(start_slot),
                        NumSamplers = u32(length),
                        ppSamplers  = raw_data(&dx_samplers)
                )
        }
}


_cmd_update_constant_buffer :: proc(cb: ^Command_Buffer, buffer: ^Buffer, data: rawptr) {
        mapped_subresource : dx.MAPPED_SUBRESOURCE
        hres := cb._impl.ctx->Map(
                pResource       = buffer._impl.buffer,
                Subresource     = 0,
                MapType         = .WRITE_DISCARD,
                MapFlags        = {},
                pMappedResource = &mapped_subresource
        )

        if hres_failed(hres) {
                log.error("Constant buffer map failed")
                return 
        }
       
        mem.copy(mapped_subresource.pData, data, buffer.size)
        
        cb._impl.ctx->Unmap(
                pResource = buffer._impl.buffer, 
                Subresource = 0
        )
}

_cmd_set_constant_buffers :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, buffers: []^Buffer) {
        MAX_CB :: dx.COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT
        dx_buffers : [MAX_CB]^dx.IBuffer

        length := clamp_slice_length_and_log(len(buffers), MAX_CB - start_slot)
        for i in 0..<length {
                dx_buffers[i] = buffers[i]._impl.buffer
        }

        if .Vertex in stages {
                cb._impl.ctx->VSSetConstantBuffers(
                        StartSlot         = u32(start_slot),
                        NumBuffers        = u32(length),
                        ppConstantBuffers = raw_data(&dx_buffers)
                )
        }
        
        if .Fragment in stages {
                cb._impl.ctx->PSSetConstantBuffers(
                        StartSlot         = u32(start_slot),
                        NumBuffers        = u32(length),
                        ppConstantBuffers = raw_data(&dx_buffers)
                )
        }
        
        if .Compute in stages {
                cb._impl.ctx->CSSetConstantBuffers(
                        StartSlot         = u32(start_slot),
                        NumBuffers        = u32(length),
                        ppConstantBuffers = raw_data(&dx_buffers)
                )
        }
}

_cmd_clear_render_target :: proc(cb: ^Command_Buffer, view: ^Render_Target_View, color: [4]f32) {
        color := color
        cb._impl.ctx->ClearRenderTargetView(view._impl.view, &color)
}

_cmd_draw :: proc(cb: ^Command_Buffer) {
        cb._impl.ctx->DrawIndexed(cb._impl.bound_index_count, 0, 0)
}


// } // when RHI_BACKEND == "d3d11"
