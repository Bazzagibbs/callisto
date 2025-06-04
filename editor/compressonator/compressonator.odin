//=====================================================================
// Copyright (c) 2007-2024    Advanced Micro Devices, Inc. All rights reserved.
// Copyright (c) 2004-2006    ATI Technologies Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// \file Compressonator.h
//
//=====================================================================
//
// Modifications to be valid C by Bailey Gibbons 2025
package compressonator

import "core:c"

_ :: c

foreign import lib {
        "lib/Compressonator_MT.lib",
        "system:ole32.lib",
}


AMD_COMPRESS_VERSION_MAJOR :: 4  // The major version number of this release.
AMD_COMPRESS_VERSION_MINOR :: 3  // The minor version number of this release.

Byte :: u8

Word :: u16

DWord :: u32

Bool :: bool

DWord_Ptr :: uintptr

Long :: c.long

Int :: c.int

// VOID :: Void

UInt :: c.uint

Float :: f32

SByte :: c.char

Char :: c.char

HalfShort :: u16

// typedef std::vector<uint8_t> CMP_VEC8;
Std_Vector_U8 :: struct {
	first: ^u8,
	last:  ^u8,
	end:   ^u8,
}

Double :: f64

// API :: _Cdecl

// Texture format.
Format :: enum c.int {
	Unknown               = 0,     // Undefined texture format.
	RGBA_8888_S           = 16,    // RGBA format with signed 8-bit fixed channels.
	ARGB_8888_S           = 32,    // ARGB format with signed 8-bit fixed channels.
	ARGB_8888             = 48,    // ARGB format with 8-bit fixed channels.
	ABGR_8888             = 64,    // ABGR format with 8-bit fixed channels.
	RGBA_8888             = 80,    // RGBA format with 8-bit fixed channels.
	BGRA_8888             = 96,    // BGRA format with 8-bit fixed channels.
	RGB_888               = 112,   // RGB format with 8-bit fixed channels.
	RGB_888_S             = 128,   // RGB format with 8-bit fixed channels.
	BGR_888               = 144,   // BGR format with 8-bit fixed channels.
	RG_8_S                = 160,   // Two component format with signed 8-bit fixed channels.
	RG_8                  = 176,   // Two component format with 8-bit fixed channels.
	R_8_S                 = 192,   // Single component format with signed 8-bit fixed channel.
	R_8                   = 208,   // Single component format with 8-bit fixed channel.
	ARGB_2101010          = 224,   // ARGB format with 10-bit fixed channels for color & a 2-bit fixed channel for alpha.
	RGBA_1010102          = 240,   // RGBA format with 10-bit fixed channels for color & a 2-bit fixed channel for alpha.
	ARGB_16               = 256,   // ARGB format with 16-bit fixed channels.
	ABGR_16               = 272,   // ABGR format with 16-bit fixed channels.
	RGBA_16               = 288,   // RGBA format with 16-bit fixed channels.
	BGRA_16               = 304,   // BGRA format with 16-bit fixed channels.
	RG_16                 = 320,   // Two component format with 16-bit fixed channels.
	R_16                  = 336,   // Single component format with 16-bit fixed channels.
	RGBE_32F              = 4096,  // RGB format with 9-bit floating point each channel and shared 5 bit exponent
	ARGB_16F              = 4112,  // ARGB format with 16-bit floating-point channels.
	ABGR_16F              = 4128,  // ABGR format with 16-bit floating-point channels.
	RGBA_16F              = 4144,  // RGBA format with 16-bit floating-point channels.
	BGRA_16F              = 4160,  // BGRA format with 16-bit floating-point channels.
	RG_16F                = 4176,  // Two component format with 16-bit floating-point channels.
	R_16F                 = 4192,  // Single component with 16-bit floating-point channels.
	ARGB_32F              = 4208,  // ARGB format with 32-bit floating-point channels.
	ABGR_32F              = 4224,  // ABGR format with 32-bit floating-point channels.
	RGBA_32F              = 4240,  // RGBA format with 32-bit floating-point channels.
	BGRA_32F              = 4256,  // BGRA format with 32-bit floating-point channels.
	RGB_32F               = 4272,  // RGB format with 32-bit floating-point channels.
	BGR_32F               = 4288,  // BGR format with 32-bit floating-point channels.
	RG_32F                = 4304,  // Two component format with 32-bit floating-point channels.
	R_32F                 = 4320,  // Single component with 32-bit floating-point channels.
	BROTLIG               = 8192,  //< Lossless CMP format compression : Prototyping
	BC1                   = 17,    // DXGI_FORMAT_BC1_UNORM GL_COMPRESSED_RGBA_S3TC_DXT1_EXT A four component opaque (or 1-bit alpha)
                                  // compressed texture format for Microsoft DirectX10. Identical to DXT1.  Four bits per pixel.
	BC2                   = 33,    // DXGI_FORMAT_BC2_UNORM VK_FORMAT_BC2_UNORM_BLOCK GL_COMPRESSED_RGBA_S3TC_DXT3_EXT A four component
                                  // compressed texture format with explicit alpha for Microsoft DirectX10. Identical to DXT3. Eight bits per pixel.
	BC3                   = 49,    // DXGI_FORMAT_BC3_UNORM VK_FORMAT_BC3_UNORM_BLOCK GL_COMPRESSED_RGBA_S3TC_DXT5_EXT A four component
                                  // compressed texture format with interpolated alpha for Microsoft DirectX10. Identical to DXT5. Eight bits per pixel.
	BC4                   = 65,    // DXGI_FORMAT_BC4_UNORM VK_FORMAT_BC4_UNORM_BLOCK GL_COMPRESSED_RED_RGTC1 A single component
                                  // compressed texture format for Microsoft DirectX10. Identical to ATI1N. Four bits per pixel.
	BC4_S                 = 4161,  // DXGI_FORMAT_BC4_SNORM VK_FORMAT_BC4_SNORM_BLOCK GL_COMPRESSED_SIGNED_RED_RGTC1 A single component
                                  // compressed texture format for Microsoft DirectX10. Identical to ATI1N. Four bits per pixel.
	BC5                   = 81,    // DXGI_FORMAT_BC5_UNORM VK_FORMAT_BC5_UNORM_BLOCK GL_COMPRESSED_RG_RGTC2 A two component
                                  // compressed texture format for Microsoft DirectX10. Identical to ATI2N_XY. Eight bits per pixel.
	BC5_S                 = 4177,  // DXGI_FORMAT_BC5_SNORM VK_FORMAT_BC5_SNORM_BLOCK GL_COMPRESSED_RGBA_BPTC_UNORM A two component
                                  // compressed texture format for Microsoft DirectX10. Identical to ATI2N_XY. Eight bits per pixel.
	BC6H                  = 97,    // DXGI_FORMAT_BC6H_UF16 VK_FORMAT_BC6H_UFLOAT_BLOCK GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT BC6H compressed texture format (UF)
	BC6H_SF               = 4193,  // DXGI_FORMAT_BC6H_SF16 VK_FORMAT_BC6H_SFLOAT_BLOCK GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT   BC6H compressed texture format (SF)
	BC7                   = 113,   // DXGI_FORMAT_BC7_UNORM VK_FORMAT_BC7_UNORM_BLOCK GL_COMPRESSED_RGBA_BPTC_UNORM BC7  compressed texture format
	ATI1N                 = 321,   // DXGI_FORMAT_BC4_UNORM VK_FORMAT_BC4_UNORM_BLOCK GL_COMPRESSED_RED_RGTC1 Single component
                                     // compression format using the same technique as DXT5 alpha. Four bits per pixel.
	ATI2N                 = 337,   // DXGI_FORMAT_BC5_UNORM VK_FORMAT_BC5_UNORM_BLOCK GL_COMPRESSED_RG_RGTC2 Two component compression format using the same
                                     // technique as DXT5 alpha. Designed for compression of tangent space normal maps. Eight bits per pixel.
	ATI2N_XY              = 338,   // DXGI_FORMAT_BC5_UNORM VK_FORMAT_BC5_UNORM_BLOCK GL_COMPRESSED_RG_RGTC2 Two component compression format using the
                                     // same technique as DXT5 alpha. The same as ATI2N but with the channels swizzled. Eight bits per pixel.
	ATI2N_DXT5            = 339,   // DXGI_FORMAT_BC5_UNORM VK_FORMAT_BC5_UNORM_BLOCK GL_COMPRESSED_RG_RGTC2 ATI2N like format
                                     // using DXT5. Intended for use on GPUs that do not natively support ATI2N. Eight bits per pixel.
	DXT1                  = 529,   // DXGI_FORMAT_BC1_UNORM VK_FORMAT_BC1_RGB_UNORM_BLOCK GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
                               // A DXTC compressed texture matopaque (or 1-bit alpha). Four bits per pixel.
	DXT3                  = 545,   // DXGI_FORMAT_BC2_UNORM VK_FORMAT_BC2_UNORM_BLOCK GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
                               // DXTC compressed texture format with explicit alpha. Eight bits per pixel.
	DXT5                  = 561,   // DXGI_FORMAT_BC3_UNORM VK_FORMAT_BC3_UNORM_BLOCK GL_COMPRESSED_RGBA_S3TC_DXT5_EXT
                                    // DXTC compressed texture format with interpolated alpha. Eight bits per pixel.
	DXT5_xGBR             = 594,   // DXGI_FORMAT_UNKNOWN DXT5 with the red component swizzled into the alpha channel. Eight bits per pixel.
	DXT5_RxBG             = 595,   // DXGI_FORMAT_UNKNOWN swizzled DXT5 format with the green component swizzled into the alpha channel. Eight bits per pixel.
	DXT5_RBxG             = 596,   // DXGI_FORMAT_UNKNOWN swizzled DXT5 format with the green component swizzled
                                    // into the alpha channel & the blue component swizzled into the green channel. Eight bits per pixel.
	DXT5_xRBG             = 597,   // DXGI_FORMAT_UNKNOWN swizzled DXT5 format with the green component swizzled into
                                    // the alpha channel & the red component swizzled into the green channel. Eight bits per pixel.
	DXT5_RGxB             = 598,   // DXGI_FORMAT_UNKNOWN swizzled DXT5 format with the blue component swizzled into the alpha channel. Eight bits per pixel.
	DXT5_xGxR             = 599,   // two-component swizzled DXT5 format with the red component swizzled into the alpha channel &
                                    // the green component in the green channel. Eight bits per pixel.
	ATC_RGB               = 769,   // CMP - a compressed RGB format.
	ATC_RGBA_Explicit     = 770,   // CMP - a compressed ARGB format with explicit alpha.
	ATC_RGBA_Interpolated = 771,   // CMP - a compressed ARGB format with interpolated alpha.
	ASTC                  = 2561,  // DXGI_FORMAT_UNKNOWN   VK_FORMAT_ASTC_4x4_UNORM_BLOCK to VK_FORMAT_ASTC_12x12_UNORM_BLOCK
	APC                   = 2562,  // APC Texture Compressor
	PVRTC                 = 2563,
	ETC_RGB               = 3585,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK GL_COMPRESSED_RGB8_ETC2  backward compatible
	ETC2_RGB              = 3586,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK GL_COMPRESSED_RGB8_ETC2
	ETC2_SRGB             = 3587,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK GL_COMPRESSED_SRGB8_ETC2
	ETC2_RGBA             = 3588,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK GL_COMPRESSED_RGBA8_ETC2_EAC
	ETC2_RGBA1            = 3589,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2
	ETC2_SRGBA            = 3590,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC
	ETC2_SRGBA1           = 3591,  // DXGI_FORMAT_UNKNOWN VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2
	BINARY                = 2817,  //< Binary/Raw Data Format
	GTC                   = 2818,  //< GTC   Fast Gradient Texture Compressor
	BASIS                 = 2819,  //< BASIS compression
	MAX                   = 65535, // Invalid Format
}

