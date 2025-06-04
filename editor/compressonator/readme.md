# Odin-Compressonator

Odin-lang bindings for [GPUOpen-Tools/Compressonator](https://github.com/GPUOpen-Tools/Compressonator).
Made using [karl-zylinski/odin-c-bindgen](https://github.com/karl-zylinski/odin-c-bindgen).

Currently only supports Windows targets. See [notes](notes.md) if you would like to add Linux support.

The source header has been slightly modified to be valid C code and fix parsing errors.

## Using these bindings

Copy this repository into your project and import it. 
- [Documentation](https://compressonator.readthedocs.io/en/latest/developer_sdk/index.html)
- [C++ Examples](https://github.com/GPUOpen-Tools/compressonator/tree/master/examples)

```odin
package example
import cmp "odin-compressonator"

main :: proc() {
    cmp.InitFramework()

    mip_set_in: cmp.Mip_Set
    err := cmp.LoadTexture("my_texture.png", &mip_set_in)
    if err != .OK {
        panic("Failed to load texture")
    }

    // Do some processing on the mip set. See linked examples above.

    cmp.FreeMipSet(&mip_set_in)
}
```


## Building Compressonator from source

I wasn't able to get the library to build using the provided scripts, however the VS2019 solution does work.

### Install dependencies

- CMake 3.15 or above
- Vulkan SDK (latest)
- Python 3.6 or above
- Qt 5.12.6 (MSVC x64 + plugins)
- OpenCV 4.2.0
- Visual Studio 2019 + the following individual components
    - Windows 10 SDK version 10.0.19041 or later
    - C++/CLI support for v132 build tools (Latest)
    - MSVC v142 - VS 2019 C++ x64/x86 build tools (Latest)
    - C++ ATL for latest v142 build tools (x86 & x64)

### Build solution

1. Clone Compressonator: `git clone --recursive https://github.com/GPUOpen-Tools/compressonator.git`
1. CD to `Compressonator/build`
2. Run `python fetch_dependencies.py`
3. Open `Compressonator/build_sdk/cmp_compressonatorlib.sln` in VS2019
4. Set the build configuration to "Release" and platform to "x64"
5. Build the solution. Output lib is in `Compressonator/build/Release/x64/`
6. Copy the lib to `odin-compressonator/lib/`

## Regenerating the Odin bindings

Note that the source header file has been modified. The original is in `Compressonator/cmp_compressonatorlib/compressonator.h`.

1. Build odin-c-bindgen
2. From this package's directory (odin-compressonator), call `bindgen include`

### Modifying the original header file

Note: this is not a real diff, but an informative guide to what has been changed from the original.

```diff
C++ vectors:
- #include <vector>
- typedef std::vector<uint8_t> CMP_VEC8;
+ // Layout of std::vector<uint8_t>
+ typedef struct {
+     uint8_t* first;
+     uint8_t* last;
+     uint8_t* end;
+ } CMP_VEC8;

Namespaces:
- namespace CMP {}              // + everything inside
- typedef CMP::DWORD CMP_DWORD; // and following lines. 
+ typedef uint32_t CMP_DWORD;   // Use the types from the namespace, except for CMP_LONG. Use the existing one instead.

Invalid C code:
- typedef void CMP_VOID;
+ #define CMP_VOID void

Missing bool type:
+ #include <stdbool.h>

Un-typedef'd structs:
- struct ComputeOptions {
- };
+ typedef struct {
+ } CMP_ComputeOptions; // Add CMP_ prefix
// Repeat for KernelPerformanceStats, KernelDeviceInfo, KernelOptions

Type changes in CMP_KernelOptions and CMP_CompressOptions:
- KernelPerformanceStats perfStats;
+ CMP_KernelPerformanceStats perfStats;
- KernelDeviceInfo deviceInfo;
+ CMP_KernelDeviceInfo deviceInfo;

Prefixless typedef aliases:
- typedef CMP_ChannelFormat ChannelFormat; // This results in invalid Odin code (Channel_Format :: Channel_Format)
- typedef CMP_TextureDataType TextureDataType;
- typedef CMP_TextureType TextureType;
- typedef CMP_MipLevel MipLevel;
- typedef CMP_MipSet MipSet;

Type changes in CMP_MipSet:
- ChannelFormat m_ChannelFormat;
+ CMP_ChannelFormat m_ChannelFormat;
- TextureDataType m_TextureDataType;
+ CMP_TextureDataType m_TextureDataType;
- TextureType m_TextureType;
+ CMP_TextureType m_TextureType;

Fix issues related to defines:
- #define BC_BLOCK_BYTES (4 * 4)
+ #define BC_BLOCK_BYTES 16
- #define BC_BLOCK_PIXELS BC_BLOCK_BYTES
+ #define BC_BLOCK_PIXELS 16

C++ opaque classes:
- class BC7BlockEncoder
+ typedef struct{} BC7BlockEncoder
- class BC6HBlockEncoder
+ typedef struct{} BC6HBlockEncoder

Function parameter type changes:
// Add "CMP_" prefix to the specified parameter's type
~ CMP_CreateMipSet(): channelFormat, textureType
~ CMP_ProcessTexture(): kernelOptions
~ CMP_CompressTexture(): options
~ CMP_GetPerformanceStats(): pPerfStats
~ CMP_GetDeviceInfo(): pDeviceInfo
~ CMP_CreateComputeLibrary(): kernelOptions
~ CMP_SetComputeOptions(): options
```

