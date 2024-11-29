package callisto_gpu

import "base:runtime"
import "core:path/filepath"
import "core:os/os2"
import "core:strings"
import "core:log"
import vk "vendor:vulkan"
import "../config"

// when RHI == "vulkan"

check_result :: proc(vkres: vk.Result) -> Result {
        if vkres == .SUCCESS {
                return .Ok
        }

        #partial switch vkres {
        case .ERROR_OUT_OF_HOST_MEMORY: return .Allocation_Error_CPU
        case .ERROR_OUT_OF_DEVICE_MEMORY: return .Allocation_Error_GPU
        case .ERROR_MEMORY_MAP_FAILED: return .Memory_Map_Failed
        }

        log.error("RHI Error:", vkres)
        return .Unknown_RHI_Error

}

_vk_prepend_layer_path :: proc() -> (ok: bool) {
        when ODIN_OS == .Windows {
                SEP :: ";"
        } else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
                SEP :: ":"
        }
        
        existing := os2.get_env("VK_INSTANCE_LAYERS", context.temp_allocator)

        exe_dir := config.get_exe_directory(context.temp_allocator)
        ours := filepath.join({exe_dir, config.SHIPPING_LIBS_PATH}, context.temp_allocator)

        if existing != "" {
                err: runtime.Allocator_Error
                ours, err = strings.join({ours, existing}, SEP)
                if err != nil {
                        return false
                }
        }

        return os2.set_env("VK_INSTANCE_LAYERS", ours)
}


VK_VTables :: struct {
        using vtable_instance : VK_Instance_VTable,
        using vtable_device   : vk.Device_VTable,
}