// Compress error codes
Error :: enum c.int {
	OK = 0,                           // Ok.
	ABORTED,                          // The conversion was aborted.
	ERR_INVALID_SOURCE_TEXTURE,       // The source texture is invalid.
	ERR_INVALID_DEST_TEXTURE,         // The destination texture is invalid.
	ERR_UNSUPPORTED_SOURCE_FORMAT,    // The source format is not a supported format.
	ERR_UNSUPPORTED_DEST_FORMAT,      // The destination format is not a supported format.
	ERR_UNSUPPORTED_GPU_ASTC_DECODE,  // The gpu hardware is not supported.
	ERR_UNSUPPORTED_GPU_BASIS_DECODE, // The gpu hardware is not supported.
	ERR_SIZE_MISMATCH,                // The source and destination texture sizes do not match.
	ERR_UNABLE_TO_INIT_CODEC,         // Compressonator was unable to initialize the codec needed for conversion.
	ERR_UNABLE_TO_INIT_DECOMPRESSLIB, // GPU_Decode Lib was unable to initialize the codec needed for decompression .
	ERR_UNABLE_TO_INIT_COMPUTELIB,    // Compute Lib was unable to initialize the codec needed for compression.
	ERR_CMP_DESTINATION,              // Error in compressing destination texture
	ERR_MEM_ALLOC_FOR_MIPSET,         // Memory Error: allocating MIPSet compression level data buffer
	ERR_UNKNOWN_DESTINATION_FORMAT,   // The destination Codec Type is unknown! In SDK refer to GetCodecType()
	ERR_FAILED_HOST_SETUP,            // Failed to setup Host for processing
	ERR_PLUGIN_FILE_NOT_FOUND,        // The required plugin library was not found
	ERR_UNABLE_TO_LOAD_FILE,          // The requested file was not loaded
	ERR_UNABLE_TO_CREATE_ENCODER,     // Request to create an encoder failed
	ERR_UNABLE_TO_LOAD_ENCODER,       // Unable to load an encode library
	ERR_NOSHADER_CODE_DEFINED,        // No shader code is available for the requested framework
	ERR_GPU_DOESNOT_SUPPORT_COMPUTE,  // The GPU device selected does not support compute
	ERR_NOPERFSTATS,                  // No Performance Stats are available
	ERR_GPU_DOESNOT_SUPPORT_CMP_EXT,  // The GPU does not support the requested compression extension!
	ERR_GAMMA_OUTOFRANGE,             // Gamma value set for processing is out of range
	ERR_PLUGIN_SHAREDIO_NOT_SET,      // The plugin C_PluginSetSharedIO call was not set and is required for this plugin to operate
	ERR_UNABLE_TO_INIT_D3DX,          // Unable to initialize DirectX SDK or get a specific DX API
	FRAMEWORK_NOT_INITIALIZED,        // CMP_InitFramework failed or not called.
	ERR_GENERIC,                      // An unknown error occurred.
}

// An enum selecting the different GPU driver types.
Compute_Type :: enum c.int {
	UNKNOWN = 0,
	CPU     = 1, //Use CPU Only, encoders defined CMP_CPUEncode or Compressonator lib will be used
	HPC     = 2, //Use CPU High Performance Compute Encoders with SPMD support defined in CMP_CPUEncode)
	GPU_OCL = 3, //Use GPU Kernel Encoders to compress textures using OpenCL Framework
	GPU_DXC = 4, //Use GPU Kernel Encoders to compress textures using DirectX Compute Framework
	GPU_VLK = 5, //Use GPU Kernel Encoders to compress textures using Vulkan Compute Framework
	GPU_HW  = 6, //Use GPU HW to encode textures , using gl extensions
}

Compute_Options :: struct {
	force_rebuild:  bool,   //Force the GPU host framework to rebuild shaders
	plugin_compute: rawptr, // Ref to Encoder codec plugin: For Internal use (will be removed!)
}

Compute_Extensions :: enum c.int {
	FP16     = 1, // Enable Packed Math Option for GPU
	MAX_ENUM = 32767,
}

Kernel_Performance_Stats :: struct {
	m_computeShaderElapsedMS: Float, // Total Elapsed Shader Time to process all the blocks
	m_num_blocks:             Int,   // Number of Texel (Typically 4x4) blocks
	m_CmpMTxPerSec:           Float, // Number of Mega Texels processed per second
}

Kernel_Device_Info :: struct {
	m_deviceName: [256]Char, // Device name (CPU or GPU)
	m_version:    [128]Char, // Kernel pipeline version number (CPU or GPU)
	m_maxUCores:  Int,       // Max Unit device CPU cores or GPU compute units (CU)
}

Kernel_Options :: struct {
	Extensions:    Compute_Extensions,       // Compute extentions to use, set to 0 if you are not using any extensions
	height:        DWord,                    // Height of the encoded texture.
	width:         DWord,                    // Width of the encoded texture.
	fquality:      Float,                    // Set the quality used for encoders 0.05 is the lowest and 1.0 for highest.
	format:        Format,                   // Encoder codec format to use for processing
	srcformat:     Format,                   // Format of source data
	encodeWith:    Compute_Type,             // Host Type : default is HPC, options are [HPC or GPU]
	threads:       Int,                      // requested number of threads to use (1= single) max is 128 for HPC and 0 is auto (usually 2 per CPU core)
	getPerfStats:  Bool,                     // Set to true if you want to get Performance Stats
	perfStats:     Kernel_Performance_Stats, // Data storage for the performance stats obtained from GPU or CPU while running encoder processing
	getDeviceInfo: Bool,                     // Set to true if you want to get target Device Info
	deviceInfo:    Kernel_Device_Info,       // Data storage for the target device
	genGPUMipMaps: Bool,                     // When ecoding with GPU HW use it to generate Compressed MipMap images, valid only if source has no miplevels
	miplevels:     Int,                      // When using GPU HW, generate upto this requested miplevel.
	useSRGBFrames: Bool,                     // Use SRGB frame buffer when generating HW based mipmaps (Default Gamma corretion will be set by HW)
                                           // if the source is SNORM then this option is enabled regardless of setting

	// The following applies to CMP_FORMAT format options
	using _: struct #raw_union {
		encodeoptions: [32]Byte, // Aligned data block for encoder options

		// Options for BC15 which is a subset of low level : CMP_BC15Options, ref: SetUserBC15EncoderOptions() for settings
		bc15:          struct {
			useChannelWeights:  Bool,
			channelWeights:     [3]Float,
			useAdaptiveWeights: Bool,
			useAlphaThreshold:  Bool,
			alphaThreshold:     Int,
			useRefinementSteps: Bool,
			refinementSteps:    Int,
		},
	},
	size:          UInt,                     // Size of *data
	data:          rawptr,                   // Data to pass down from CPU to kernel
	dataSVM:       rawptr,                   // Data allocated as Shared by CPU and GPU (used only when code is running in 64bit and devices support SVM)
	srcfile:       cstring,                  // Shader source file location
}

MS_FLAG_Default :: 0
MS_FLAG_AlphaPremult :: 1
MS_FLAG_DisableMipMapping :: 2
AMD_MAX_CMDS :: 20
AMD_MAX_CMD_STR :: 32
AMD_MAX_CMD_PARAM :: 16

Amd_Cmd_Set :: struct {
	strCommand:   [32]Char,
	strParameter: [16]Char,
}

// An enum selecting the speed vs. quality trade-off.
Speed :: enum c.int {
	Normal,    // Highest quality mode
	Fast,      // Slightly lower quality but much faster compression mode - DXTn & ATInN only
	SuperFast, // Slightly lower quality but much, much faster compression mode - DXTn & ATInN only
}

// An enum selecting the different GPU driver types.
GPU_Decode :: enum c.int {
	OPENGL = 0, // Use OpenGL   to decode Textures (default)
	DIRECTX,    // Use DirectX  to decode Textures
	VULKAN,     // Use Vulkan  to decode Textures
	INVALID,
}

// CMP_PrintInfo
// function for printing std out info to users.
Print_Info_Str :: #type proc "c" (infoStr: cstring)