VK_Instance_VTable :: struct {
        AcquireDrmDisplayEXT                                            : vk.ProcAcquireDrmDisplayEXT,
        AcquireWinrtDisplayNV                                           : vk.ProcAcquireWinrtDisplayNV,
        CreateDebugReportCallbackEXT                                    : vk.ProcCreateDebugReportCallbackEXT,
        CreateDebugUtilsMessengerEXT                                    : vk.ProcCreateDebugUtilsMessengerEXT,
        CreateDevice                                                    : vk.ProcCreateDevice,
        CreateDisplayModeKHR                                            : vk.ProcCreateDisplayModeKHR,
        CreateDisplayPlaneSurfaceKHR                                    : vk.ProcCreateDisplayPlaneSurfaceKHR,
        CreateHeadlessSurfaceEXT                                        : vk.ProcCreateHeadlessSurfaceEXT,
        CreateIOSSurfaceMVK                                             : vk.ProcCreateIOSSurfaceMVK,
        CreateMacOSSurfaceMVK                                           : vk.ProcCreateMacOSSurfaceMVK,
        CreateMetalSurfaceEXT                                           : vk.ProcCreateMetalSurfaceEXT,
        CreateWaylandSurfaceKHR                                         : vk.ProcCreateWaylandSurfaceKHR,
        CreateWin32SurfaceKHR                                           : vk.ProcCreateWin32SurfaceKHR,
        DebugReportMessageEXT                                           : vk.ProcDebugReportMessageEXT,
        DestroyDebugReportCallbackEXT                                   : vk.ProcDestroyDebugReportCallbackEXT,
        DestroyDebugUtilsMessengerEXT                                   : vk.ProcDestroyDebugUtilsMessengerEXT,
        DestroyInstance                                                 : vk.ProcDestroyInstance,
        DestroySurfaceKHR                                               : vk.ProcDestroySurfaceKHR,
        EnumerateDeviceExtensionProperties                              : vk.ProcEnumerateDeviceExtensionProperties,
        EnumerateDeviceLayerProperties                                  : vk.ProcEnumerateDeviceLayerProperties,
        EnumeratePhysicalDeviceGroups                                   : vk.ProcEnumeratePhysicalDeviceGroups,
        EnumeratePhysicalDeviceGroupsKHR                                : vk.ProcEnumeratePhysicalDeviceGroupsKHR,
        EnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR   : vk.ProcEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR,
        EnumeratePhysicalDevices                                        : vk.ProcEnumeratePhysicalDevices,
        GetDisplayModeProperties2KHR                                    : vk.ProcGetDisplayModeProperties2KHR,
        GetDisplayModePropertiesKHR                                     : vk.ProcGetDisplayModePropertiesKHR,
        GetDisplayPlaneCapabilities2KHR                                 : vk.ProcGetDisplayPlaneCapabilities2KHR,
        GetDisplayPlaneCapabilitiesKHR                                  : vk.ProcGetDisplayPlaneCapabilitiesKHR,
        GetDisplayPlaneSupportedDisplaysKHR                             : vk.ProcGetDisplayPlaneSupportedDisplaysKHR,
        GetDrmDisplayEXT                                                : vk.ProcGetDrmDisplayEXT,
        GetInstanceProcAddrLUNARG                                       : vk.ProcGetInstanceProcAddrLUNARG,
        GetPhysicalDeviceCalibrateableTimeDomainsEXT                    : vk.ProcGetPhysicalDeviceCalibrateableTimeDomainsEXT,
        GetPhysicalDeviceCalibrateableTimeDomainsKHR                    : vk.ProcGetPhysicalDeviceCalibrateableTimeDomainsKHR,
        GetPhysicalDeviceCooperativeMatrixPropertiesKHR                 : vk.ProcGetPhysicalDeviceCooperativeMatrixPropertiesKHR,
        GetPhysicalDeviceCooperativeMatrixPropertiesNV                  : vk.ProcGetPhysicalDeviceCooperativeMatrixPropertiesNV,
        GetPhysicalDeviceDisplayPlaneProperties2KHR                     : vk.ProcGetPhysicalDeviceDisplayPlaneProperties2KHR,
        GetPhysicalDeviceDisplayPlanePropertiesKHR                      : vk.ProcGetPhysicalDeviceDisplayPlanePropertiesKHR,
        GetPhysicalDeviceDisplayProperties2KHR                          : vk.ProcGetPhysicalDeviceDisplayProperties2KHR,
        GetPhysicalDeviceDisplayPropertiesKHR                           : vk.ProcGetPhysicalDeviceDisplayPropertiesKHR,
        GetPhysicalDeviceExternalBufferProperties                       : vk.ProcGetPhysicalDeviceExternalBufferProperties,
        GetPhysicalDeviceExternalBufferPropertiesKHR                    : vk.ProcGetPhysicalDeviceExternalBufferPropertiesKHR,
        GetPhysicalDeviceExternalFenceProperties                        : vk.ProcGetPhysicalDeviceExternalFenceProperties,
        GetPhysicalDeviceExternalFencePropertiesKHR                     : vk.ProcGetPhysicalDeviceExternalFencePropertiesKHR,
        GetPhysicalDeviceExternalImageFormatPropertiesNV                : vk.ProcGetPhysicalDeviceExternalImageFormatPropertiesNV,
        GetPhysicalDeviceExternalSemaphoreProperties                    : vk.ProcGetPhysicalDeviceExternalSemaphoreProperties,
        GetPhysicalDeviceExternalSemaphorePropertiesKHR                 : vk.ProcGetPhysicalDeviceExternalSemaphorePropertiesKHR,
        GetPhysicalDeviceFeatures                                       : vk.ProcGetPhysicalDeviceFeatures,
        GetPhysicalDeviceFeatures2                                      : vk.ProcGetPhysicalDeviceFeatures2,
        GetPhysicalDeviceFeatures2KHR                                   : vk.ProcGetPhysicalDeviceFeatures2KHR,
        GetPhysicalDeviceFormatProperties                               : vk.ProcGetPhysicalDeviceFormatProperties,
        GetPhysicalDeviceFormatProperties2                              : vk.ProcGetPhysicalDeviceFormatProperties2,
        GetPhysicalDeviceFormatProperties2KHR                           : vk.ProcGetPhysicalDeviceFormatProperties2KHR,
        GetPhysicalDeviceFragmentShadingRatesKHR                        : vk.ProcGetPhysicalDeviceFragmentShadingRatesKHR,
        GetPhysicalDeviceImageFormatProperties                          : vk.ProcGetPhysicalDeviceImageFormatProperties,
        GetPhysicalDeviceImageFormatProperties2                         : vk.ProcGetPhysicalDeviceImageFormatProperties2,
        GetPhysicalDeviceImageFormatProperties2KHR                      : vk.ProcGetPhysicalDeviceImageFormatProperties2KHR,
        GetPhysicalDeviceMemoryProperties                               : vk.ProcGetPhysicalDeviceMemoryProperties,
        GetPhysicalDeviceMemoryProperties2                              : vk.ProcGetPhysicalDeviceMemoryProperties2,
        GetPhysicalDeviceMemoryProperties2KHR                           : vk.ProcGetPhysicalDeviceMemoryProperties2KHR,
        GetPhysicalDeviceMultisamplePropertiesEXT                       : vk.ProcGetPhysicalDeviceMultisamplePropertiesEXT,
        GetPhysicalDeviceOpticalFlowImageFormatsNV                      : vk.ProcGetPhysicalDeviceOpticalFlowImageFormatsNV,
        GetPhysicalDevicePresentRectanglesKHR                           : vk.ProcGetPhysicalDevicePresentRectanglesKHR,
        GetPhysicalDeviceProperties                                     : vk.ProcGetPhysicalDeviceProperties,
        GetPhysicalDeviceProperties2                                    : vk.ProcGetPhysicalDeviceProperties2,
        GetPhysicalDeviceProperties2KHR                                 : vk.ProcGetPhysicalDeviceProperties2KHR,
        GetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR           : vk.ProcGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR,
        GetPhysicalDeviceQueueFamilyProperties                          : vk.ProcGetPhysicalDeviceQueueFamilyProperties,
        GetPhysicalDeviceQueueFamilyProperties2                         : vk.ProcGetPhysicalDeviceQueueFamilyProperties2,
        GetPhysicalDeviceQueueFamilyProperties2KHR                      : vk.ProcGetPhysicalDeviceQueueFamilyProperties2KHR,
        GetPhysicalDeviceSparseImageFormatProperties                    : vk.ProcGetPhysicalDeviceSparseImageFormatProperties,
        GetPhysicalDeviceSparseImageFormatProperties2                   : vk.ProcGetPhysicalDeviceSparseImageFormatProperties2,
        GetPhysicalDeviceSparseImageFormatProperties2KHR                : vk.ProcGetPhysicalDeviceSparseImageFormatProperties2KHR,
        GetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV : vk.ProcGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV,
        GetPhysicalDeviceSurfaceCapabilities2EXT                        : vk.ProcGetPhysicalDeviceSurfaceCapabilities2EXT,
        GetPhysicalDeviceSurfaceCapabilities2KHR                        : vk.ProcGetPhysicalDeviceSurfaceCapabilities2KHR,
        GetPhysicalDeviceSurfaceCapabilitiesKHR                         : vk.ProcGetPhysicalDeviceSurfaceCapabilitiesKHR,
        GetPhysicalDeviceSurfaceFormats2KHR                             : vk.ProcGetPhysicalDeviceSurfaceFormats2KHR,
        GetPhysicalDeviceSurfaceFormatsKHR                              : vk.ProcGetPhysicalDeviceSurfaceFormatsKHR,
        GetPhysicalDeviceSurfacePresentModes2EXT                        : vk.ProcGetPhysicalDeviceSurfacePresentModes2EXT,
        GetPhysicalDeviceSurfacePresentModesKHR                         : vk.ProcGetPhysicalDeviceSurfacePresentModesKHR,
        GetPhysicalDeviceSurfaceSupportKHR                              : vk.ProcGetPhysicalDeviceSurfaceSupportKHR,
        GetPhysicalDeviceToolProperties                                 : vk.ProcGetPhysicalDeviceToolProperties,
        GetPhysicalDeviceToolPropertiesEXT                              : vk.ProcGetPhysicalDeviceToolPropertiesEXT,
        GetPhysicalDeviceVideoCapabilitiesKHR                           : vk.ProcGetPhysicalDeviceVideoCapabilitiesKHR,
        GetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR           : vk.ProcGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR,
        GetPhysicalDeviceVideoFormatPropertiesKHR                       : vk.ProcGetPhysicalDeviceVideoFormatPropertiesKHR,
        GetPhysicalDeviceWaylandPresentationSupportKHR                  : vk.ProcGetPhysicalDeviceWaylandPresentationSupportKHR,
        GetPhysicalDeviceWin32PresentationSupportKHR                    : vk.ProcGetPhysicalDeviceWin32PresentationSupportKHR,
        GetWinrtDisplayNV                                               : vk.ProcGetWinrtDisplayNV,
        ReleaseDisplayEXT                                               : vk.ProcReleaseDisplayEXT,
        SubmitDebugUtilsMessageEXT                                      : vk.ProcSubmitDebugUtilsMessageEXT,
}