// User options and setting used for processing
Compress_Options :: struct {
	dwSize:                     DWord,                    // The size of this structure.

	// New to v4.5
	// Flags to control parameters in Brotli-G compression preconditioning
	doPreconditionBRLG: bool,
	doDeltaEncodeBRLG:          bool,
	doSwizzleBRLG:              bool,
	dwPageSize:                 DWord,                    // Used by Brotli-G Codec for setting the page size used for compression
	bUseRefinementSteps:        Bool,                     // Used by BC1, BC2, and BC3 codecs to improve quality,
                                   // this setting will increase encoding time for better quality results
	nRefinementSteps:           Int,                      // Currently only 1 step is implemented
	bUseChannelWeighting:       Bool,                     // Use channel weights. With swizzled formats the weighting applies to the data within the specified
                                      // channel not the channel itself. Channel weigthing is not implemented for BC6H and BC7
	fWeightingRed:              Float,                    // The weighting of the Red or X Channel.
	fWeightingGreen:            Float,                    // The weighting of the Green or Y Channel.
	fWeightingBlue:             Float,                    // The weighting of the Blue or Z Channel.
	bUseAdaptiveWeighting:      Bool,                     // Adapt weighting on a per-block basis.
	bDXT1UseAlpha:              Bool,                     // Encode single-bit alpha data. Only valid when compressing to DXT1 & BC1.
	bUseGPUDecompress:          Bool,                     // Use GPU to decompress. Decode API can be changed by specified in DecodeWith parameter. Default is OpenGL.
	bUseCGCompress:             Bool,                     // Use SPMD/GPU to compress. Encode API can be changed by specified in EncodeWith parameter. Default is OpenCL.
	nAlphaThreshold:            Byte,                     // The alpha threshold to use when compressing to DXT1 & BC1 with bDXT1UseAlpha.
                                      // Texels with an alpha value less than the threshold are treated as transparent.
                                      // Note: When nCompressionSpeed is not set to Normal AphaThreshold is ignored for DXT1 & BC1
	bDisableMultiThreading:     Bool,                     // Disable multi-threading of the compression. This will slow the compression but can be
                                      // useful if you're managing threads in your application.
                                      // if set BC7 dwnumThreads will default to 1 during encoding and then return back to its original value when done.
	nCompressionSpeed:          Speed,                    // The trade-off between compression speed & quality.
                                      // Notes:
                                      // 1. This value is ignored for BC6H and BC7 (for BC7 the compression speed depends on fquaility value)
                                      // 2. For 64 bit DXT1 to DXT5 and BC1 to BC5 nCompressionSpeed is ignored and set to Noramal Speed
                                      // 3. To force the use of nCompressionSpeed setting regarless of Note 2 use fQuality at 0.05
	nGPUDecode:                 GPU_Decode,               // This value is set using DecodeWith argument (OpenGL, DirectX) default is OpenGL
	nEncodeWith:                Compute_Type,             // This value is set using EncodeWith argument, currently only OpenCL is used
	dwnumThreads:               DWord,                    // Number of threads to initialize for BC7 encoding (Max up to 128). Default set to auto,
	fquality:                   Float,                    // Quality of encoding. This value ranges between 0.0 and 1.0. BC7 & BC6 default is 0.05, others codecs are set at 1.0
                                      // setting fquality above 0.0 gives the fastest, lowest quality encoding, 1.0 is the slowest,
                                      // highest quality encoding. Default set to a low value of 0.05
	brestrictColour:            Bool,                     // This setting is a quality tuning setting for BC7 which may be necessary for convenience in some
                                      // applications. Default set to false. If set and the block does not need alpha it instructs
                                      //  the code not to use modes that have combined colour + alpha - this avoids the possibility that the encoder might
                                      //  choose an alpha other than 1.0 (due to parity) and cause something to become accidentally slightly transparent
                                      //  (it's possible that when encoding 3-component texture applications will assume that the 4th component can
                                      //  safely be assumed to be 1.0 all the time.)
	brestrictAlpha:             Bool,                     // This setting is a quality tuning setting for BC7 which may be necessary for some textures. Default set to false,
                                      // if set it will also apply restriction to blocks with alpha to avoid issues with punch-through
                                      // or thresholded alpha encoding
	dwmodeMask:                 DWord,                    // Mode to set BC7 to encode blocks using any of 8 different block modes in order to obtain the highest quality. Default set to 0xFF)
                           // You can combine the bits to test for which modes produce the best image quality.
                           // The mode that produces the best image quality above a set quality level (fquality) is used and subsequent modes set in the mask
                           // are not tested, this optimizes the performance of the compression versus the required quality.
                           // If you prefer to check all modes regardless of the quality then set the fquality to a value of 0
	NumCmds:                    c.int,                    // Count of the number of command value pairs in CmdSet[].  Max value that can be set is AMD_MAX_CMDS = 20 on this release
	CmdSet:                     [20]Amd_Cmd_Set,          // Extended command options that can be set for the specified codec\n
                                       // Example to set the number of threads and quality used for compression\n
                                       //        CMP_CompressOptions Options;\n
                                       //        memset(Options,0,sizeof(CMP_CompressOptions));\n
                                       //        Options.dwSize = sizeof(CMP_CompressOptions)\n
                                       //        Options.CmdSet[0].strCommand   = "NumThreads"\n
                                       //        Options.CmdSet[0].strParameter = "8";\n
                                       //        Options.CmdSet[1].strCommand   = "Quality"\n
                                       //        Options.CmdSet[1].strParameter = "1.0";\n
                                       //        Options.NumCmds = 2;\n
	fInputDefog:                Float,                    // ToneMap properties for float type image send into non float compress algorithm.
	fInputExposure:             Float,
	fInputKneeLow:              Float,
	fInputKneeHigh:             Float,
	fInputGamma:                Float,
	fInputFilterGamma:          Float,                    // Gamma correction value applied for mipmap generation
	iCmpLevel:                  Int,                      // < draco setting: compression level (range 0-10: higher mean more compressed) - default 7
	iPosBits:                   Int,                      // quantization bits for position - default 14
	iTexCBits:                  Int,                      // quantization bits for texture coordinates - default 12
	iNormalBits:                Int,                      // quantization bits for normal - default 10
	iGenericBits:               Int,                      // quantization bits for generic - default 8
	iVcacheSize:                Int,                      // For mesh vertices optimization, hardware vertex cache size. (value range 1 - no limit as it
                              // allows users to simulate hardware cache size to find the most optimum size)- default is enabled with cache size = 16
	iVcacheFIFOSize:            Int,                      // For mesh vertices optimization, hardware vertex cache size. (value range 1 - no limit as it
                              // allows users to simulate hardware cache size to find the most optimum size)- default is disabled.
	fOverdrawACMR:              Float,                    // For mesh overdraw optimization,  optimize overdraw with ACMR (average cache miss ratio)
                              // threshold value specified (value range 1-3) - default is enabled with ACMR value = 1.05 (i.e. 5% worse)
	iSimplifyLOD:               Int,                      // simplify mesh using LOD (Level of Details) value specified.(value range 1- no limit as it allows users
                              // to simplify the mesh until the level they desired. Higher level means less triangles drawn, less details.)
	bVertexFetch:               bool,                     // optimize vertices fetch . boolean value 0 - disabled, 1-enabled. -default is enabled.
	SourceFormat:               Format,
	DestFormat:                 Format,
	format_support_hostEncoder: Bool,                     // Temp setting used while encoding with gpu or hpc plugins

	// User Print Info interface
	m_PrintInfoStr: Print_Info_Str,
	getPerfStats:               Bool,                     // Set to true if you want to get Performance Stats
	perfStats:                  Kernel_Performance_Stats, // Data storage for the performance stats obtained from GPU or CPU while running encoder processing
	getDeviceInfo:              Bool,                     // Set to true if you want to get target device info
	deviceInfo:                 Kernel_Device_Info,       // Data storage for the performance stats obtained from GPU or CPU while running encoder processing
	genGPUMipMaps:              Bool,                     // When ecoding with GPU HW use it to generate MipMap images, valid only when miplevels is set else default is toplevel 1
	useSRGBFrames:              Bool,                     // when using GPU HW for encoding and mipmap generation use SRGB frames, default is RGB
	miplevels:                  Int,                      // miplevels to use when GPU is used to generate them
}

/// The format of data in the channels of texture.
Channel_Format :: enum c.int {
	_8bit      = 0,  // 8-bit integer data.
	Float16    = 1,  // 16-bit float data.
	Float32    = 2,  // 32-bit float data.
	Compressed = 3,  // Compressed data.
	_16bit     = 4,  // 16-bit integer data.
	_2101010   = 5,  // 10-bit integer data in the color channels & 2-bit integer data in the alpha channel.
	_32bit     = 6,  // 32-bit integer data.
	Float9995E = 7,  // 32-bit partial precision float.
	YUV_420    = 8,  // YUV Chroma formats
	YUV_422    = 9,  // YUV Chroma formats
	YUV_444    = 10, // YUV Chroma formats
	YUV_4444   = 11, // YUV Chroma formats
	_1010102   = 12,
}

// The type of data the texture represents. Do not change the index values, they are used in saved files
Texture_Data_Type :: enum c.int {
	XRGB       = 0, // An RGB texture padded to DWORD width.
	ARGB       = 1, // An ARGB texture.
	NORMAL_MAP = 2, // A normal map.
	R          = 3, // A single component texture.
	RG         = 4, // A two component texture.
	YUV_SD     = 5, // An YUB Standard Definition texture.
	YUV_HD     = 6, // An YUB High Definition texture.
	RGB        = 7, // An RGB texture
	_8         = 8, // 8  Bit untyped data
	_16        = 9, // 16 Bit untyped data
}

// The type of the texture or Data: Do not change the index values, they are used in saved files
Texture_Type :: enum c.int {
	_2D           = 0, // A regular 2D texture. data stored linearly (rgba,rgba,...rgba)
	CubeMap       = 1, // A cubemap texture.
	VolumeTexture = 2, // A volume texture.
	_2D_Block     = 3, // 2D texture data stored as [Height][Width] blocks as individual channels using cmp_rgb_t or cmp_yuv_t
	_1D           = 4, // Untyped data stored linearly
	Unknown       = 5, // Unknown type of texture : No data is stored for this type
}

// typedef CMP_TextureType TextureType;
Color :: struct {
	using _: struct #raw_union {
		rgba:    [4]Byte, // The color as an array of components.
		asDword: DWord,   // The color as a DWORD.
	},
}

D3DX_FILTER_NONE :: 1
D3DX_FILTER_POINT :: 2
D3DX_FILTER_LINEAR :: 3
D3DX_FILTER_TRIANGLE :: 4
D3DX_FILTER_BOX :: 5

D3DX_FILTER_DITHER :: 1 << 19
D3DX_FILTER_SRGB :: 3 << 21
D3DX_FILTER_MIRROR :: 7 << 16

CFilter_Parameters :: struct {
	nFilterType:        c.int,   // This is either CPU Box Filter or GPU Based CMP_D3DX_FILTER_... definitions
	dwMipFilterOptions: c.ulong, // Selects options for the Filter Type
	nMinSize:           c.int,   // Minimum MipMap Level requested
	fGammaCorrection:   f32,     // Apply Gamma correction to RGB channels, using this value as a power exponent,value of 0 or 1 = no correction
	fSharpness:         f32,     // Uses Fidelity Fx CAS sharpness, default 0 No sharpness set
	destWidth:          c.int,   // Scale source texture width to destWidth default 0 no scaleing
	destHeight:         c.int,   // Scale source texture height to destHeight default 0 no scalwing
	useSRGB:            bool,    // if set true process image as SRGB else use linear color space. Default is false
}

Vision_Process :: enum c.int {
	DEFAULT = 0, // Run image analysis or processing options, Align,Crop,SSIM, PSNR, ...
	LSTD    = 1, // Run Laplacian operator and calculate standard deviation values
}

CVision_Process_Options :: struct {
	nProcessType: Vision_Process, // Type of image processing to perform
	Auto:         Bool,           // Use Auto stting to align and crop images
	AlignImages:  Bool,           // Align the Test image with the source image
	ShowImages:   Bool,           // Display processed images
	SaveMatch:    Bool,           // Save auto match image
	SaveImages:   Bool,           // Save processed images
	SSIM:         Bool,           // Run SSIM on test image
	PSNR:         Bool,           // Run PSNR on test image
	ImageDiff:    Bool,           // Run Image Diff
	CropImages:   Bool,           // Crop the Test image with the source image using Crop %
	Crop:         Int,            // Crop images within a set % range
}

CVision_Process_Results :: struct {
	result:    Int,   // Return 0 is success else error value
	imageSize: Int,   // 0: if Source and Test Images are aligned with width & height
                         // 1: Images were auto resized prior to processing
                         // 2: Images are not the same size
	srcLSTD:   Float, // Laplacian Standard Deviation if the source sample
	tstLSTD:   Float, // Laplacian Standard Deviation if the test   sample
	normLSTD:  Float, // Normalized Laplacian Standard Deviation = tstLSTD / srcLSTD
	SSIM:      Float, // Simularity Index of Test Sample compared to the source
	PSNR:      Float, // Simularity Index of Test Sample compared to the source
}

// A MipLevel is the fundamental unit for containing texture data.
// \remarks
// One logical mip level can be composed of many MipLevels, see the documentation of MipSet for explanation.
// \sa \link
Mip_Level :: struct {
	m_nWidth:       Int,   // Width of the data in pixels.
	m_nHeight:      Int,   // Height of the data in pixels.
	m_dwLinearSize: DWord, // Size of the data in bytes.
	using _: struct #raw_union {
		m_psbData:   [^]SByte,         // pointer signed 8  bit.data blocks
		m_pbData:    [^]Byte,          // pointer unsigned 8  bit.data blocks
		m_pwData:    [^]Word,          // pointer unsigned 16 bit.data blocks
		m_pcData:    [^]Color,         // pointer to a union (array of 4 unsigned 8 bits or one 32 bit) data blocks
		m_pfData:    [^]Float,         // pointer to 32-bit signed float data blocks
		m_phfsData:  [^]HalfShort,     // pointer to 16 bit short  data blocks
		m_pdwData:   [^]DWord,         // pointer to 32 bit data blocks
		m_pvec8Data: [^]Std_Vector_U8, // std::vector unsigned 8 bits data blocks
	},
}

// typedef CMP_MipLevel MipLevel;
Mip_Level_Table :: [^]^Mip_Level// A pointer to a set of MipLevels.


// Each texture and all its mip-map levels are encapsulated in a MipSet.
// Do not depend on m_pMipLevelTable being there, it is an implementation detail that you see only because there is no easy cross-complier
// way of passing data around in internal classes.
//
// For 2D textures there are m_nMipLevels MipLevels.
// Cube maps have multiple faces or sides for each mip-map level . Instead of making a totally new data type, we just made each one of these faces be represented by a MipLevel, even though the terminology can be a bit confusing at first. So if your cube map consists of 6 faces for each mip-map level, then your first mip-map level will consist of 6 MipLevels, each having the same m_nWidth, m_nHeight. The next mip-map level will have half the m_nWidth & m_nHeight as the previous, but will be composed of 6 MipLevels still.
// A volume texture is a 3D texture. Again, instead of creating a new data type, we chose to make use of multiple MipLevels to create a single mip-map level of a volume texture. So a single mip-map level of a volume texture will consist of many MipLevels, all having the same m_nWidth and m_nHeight. The next mip-map level will have m_nWidth and m_nHeight half of the previous mip-map level's (to a minimum of 1) and will be composed of half as many MipLevels as the previous mip-map level (the first mip-map level takes this number from the MipSet it's part of), to a minimum of one.
Mip_Set :: struct {
	m_nWidth:          Int,               // User Setting: Width in pixels of the topmost mip-map level of the mip-map set. Initialized by TC_AppAllocateMipSet.
	m_nHeight:         Int,               // User Setting: Height in pixels of the topmost mip-map level of the mip-map set. Initialized by TC_AppAllocateMipSet.
	m_nDepth:          Int,               // User Setting: Depth in MipLevels of the topmost mip-map level of the mip-map set. Initialized by TC_AppAllocateMipSet. See Remarks.
	m_format:          Format,            // User Setting: Format for this MipSet
	m_ChannelFormat:   Channel_Format,    // A texture is usually composed of channels, such as RGB channels for a texture with red green and
	m_TextureDataType: Texture_Data_Type, // An indication of the type of data that the texture contains. A texture with just
	m_TextureType:     Texture_Type,      // Indicates whether the texture is 2D, a cube map, or a volume texture. Used to determine how to
	m_Flags:           UInt,              // Flags that mip-map set.
	m_CubeFaceMask:    Byte,              // A mask of MS_CubeFace values indicating which cube-map faces are present.
	m_dwFourCC:        DWord,             // The FourCC for this mip-map set. 0 if the mip-map set is uncompressed. Generated using
                                        // MAKEFOURCC (defined in the Platform SDK or DX SDK).
	m_dwFourCC2:       DWord,             // An extra FourCC used by The Compressonator internally. Our DDS plugin saves/loads m_dwFourCC2 from
                                        // pDDSD ddpfPixelFormat.dwPrivateFormatBitCount (since it's not really used by anything else) whether
                                        // or not it is 0. Generated using MAKEFOURCC (defined in the Platform SDK or DX SDK).
                                        // The FourCC2 field is currently used to allow differentiation between the various swizzled DXT5 formats.
                                        // These formats must have a FourCC of DXT5 to be supported by the DirectX runtime but
                                        // Compressonator needs to know the swizzled FourCC to correctly display the texture.
	m_nMaxMipLevels:   Int,               // Set by The Compressonator when you call TC_AppAllocateMipSet based on the width, height,
                                        // depth, and textureType values passed in. Is really the maximum number of mip-map levels
                                        // possible for that texture including the topmost mip-map level if you integer divide width,
                                        // height, and depth by 2, rounding down but never falling below 1 until all three of them are 1.
                                        // So a 5x10 2D texture would have a m_nMaxMipLevels of 4 (5x10  2x5  1x2  1x1).
	m_nMipLevels:      Int,               // The number of mip-map levels in the mip-map set that actually have data. Always less than or equal to m_nMaxMipLevels.
                                   // Set to 0 after TC_AppAllocateMipSet.
	m_transcodeFormat: Format,            // For universal format: Sets the target data format for data processing and analysis
	m_compressed:      Bool,              // New Flags if data is compressed (example Block Compressed data in form of BCxx)
	m_isDeCompressed:  Format,            // The New MipSet is a decompressed result from a prior Compressed MipSet Format specified
	m_swizzle:         Bool,              // Flag is used by image load and save to indicate channels were swizzled from the origial source
	m_nBlockWidth:     Byte,              // Width in pixels of the Compression Block that is to be processed default  4
	m_nBlockHeight:    Byte,              // Height in pixels of the Compression Block that is to be processed default 4
	m_nBlockDepth:     Byte,              // Depth in pixels of the Compression Block that is to be processed default  1
	m_nChannels:       Byte,              // Number of channels used min is 1 max is 4, 0 defaults to 1
	m_isSigned:        Byte,              // channel data is signed (has + and - data values)
	dwWidth:           DWord,             // set by various API for ref,Width of the current active miplevel. if toplevel mipmap then value is same as m_nWidth
	dwHeight:          DWord,             // set by various API for ref,Height of the current active miplevel. if toplevel mipmap then value is same as m_nHeight
	dwDataSize:        DWord,             // set by various API for ref,Size of the current active miplevel allocated texture data.
	pData:             [^]Byte,           // set by various API for ref,Pointer to the current active miplevel texture data: used in MipLevelTable
	m_pMipLevelTable:  Mip_Level_Table,   // set by various API for ref, This is an implementation dependent way of storing the MipLevels
                                          // that this mip-map set contains. Do not depend on it, use TC_AppGetMipLevel to access a mip-map set's MipLevels.
	m_pReservedData:   rawptr,            // Reserved for binary data loading

	// Reserved for internal data tracking
	m_nIterations: Int,

	// Tracking for HW based mipmap compression
	m_atmiplevel: Int,
	m_atfaceorslice:   Int,
}