_vk_load_proc_addresses_instance_vtable :: proc(instance: vk.Instance, vtable: ^VK_Instance_VTable) {
	vtable.AcquireDrmDisplayEXT                                            = auto_cast vk.GetInstanceProcAddr(instance, "vkAcquireDrmDisplayEXT")
	vtable.AcquireWinrtDisplayNV                                           = auto_cast vk.GetInstanceProcAddr(instance, "vkAcquireWinrtDisplayNV")
	vtable.CreateDebugReportCallbackEXT                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT")
	vtable.CreateDebugUtilsMessengerEXT                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT")
	vtable.CreateDevice                                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateDevice")
	vtable.CreateDisplayModeKHR                                            = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateDisplayModeKHR")
	vtable.CreateDisplayPlaneSurfaceKHR                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateDisplayPlaneSurfaceKHR")
	vtable.CreateHeadlessSurfaceEXT                                        = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateHeadlessSurfaceEXT")
	vtable.CreateIOSSurfaceMVK                                             = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateIOSSurfaceMVK")
	vtable.CreateMacOSSurfaceMVK                                           = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateMacOSSurfaceMVK")
	vtable.CreateMetalSurfaceEXT                                           = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateMetalSurfaceEXT")
	vtable.CreateWaylandSurfaceKHR                                         = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateWaylandSurfaceKHR")
	vtable.CreateWin32SurfaceKHR                                           = auto_cast vk.GetInstanceProcAddr(instance, "vkCreateWin32SurfaceKHR")
	vtable.DebugReportMessageEXT                                           = auto_cast vk.GetInstanceProcAddr(instance, "vkDebugReportMessageEXT")
	vtable.DestroyDebugReportCallbackEXT                                   = auto_cast vk.GetInstanceProcAddr(instance, "vkDestroyDebugReportCallbackEXT")
	vtable.DestroyDebugUtilsMessengerEXT                                   = auto_cast vk.GetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT")
	vtable.DestroyInstance                                                 = auto_cast vk.GetInstanceProcAddr(instance, "vkDestroyInstance")
	vtable.DestroySurfaceKHR                                               = auto_cast vk.GetInstanceProcAddr(instance, "vkDestroySurfaceKHR")
	vtable.EnumerateDeviceExtensionProperties                              = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumerateDeviceExtensionProperties")
	vtable.EnumerateDeviceLayerProperties                                  = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumerateDeviceLayerProperties")
	vtable.EnumeratePhysicalDeviceGroups                                   = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceGroups")
	vtable.EnumeratePhysicalDeviceGroupsKHR                                = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceGroupsKHR")
	vtable.EnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR   = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR")
	vtable.EnumeratePhysicalDevices                                        = auto_cast vk.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDevices")
	vtable.GetDisplayModeProperties2KHR                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDisplayModeProperties2KHR")
	vtable.GetDisplayModePropertiesKHR                                     = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDisplayModePropertiesKHR")
	vtable.GetDisplayPlaneCapabilities2KHR                                 = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDisplayPlaneCapabilities2KHR")
	vtable.GetDisplayPlaneCapabilitiesKHR                                  = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDisplayPlaneCapabilitiesKHR")
	vtable.GetDisplayPlaneSupportedDisplaysKHR                             = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDisplayPlaneSupportedDisplaysKHR")
	vtable.GetDrmDisplayEXT                                                = auto_cast vk.GetInstanceProcAddr(instance, "vkGetDrmDisplayEXT")
	vtable.GetInstanceProcAddrLUNARG                                       = auto_cast vk.GetInstanceProcAddr(instance, "vkGetInstanceProcAddrLUNARG")
	vtable.GetPhysicalDeviceCalibrateableTimeDomainsEXT                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCalibrateableTimeDomainsEXT")
	vtable.GetPhysicalDeviceCalibrateableTimeDomainsKHR                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCalibrateableTimeDomainsKHR")
	vtable.GetPhysicalDeviceCooperativeMatrixPropertiesKHR                 = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCooperativeMatrixPropertiesKHR")
	vtable.GetPhysicalDeviceCooperativeMatrixPropertiesNV                  = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCooperativeMatrixPropertiesNV")
	vtable.GetPhysicalDeviceDisplayPlaneProperties2KHR                     = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPlaneProperties2KHR")
	vtable.GetPhysicalDeviceDisplayPlanePropertiesKHR                      = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPlanePropertiesKHR")
	vtable.GetPhysicalDeviceDisplayProperties2KHR                          = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayProperties2KHR")
	vtable.GetPhysicalDeviceDisplayPropertiesKHR                           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPropertiesKHR")
	vtable.GetPhysicalDeviceExternalBufferProperties                       = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalBufferProperties")
	vtable.GetPhysicalDeviceExternalBufferPropertiesKHR                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalBufferPropertiesKHR")
	vtable.GetPhysicalDeviceExternalFenceProperties                        = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalFenceProperties")
	vtable.GetPhysicalDeviceExternalFencePropertiesKHR                     = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalFencePropertiesKHR")
	vtable.GetPhysicalDeviceExternalImageFormatPropertiesNV                = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalImageFormatPropertiesNV")
	vtable.GetPhysicalDeviceExternalSemaphoreProperties                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalSemaphoreProperties")
	vtable.GetPhysicalDeviceExternalSemaphorePropertiesKHR                 = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalSemaphorePropertiesKHR")
	vtable.GetPhysicalDeviceFeatures                                       = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures")
	vtable.GetPhysicalDeviceFeatures2                                      = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures2")
	vtable.GetPhysicalDeviceFeatures2KHR                                   = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures2KHR")
	vtable.GetPhysicalDeviceFormatProperties                               = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties")
	vtable.GetPhysicalDeviceFormatProperties2                              = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties2")
	vtable.GetPhysicalDeviceFormatProperties2KHR                           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties2KHR")
	vtable.GetPhysicalDeviceFragmentShadingRatesKHR                        = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFragmentShadingRatesKHR")
	vtable.GetPhysicalDeviceImageFormatProperties                          = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties")
	vtable.GetPhysicalDeviceImageFormatProperties2                         = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties2")
	vtable.GetPhysicalDeviceImageFormatProperties2KHR                      = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties2KHR")
	vtable.GetPhysicalDeviceMemoryProperties                               = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties")
	vtable.GetPhysicalDeviceMemoryProperties2                              = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties2")
	vtable.GetPhysicalDeviceMemoryProperties2KHR                           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties2KHR")
	vtable.GetPhysicalDeviceMultisamplePropertiesEXT                       = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMultisamplePropertiesEXT")
	vtable.GetPhysicalDeviceOpticalFlowImageFormatsNV                      = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceOpticalFlowImageFormatsNV")
	vtable.GetPhysicalDevicePresentRectanglesKHR                           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDevicePresentRectanglesKHR")
	vtable.GetPhysicalDeviceProperties                                     = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties")
	vtable.GetPhysicalDeviceProperties2                                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties2")
	vtable.GetPhysicalDeviceProperties2KHR                                 = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties2KHR")
	vtable.GetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR")
	vtable.GetPhysicalDeviceQueueFamilyProperties                          = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties")
	vtable.GetPhysicalDeviceQueueFamilyProperties2                         = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties2")
	vtable.GetPhysicalDeviceQueueFamilyProperties2KHR                      = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties2KHR")
	vtable.GetPhysicalDeviceSparseImageFormatProperties                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties")
	vtable.GetPhysicalDeviceSparseImageFormatProperties2                   = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties2")
	vtable.GetPhysicalDeviceSparseImageFormatProperties2KHR                = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties2KHR")
	vtable.GetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV")
	vtable.GetPhysicalDeviceSurfaceCapabilities2EXT                        = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilities2EXT")
	vtable.GetPhysicalDeviceSurfaceCapabilities2KHR                        = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilities2KHR")
	vtable.GetPhysicalDeviceSurfaceCapabilitiesKHR                         = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
	vtable.GetPhysicalDeviceSurfaceFormats2KHR                             = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceFormats2KHR")
	vtable.GetPhysicalDeviceSurfaceFormatsKHR                              = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceFormatsKHR")
	vtable.GetPhysicalDeviceSurfacePresentModes2EXT                        = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfacePresentModes2EXT")
	vtable.GetPhysicalDeviceSurfacePresentModesKHR                         = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfacePresentModesKHR")
	vtable.GetPhysicalDeviceSurfaceSupportKHR                              = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceSupportKHR")
	vtable.GetPhysicalDeviceToolProperties                                 = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceToolProperties")
	vtable.GetPhysicalDeviceToolPropertiesEXT                              = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceToolPropertiesEXT")
	vtable.GetPhysicalDeviceVideoCapabilitiesKHR                           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoCapabilitiesKHR")
	vtable.GetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR           = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR")
	vtable.GetPhysicalDeviceVideoFormatPropertiesKHR                       = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoFormatPropertiesKHR")
	vtable.GetPhysicalDeviceWaylandPresentationSupportKHR                  = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceWaylandPresentationSupportKHR")
	vtable.GetPhysicalDeviceWin32PresentationSupportKHR                    = auto_cast vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceWin32PresentationSupportKHR")
	vtable.GetWinrtDisplayNV                                               = auto_cast vk.GetInstanceProcAddr(instance, "vkGetWinrtDisplayNV")
	vtable.ReleaseDisplayEXT                                               = auto_cast vk.GetInstanceProcAddr(instance, "vkReleaseDisplayEXT")
	vtable.SubmitDebugUtilsMessageEXT                                      = auto_cast vk.GetInstanceProcAddr(instance, "vkSubmitDebugUtilsMessageEXT")
}