// The structure describing a texture.
Texture :: struct {
	dwSize:          DWord,   // Size of this structure.
	dwWidth:         DWord,   // Width of the texture.
	dwHeight:        DWord,   // Height of the texture.
	dwPitch:         DWord,   // Distance to start of next line,
                                 // necessary only for uncompressed textures.
	format:          Format,  // Format of the texture.
	transcodeFormat: Format,  // if the "format" is CMP_FORMAT_BASIS; A optional target
                                 // format can be set here (default is BC1),
                                 // it can also be conditionally set runtime
	nBlockHeight:    Byte,    // if the source is a compressed format,
                                 // specify its block dimensions (Default nBlockHeight = 4).
	nBlockWidth:     Byte,    // (Default nBlockWidth = 4)
	nBlockDepth:     Byte,    // For ASTC this is the z setting. (Default nBlockDepth = 1)
	dwDataSize:      DWord,   // Size of the current pData texture data
	pData:           [^]Byte, // Pointer to the texture data to process, this can be the
                                 // image source or a specific MIP level
	pMipSet:         rawptr,  // Pointer to a MipSet structure, typically used by Load Texture
                                 // and Save Texture. Users can access any MIP level or cube map
                                 // buffer using MIP Level access API and this pointer.
}

// Internal : BRLG Extra Info maps to MipSet m_pReservedData
BRLG_Extra_Info :: struct {
	fileName: cstring,
	numChars: DWord,
}

// A BRLG file stores one or more separately compressed blocks, where each block corresponds to a single input file
// It is theoretically possible (though not currently supported in Compressonator) to extract only a single block from the BRLG file and decompress it
//
// BRLG File Structure as of version 2 (is 100% compatible with version 1)
//   -> Starts with the BRLG_FileHeader struct
//   -> For each block (corresponding to a source file) there is a BRLG_BlockHeader struct, optional file name (of variable size), and the compressed data
BRLG_File_Header :: struct {
	fileType:     [4]Byte, // expected to be equal to 'B' 'R' 'L' 'G'
	majorVersion: Byte,

	// number of bytes needed for the header
	headerSize: UInt,

	// number of bytes remaining in the file (after subtracting the file header size)
	compressedDataSize: DWord,
}

BRLG_Block_Header :: struct {
	originalWidth:           DWord,             // Texture width or original data size for other data types
	originalHeight:          UInt,              // Texture height, or 1 if originalWidth contains the original data size
	originalFormat:          Format,
	originalTextureType:     Texture_Type,      // CMP_TextureType : 2D, Cubemap, Volume, etc..
	originalTextureDataType: Texture_Data_Type, // CMP_TextureDataType: Type of data stored
	extraDataSize:           UInt,              // size of the extra data stored after this structure, currently only the original file name
	compressedBlockSize:     UInt,              // Size in bytes of the compressed block data
}

//==================================================
//API Definitions for Compressonator v3.1
//==================================================
// Number of image components
BC_COMPONENT_COUNT :: 4

// Number of bytes in a BC7 Block
// #define BC_BLOCK_BYTES (4 * 4)
BC_BLOCK_BYTES :: 16

// Number of pixels in a BC7 block
// #define BC_BLOCK_PIXELS BC_BLOCK_BYTES
BC_BLOCK_PIXELS :: 16

// This defines the ordering in which components should be packed into
// the block for encoding
BC_Component :: enum c.int {
	RED   = 0,
	GREEN = 1,
	BLUE  = 2,
	ALPHA = 3,
}

BC_Error :: enum c.int {
	NONE,
	LIBRARY_NOT_INITIALIZED,
	LIBRARY_ALREADY_INITIALIZED,
	INVALID_PARAMETERS,
	OUT_OF_MEMORY,
}

BC7_Block_Encoder :: struct {
}

BC6H_Block_Encoder :: struct {
}

BC6H_Block_Parameters :: struct {
	dwMask:         Word, // User can enable or disable specific modes default is 0xFFFF
	fExposure:      f32,  // Sets the image lighter (using larger values) or darker (using lower values) default is 0.95
	bIsSigned:      bool, // Specify if half floats are signed or unsigned BC6H_UF16 or BC6H_SF16
	fQuality:       f32,  // Reserved: not used in BC6H at this time
	bUsePatternRec: bool, // Reserved: for new algorithm to use mono pattern shape matching based on two pixel planes
}

// CMP_Feedback_Proc
// Feedback function for conversion.
// \param[in] fProgress The percentage progress of the texture compression.
// \param[in] mipProgress The current MIP level been processed, value of fProgress = mipProgress
// \return non-NULL(true) value to abort conversion
Feedback_Proc :: #type proc "c" (fProgress: f32, pUser1: DWord_Ptr, pUser2: DWord_Ptr) -> (abort: bool)

//==================================================
// API Definitions for Compressonator v3.2 and higher
//===================================================
Mip_Progress_Parameters :: struct {
	mipProgress: Float, // The percentage progress of the current MIP level texture compression
	mipLevel:    Int,   // returns the current MIP level been processed 0..max available for the image
	cubeFace:    Int,   // returns the current Cube Face been processed 1..6
}

// The structure describing block encoder level settings.
Encoder_Setting :: struct {
	width:   c.uint, // Width of the encoded texture.
	height:  c.uint, // Height of the encoded texture.
	pitch:   c.uint, // Distance to start of next line..
	quality: f32,    // Set the quality used for encoders 0.05 is the lowest and 1.0 for highest.
	format:  c.uint, // Format of the encoder to use: this is a enum set see compressonator.h CMP_FORMAT
}

Analysis_Modes :: enum c.int {
	CMP_ANALYSIS_MSEPSNR = 0, // Enable Measurement of MSE and PSNR for 2 mipset image samples
}

Analysis_Data :: struct {
	analysisMode:   c.ulong, // Bit mapped setting to enable various forms of image anlaysis
	channelBitMap:  c.uint,  // Bit setting for active channels to do analysis on and reserved features
                                  // msb(....ABGR)lsb
	fInputDefog:    f32,     // default = 0.0f
	fInputExposure: f32,     // default = 0.0f
	fInputKneeLow:  f32,     // default = 0.0f
	fInputKneeHigh: f32,     // default = 5.0f
	fInputGamma:    f32,     // default = 2.2f
	mse:            f32,     // Mean Square Error for all active channels in a given CMP_FORMAT
	mseR:           f32,     // Mean Square for Red Channel
	mseG:           f32,     // Mean Square for Green
	mseB:           f32,     // Mean Square for Blue
	mseA:           f32,     // Mean Square for Alpha
	psnr:           f32,     // Peak Signal Ratio for all active channels in a given CMP_FORMAT
	psnrR:          f32,     // Peak Signal Ratio for Red Chennel
	psnrG:          f32,     // Peak Signal Ratio for Green
	psnrB:          f32,     // Peak Signal Ratio for Blue
	psnrA:          f32,     // Peak Signal Ratio for Alpha
}

// CMP_MIPFeedback_Proc
// Feedback function for conversion.
// \param[in] fProgress The percentage progress of the texture compression.
// \param[in] mipProgress The current MIP level been processed, value of fProgress = mipProgress
// \return non-NULL(true) value to abort conversion
Mip_Feedback_Proc :: #type proc "c" (mipProgress: Mip_Progress_Parameters) -> (abort: bool)

Codec_Feedback_Proc :: #type proc "c" (fProgress: f32, pUser1: DWord_Ptr, pUser2: DWord_Ptr) -> (abort: bool)

@(default_calling_convention="c", link_prefix="CMP_")
foreign lib {
	MaxFacesOrSlices :: proc(pMipSet: ^Mip_Set, nMipLevel: Int) -> Int ---

	//=================================================================================
	//
	// InitializeBCLibrary() - Startup the BC6H or BC7 library
	//
	// Must be called before any other library methods are valid
	InitializeBCLibrary :: proc() -> BC_Error ---

	// ShutdownBCLibrary - Shutdown the BC6H or BC7 library
	ShutdownBCLibrary :: proc() -> BC_Error ---

	// CMP_CreateBC6HEncoder() - Creates an encoder object with the specified quality and settings for BC6H codec
	// CMP_CreateBC7Encoder()  - Creates an encoder object with the specified quality and settings for BC7  codec
	//
	// Library must be initialized before calling this function.
	//
	// Arguments and Settings:
	//
	//      quality       - Quality of encoding. This value ranges between 0.0 and 1.0. (Valid only for BC7 in this release) default is 0.01
	//                      0.0 gives the fastest, lowest quality encoding, 1.0 is the slowest, highest quality encoding
	//                      In general even quality level 0.0 will give very good results on the vast majority of images
	//                      Higher quality settings may be needed for some difficult images (e.g. normal maps) to give good results
	//                      Encoding time will increase significantly at high quality levels. Quality levels around 0.8 will
	//                      give very close to the highest possible quality, increasing the level above this will cause large
	//                      increases in encoding time for very marginal gains in quality
	//
	//      performance   - Perfromance of encoding. This value ranges between 0.0 and 1.0. (Valid only for BC7 in this release) Typical default is 1.0
	//                      Encoding time can be reduced by incresing this value for a given Quality level. Lower values will improve overall quality with
	//                        optimal setting been performed at a value of 0.
	//
	//      restrictColor - (for BC7) This setting is a quality tuning setting which may be necessary for convenience in some applications.
	//                      BC7 can be used for encoding data with up to four-components (e.g. ARGB), but the output of a BC7 decoder
	//                        is effectively always 4-components, even if the original input contained less
	//                      If BC7 is used to encode three-component data (e.g. RGB) then the encoder generally assumes that it doesn't matter what
	//                      ends up in the 4th component of the data, however some applications might be written in such a way that they
	//                      expect the 4th component to always be 1.0 (this might, for example, allow mixing of textures with and without
	//                      alpha channels without special handling). In this example case the default behaviour of the encoder might cause some
	//                      unexpected results, as the alpha channel is not guaranteed to always contain exactly 1.0 (since some error may be distributed
	//                      into the 4th channel)
	//                      If the restrictColor flag is set then for any input blocks where the 4th component is always 1.0 (255) the encoder will
	//                      restrict itself to using encodings where the reconstructed 4th component is also always guaranteed to contain 1.0 (255)
	//                      This may cause a very slight loss in overall quality measured in absolute RMS error, but this will generally be negligible
	//
	//      restrictAlpha - (for BC7) This setting is a quality tuning setting which may be necessary for some textures. Some textures may need alpha values
	//                      of 1.0 and 0.0 to be exactly represented, but some BC7 block modes distribute error between the colour and alpha
	//                      channels (because they have a shared least significant bit in the encoding). This could result in the alpha values
	//                      being pulled away from zero or one by the global minimization of the error. If this flag is specified then the encoder
	//                      will restrict its behaviour so that for blocks which contain an alpha of zero or one then these values should be
	//                      precisely represented
	//
	//      modeMask      - This is an advanced option. (Valid only for BC7 in this release)
	//                      BC7 can encode blocks using any of 8 different block modes in order to obtain the highest quality (for reference of how each
	//                      of these block modes work consult the BC7 specification)
	//                      Under some circumstances it is possible that it might be desired to manipulate the encoder to only produce certain modes
	//                      Using this setting it is possible to instruct the encoder to only use certain block modes.
	//                      This input is a bitmask of permitted modes for the encoder to use - for normal operation it should be set to 0xFF (all modes valid)
	//                      The bitmask is arranged such that a setting of 0x1 only allows the encoder to use block mode 0.
	//                      0x80 would only permit the use of block mode 7
	//                      Restricting the available modes will generally reduce quality, but will also increase encoding speed
	//
	//      encoder       - Address of a pointer to an encoder.
	//                      This function will allocate a BC7BlockEncoder or BC6HBlockEncoder object using new
	//
	//      isSigned      - For BC6H this flag sets the bit layout, false = UF16 (unsigned float) and true = SF16 (signed float)
	//
	// Note: For BC6H quality and modeMask are reserved for future release
	CreateBC6HEncoder :: proc(user_settings: BC6H_Block_Parameters, encoder: ^^BC6H_Block_Encoder) -> BC_Error ---
	CreateBC7Encoder  :: proc(quality: f64, restrictColour: Bool, restrictAlpha: Bool, modeMask: DWord, performance: f64, encoder: ^^BC7_Block_Encoder) -> BC_Error ---

	// CMP_EncodeBC7Block()  - Enqueue a single BC7  block to the library for encoding
	// CMP_EncodeBC6HBlock() - Enqueue a single BC6H block to the library for encoding
	//
	// For BC7:
	// Input is expected to be a single 16 element block containing 4 components in the range 0.->255.
	// Pixel data in the block should be arranged in row-major order
	// For three-component input images the 4th component (BC7_COMP_ALPHA) should be set to 255 for
	// all pixels to ensure optimal encoding
	//
	// For BC6H:
	// Input is expected to be a single 16 element block containing 4 components in Half-Float format (16bit).
	// Pixel data in the block should be arranged in row-major order.
	// the 4th component should be set to 0, since Alpha is not supported in BC6H
	EncodeBC7Block  :: proc(encoder: ^BC7_Block_Encoder, _in: ^[16][4]f64, out: [^]Byte) -> BC_Error ---
	EncodeBC6HBlock :: proc(encoder: ^BC6H_Block_Encoder, _in: ^[16][4]Float, out: [^]Byte) -> BC_Error ---

	// CMP_DecodeBC6HBlock() - Decode a BC6H block to an uncompressed output
	// CMP_DecodeBC7Block()  - Decode a BC7 block to an uncompressed output
	//
	// This function takes a pointer to an encoded BC block as input, decodes it and writes out the result
	DecodeBC6HBlock :: proc(_in: [^]Byte, out: ^[16][4]Float) -> BC_Error ---
	DecodeBC7Block  :: proc(_in: [^]Byte, out: ^[16][4]f64) -> BC_Error ---

	// CMP_DestroyBC6HEncoder() - Deletes a previously allocated encoder object
	// CMP_DestroyBC7Encoder()  - Deletes a previously allocated encoder object
	DestroyBC6HEncoder :: proc(encoder: ^BC6H_Block_Encoder) -> BC_Error ---
	DestroyBC7Encoder  :: proc(encoder: ^BC7_Block_Encoder) -> BC_Error ---

	// Calculates the required buffer size for the specified texture
	// \param[in] pTexture A pointer to the texture.
	// \return    The size of the buffer required to hold the texture data.
	CalculateBufferSize :: proc(pTexture: ^Texture) -> DWord ---

	// Converts the source texture to the destination texture
	// This can be compression, decompression or converting between two uncompressed formats.
	// \param[in] pSourceTexture A pointer to the source texture.
	// \param[in] pDestTexture A pointer to the destination texture.
	// \param[in] pOptions A pointer to the compression options - can be NULL.
	// \param[in] pFeedbackProc A pointer to the feedback function - can be NULL.
	// \return    CMP_OK if successful, otherwise the error code.
	ConvertTexture :: proc(pSourceTexture: ^Texture, pDestTexture: ^Texture, pOptions: ^Compress_Options, pFeedbackProc: Feedback_Proc) -> Error ---

	// MIP MAP Interfaces
	CalcMaxMipLevel      :: proc(nHeight: Int, nWidth: Int, bForGPU: Bool) -> Int ---
	CalcMinMipSize       :: proc(nHeight: Int, nWidth: Int, MipsLevel: Int) -> Int ---
	GenerateMIPLevelsEx  :: proc(pMipSet: ^Mip_Set, pCFilterParams: ^CFilter_Parameters) -> Int ---
	GenerateMIPLevels    :: proc(pMipSet: ^Mip_Set, nMinSize: Int) -> Int ---
	CreateCompressMipSet :: proc(pMipSetCMP: ^Mip_Set, pMipSetSRC: ^Mip_Set) -> Error ---
	CreateMipSet         :: proc(pMipSet: ^Mip_Set, nWidth: Int, nHeight: Int, nDepth: Int, channelFormat: Channel_Format, textureType: Texture_Type) -> Error ---

	// MIP Map Quality
	getFormat_nChannels :: proc(format: Format) -> UInt ---
	MipSetAnlaysis      :: proc(src1: ^Mip_Set, src2: ^Mip_Set, nMipLevel: Int, nFaceOrSlice: Int, pAnalysisData: ^Analysis_Data) -> Error ---

	// Converts the source texture to the destination texture using MipSets with MIP MAP Levels
	ConvertMipTexture :: proc(p_MipSetIn: ^Mip_Set, p_MipSetOut: ^Mip_Set, pOptions: ^Compress_Options, pFeedbackProc: Feedback_Proc) -> Error ---

	//--------------------------------------------
	// CMP_Framework Lib: Texture Encoder Interfaces
	//--------------------------------------------
	LoadTexture         :: proc(sourceFile: cstring, pMipSet: ^Mip_Set) -> Error ---
	SaveTexture         :: proc(destFile: cstring, pMipSet: ^Mip_Set) -> Error ---
	ProcessTexture      :: proc(srcMipSet: ^Mip_Set, dstMipSet: ^Mip_Set, kernelOptions: Kernel_Options, pFeedbackProc: Feedback_Proc) -> Error ---
	CompressTexture     :: proc(options: ^Kernel_Options, srcMipSet: Mip_Set, dstMipSet: Mip_Set, pFeedback: Feedback_Proc) -> Error ---
	Format2FourCC       :: proc(format: Format, pMipSet: ^Mip_Set) ---
	ParseFormat         :: proc(pFormat: cstring) -> Format ---
	NumberOfProcessors  :: proc() -> Int ---
	FreeMipSet          :: proc(MipSetIn: ^Mip_Set) ---
	GetMipLevel         :: proc(data: ^^Mip_Level, pMipSet: ^Mip_Set, nMipLevel: Int, nFaceOrSlice: Int) ---
	GetPerformanceStats :: proc(pPerfStats: ^Kernel_Performance_Stats) -> Error ---
	GetDeviceInfo       :: proc(pDeviceInfo: ^Kernel_Device_Info) -> Error ---
	IsCompressedFormat  :: proc(format: Format) -> Bool ---
	IsFloatFormat       :: proc(InFormat: Format) -> Bool ---

	//--------------------------------------------
	// CMP_Framework Lib: Host level interface
	//--------------------------------------------
	CreateComputeLibrary  :: proc(srcTexture: ^Mip_Set, kernelOptions: ^Kernel_Options, Reserved: rawptr) -> Error ---
	DestroyComputeLibrary :: proc(forceClose: Bool) -> Error ---
	SetComputeOptions     :: proc(options: ^Compute_Options) -> Error ---

	//---------------------------------------------------------
	// CMP_Framework Lib: Generic API to access the core using CMP_EncoderSetting
	//----------------------------------------------------------
	CreateBlockEncoder  :: proc(blockEncoder: ^rawptr, encodeSettings: Encoder_Setting) -> Error ---
	CompressBlock       :: proc(blockEncoder: ^rawptr, srcBlock: rawptr, sourceStride: c.uint, dstBlock: rawptr, dstStride: c.uint) -> Error ---
	CompressBlockXY     :: proc(blockEncoder: ^rawptr, blockx: c.uint, blocky: c.uint, imgSrc: rawptr, sourceStride: c.uint, cmpDst: rawptr, dstStride: c.uint) -> Error ---
	DestroyBlockEncoder :: proc(blockEncoder: ^rawptr) ---

	//-----------------------------------
	// CMP_Framework Lib: Host interface
	//-----------------------------------
	InitFramework :: proc() ---
}
