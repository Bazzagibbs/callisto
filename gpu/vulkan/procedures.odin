//
// Vulkan wrapper generated from "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/master/include/vulkan/vulkan_core.h"
//
package callisto_vulkan

import "core:c"

// Loader Procedure Types
ProcCreateInstance                       :: #type proc "system" (pCreateInfo: ^InstanceCreateInfo, pAllocator: ^AllocationCallbacks, pInstance: ^Instance) -> Result
ProcDebugUtilsMessengerCallbackEXT       :: #type proc "system" (messageSeverity: DebugUtilsMessageSeverityFlagsEXT, messageTypes: DebugUtilsMessageTypeFlagsEXT, pCallbackData: ^DebugUtilsMessengerCallbackDataEXT, pUserData: rawptr) -> b32
ProcDeviceMemoryReportCallbackEXT        :: #type proc "system" (pCallbackData: ^DeviceMemoryReportCallbackDataEXT, pUserData: rawptr)
ProcEnumerateInstanceExtensionProperties :: #type proc "system" (pLayerName: cstring, pPropertyCount: ^u32, pProperties: [^]ExtensionProperties) -> Result
ProcEnumerateInstanceLayerProperties     :: #type proc "system" (pPropertyCount: ^u32, pProperties: [^]LayerProperties) -> Result
ProcEnumerateInstanceVersion             :: #type proc "system" (pApiVersion: ^u32) -> Result

// Misc Procedure Types
ProcAllocationFunction             :: #type proc "system" (pUserData: rawptr, size: int, alignment: int, allocationScope: SystemAllocationScope) -> rawptr
ProcDebugReportCallbackEXT         :: #type proc "system" (flags: DebugReportFlagsEXT, objectType: DebugReportObjectTypeEXT, object: u64, location: int, messageCode: i32, pLayerPrefix: cstring, pMessage: cstring, pUserData: rawptr) -> b32
ProcFreeFunction                   :: #type proc "system" (pUserData: rawptr, pMemory: rawptr)
ProcInternalAllocationNotification :: #type proc "system" (pUserData: rawptr, size: int, allocationType: InternalAllocationType, allocationScope: SystemAllocationScope)
ProcInternalFreeNotification       :: #type proc "system" (pUserData: rawptr, size: int, allocationType: InternalAllocationType, allocationScope: SystemAllocationScope)
ProcReallocationFunction           :: #type proc "system" (pUserData: rawptr, pOriginal: rawptr, size: int, alignment: int, allocationScope: SystemAllocationScope) -> rawptr
ProcVoidFunction                   :: #type proc "system" ()

// Instance Procedure Types
ProcAcquireDrmDisplayEXT                                            :: #type proc "system" (physicalDevice: PhysicalDevice, drmFd: i32, display: DisplayKHR) -> Result
ProcAcquireWinrtDisplayNV                                           :: #type proc "system" (physicalDevice: PhysicalDevice, display: DisplayKHR) -> Result
ProcCreateDebugReportCallbackEXT                                    :: #type proc "system" (instance: Instance, pCreateInfo: ^DebugReportCallbackCreateInfoEXT, pAllocator: ^AllocationCallbacks, pCallback: ^DebugReportCallbackEXT) -> Result
ProcCreateDebugUtilsMessengerEXT                                    :: #type proc "system" (instance: Instance, pCreateInfo: ^DebugUtilsMessengerCreateInfoEXT, pAllocator: ^AllocationCallbacks, pMessenger: ^DebugUtilsMessengerEXT) -> Result
ProcCreateDevice                                                    :: #type proc "system" (physicalDevice: PhysicalDevice, pCreateInfo: ^DeviceCreateInfo, pAllocator: ^AllocationCallbacks, pDevice: ^Device) -> Result
ProcCreateDisplayModeKHR                                            :: #type proc "system" (physicalDevice: PhysicalDevice, display: DisplayKHR, pCreateInfo: ^DisplayModeCreateInfoKHR, pAllocator: ^AllocationCallbacks, pMode: ^DisplayModeKHR) -> Result
ProcCreateDisplayPlaneSurfaceKHR                                    :: #type proc "system" (instance: Instance, pCreateInfo: ^DisplaySurfaceCreateInfoKHR, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateHeadlessSurfaceEXT                                        :: #type proc "system" (instance: Instance, pCreateInfo: ^HeadlessSurfaceCreateInfoEXT, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateIOSSurfaceMVK                                             :: #type proc "system" (instance: Instance, pCreateInfo: ^IOSSurfaceCreateInfoMVK, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateMacOSSurfaceMVK                                           :: #type proc "system" (instance: Instance, pCreateInfo: ^MacOSSurfaceCreateInfoMVK, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateMetalSurfaceEXT                                           :: #type proc "system" (instance: Instance, pCreateInfo: ^MetalSurfaceCreateInfoEXT, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateWaylandSurfaceKHR                                         :: #type proc "system" (instance: Instance, pCreateInfo: ^WaylandSurfaceCreateInfoKHR, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcCreateWin32SurfaceKHR                                           :: #type proc "system" (instance: Instance, pCreateInfo: ^Win32SurfaceCreateInfoKHR, pAllocator: ^AllocationCallbacks, pSurface: ^SurfaceKHR) -> Result
ProcDebugReportMessageEXT                                           :: #type proc "system" (instance: Instance, flags: DebugReportFlagsEXT, objectType: DebugReportObjectTypeEXT, object: u64, location: int, messageCode: i32, pLayerPrefix: cstring, pMessage: cstring)
ProcDestroyDebugReportCallbackEXT                                   :: #type proc "system" (instance: Instance, callback: DebugReportCallbackEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyDebugUtilsMessengerEXT                                   :: #type proc "system" (instance: Instance, messenger: DebugUtilsMessengerEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyInstance                                                 :: #type proc "system" (instance: Instance, pAllocator: ^AllocationCallbacks)
ProcDestroySurfaceKHR                                               :: #type proc "system" (instance: Instance, surface: SurfaceKHR, pAllocator: ^AllocationCallbacks)
ProcEnumerateDeviceExtensionProperties                              :: #type proc "system" (physicalDevice: PhysicalDevice, pLayerName: cstring, pPropertyCount: ^u32, pProperties: [^]ExtensionProperties) -> Result
ProcEnumerateDeviceLayerProperties                                  :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]LayerProperties) -> Result
ProcEnumeratePhysicalDeviceGroups                                   :: #type proc "system" (instance: Instance, pPhysicalDeviceGroupCount: ^u32, pPhysicalDeviceGroupProperties: [^]PhysicalDeviceGroupProperties) -> Result
ProcEnumeratePhysicalDeviceGroupsKHR                                :: #type proc "system" (instance: Instance, pPhysicalDeviceGroupCount: ^u32, pPhysicalDeviceGroupProperties: [^]PhysicalDeviceGroupProperties) -> Result
ProcEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR   :: #type proc "system" (physicalDevice: PhysicalDevice, queueFamilyIndex: u32, pCounterCount: ^u32, pCounters: [^]PerformanceCounterKHR, pCounterDescriptions: [^]PerformanceCounterDescriptionKHR) -> Result
ProcEnumeratePhysicalDevices                                        :: #type proc "system" (instance: Instance, pPhysicalDeviceCount: ^u32, pPhysicalDevices: [^]PhysicalDevice) -> Result
ProcGetDisplayModeProperties2KHR                                    :: #type proc "system" (physicalDevice: PhysicalDevice, display: DisplayKHR, pPropertyCount: ^u32, pProperties: [^]DisplayModeProperties2KHR) -> Result
ProcGetDisplayModePropertiesKHR                                     :: #type proc "system" (physicalDevice: PhysicalDevice, display: DisplayKHR, pPropertyCount: ^u32, pProperties: [^]DisplayModePropertiesKHR) -> Result
ProcGetDisplayPlaneCapabilities2KHR                                 :: #type proc "system" (physicalDevice: PhysicalDevice, pDisplayPlaneInfo: ^DisplayPlaneInfo2KHR, pCapabilities: [^]DisplayPlaneCapabilities2KHR) -> Result
ProcGetDisplayPlaneCapabilitiesKHR                                  :: #type proc "system" (physicalDevice: PhysicalDevice, mode: DisplayModeKHR, planeIndex: u32, pCapabilities: [^]DisplayPlaneCapabilitiesKHR) -> Result
ProcGetDisplayPlaneSupportedDisplaysKHR                             :: #type proc "system" (physicalDevice: PhysicalDevice, planeIndex: u32, pDisplayCount: ^u32, pDisplays: [^]DisplayKHR) -> Result
ProcGetDrmDisplayEXT                                                :: #type proc "system" (physicalDevice: PhysicalDevice, drmFd: i32, connectorId: u32, display: ^DisplayKHR) -> Result
ProcGetInstanceProcAddr                                             :: #type proc "system" (instance: Instance, pName: cstring) -> ProcVoidFunction
ProcGetInstanceProcAddrLUNARG                                       :: #type proc "system" (instance: Instance, pName: cstring) -> ProcVoidFunction
ProcGetPhysicalDeviceCalibrateableTimeDomainsEXT                    :: #type proc "system" (physicalDevice: PhysicalDevice, pTimeDomainCount: ^u32, pTimeDomains: [^]TimeDomainKHR) -> Result
ProcGetPhysicalDeviceCalibrateableTimeDomainsKHR                    :: #type proc "system" (physicalDevice: PhysicalDevice, pTimeDomainCount: ^u32, pTimeDomains: [^]TimeDomainKHR) -> Result
ProcGetPhysicalDeviceCooperativeMatrixPropertiesKHR                 :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]CooperativeMatrixPropertiesKHR) -> Result
ProcGetPhysicalDeviceCooperativeMatrixPropertiesNV                  :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]CooperativeMatrixPropertiesNV) -> Result
ProcGetPhysicalDeviceDisplayPlaneProperties2KHR                     :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]DisplayPlaneProperties2KHR) -> Result
ProcGetPhysicalDeviceDisplayPlanePropertiesKHR                      :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]DisplayPlanePropertiesKHR) -> Result
ProcGetPhysicalDeviceDisplayProperties2KHR                          :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]DisplayProperties2KHR) -> Result
ProcGetPhysicalDeviceDisplayPropertiesKHR                           :: #type proc "system" (physicalDevice: PhysicalDevice, pPropertyCount: ^u32, pProperties: [^]DisplayPropertiesKHR) -> Result
ProcGetPhysicalDeviceExternalBufferProperties                       :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalBufferInfo: ^PhysicalDeviceExternalBufferInfo, pExternalBufferProperties: [^]ExternalBufferProperties)
ProcGetPhysicalDeviceExternalBufferPropertiesKHR                    :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalBufferInfo: ^PhysicalDeviceExternalBufferInfo, pExternalBufferProperties: [^]ExternalBufferProperties)
ProcGetPhysicalDeviceExternalFenceProperties                        :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalFenceInfo: ^PhysicalDeviceExternalFenceInfo, pExternalFenceProperties: [^]ExternalFenceProperties)
ProcGetPhysicalDeviceExternalFencePropertiesKHR                     :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalFenceInfo: ^PhysicalDeviceExternalFenceInfo, pExternalFenceProperties: [^]ExternalFenceProperties)
ProcGetPhysicalDeviceExternalImageFormatPropertiesNV                :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, type: ImageType, tiling: ImageTiling, usage: ImageUsageFlags, flags: ImageCreateFlags, externalHandleType: ExternalMemoryHandleTypeFlagsNV, pExternalImageFormatProperties: [^]ExternalImageFormatPropertiesNV) -> Result
ProcGetPhysicalDeviceExternalSemaphoreProperties                    :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalSemaphoreInfo: ^PhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: [^]ExternalSemaphoreProperties)
ProcGetPhysicalDeviceExternalSemaphorePropertiesKHR                 :: #type proc "system" (physicalDevice: PhysicalDevice, pExternalSemaphoreInfo: ^PhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: [^]ExternalSemaphoreProperties)
ProcGetPhysicalDeviceFeatures                                       :: #type proc "system" (physicalDevice: PhysicalDevice, pFeatures: [^]PhysicalDeviceFeatures)
ProcGetPhysicalDeviceFeatures2                                      :: #type proc "system" (physicalDevice: PhysicalDevice, pFeatures: [^]PhysicalDeviceFeatures2)
ProcGetPhysicalDeviceFeatures2KHR                                   :: #type proc "system" (physicalDevice: PhysicalDevice, pFeatures: [^]PhysicalDeviceFeatures2)
ProcGetPhysicalDeviceFormatProperties                               :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, pFormatProperties: [^]FormatProperties)
ProcGetPhysicalDeviceFormatProperties2                              :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, pFormatProperties: [^]FormatProperties2)
ProcGetPhysicalDeviceFormatProperties2KHR                           :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, pFormatProperties: [^]FormatProperties2)
ProcGetPhysicalDeviceFragmentShadingRatesKHR                        :: #type proc "system" (physicalDevice: PhysicalDevice, pFragmentShadingRateCount: ^u32, pFragmentShadingRates: [^]PhysicalDeviceFragmentShadingRateKHR) -> Result
ProcGetPhysicalDeviceImageFormatProperties                          :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, type: ImageType, tiling: ImageTiling, usage: ImageUsageFlags, flags: ImageCreateFlags, pImageFormatProperties: [^]ImageFormatProperties) -> Result
ProcGetPhysicalDeviceImageFormatProperties2                         :: #type proc "system" (physicalDevice: PhysicalDevice, pImageFormatInfo: ^PhysicalDeviceImageFormatInfo2, pImageFormatProperties: [^]ImageFormatProperties2) -> Result
ProcGetPhysicalDeviceImageFormatProperties2KHR                      :: #type proc "system" (physicalDevice: PhysicalDevice, pImageFormatInfo: ^PhysicalDeviceImageFormatInfo2, pImageFormatProperties: [^]ImageFormatProperties2) -> Result
ProcGetPhysicalDeviceMemoryProperties                               :: #type proc "system" (physicalDevice: PhysicalDevice, pMemoryProperties: [^]PhysicalDeviceMemoryProperties)
ProcGetPhysicalDeviceMemoryProperties2                              :: #type proc "system" (physicalDevice: PhysicalDevice, pMemoryProperties: [^]PhysicalDeviceMemoryProperties2)
ProcGetPhysicalDeviceMemoryProperties2KHR                           :: #type proc "system" (physicalDevice: PhysicalDevice, pMemoryProperties: [^]PhysicalDeviceMemoryProperties2)
ProcGetPhysicalDeviceMultisamplePropertiesEXT                       :: #type proc "system" (physicalDevice: PhysicalDevice, samples: SampleCountFlags, pMultisampleProperties: [^]MultisamplePropertiesEXT)
ProcGetPhysicalDeviceOpticalFlowImageFormatsNV                      :: #type proc "system" (physicalDevice: PhysicalDevice, pOpticalFlowImageFormatInfo: ^OpticalFlowImageFormatInfoNV, pFormatCount: ^u32, pImageFormatProperties: [^]OpticalFlowImageFormatPropertiesNV) -> Result
ProcGetPhysicalDevicePresentRectanglesKHR                           :: #type proc "system" (physicalDevice: PhysicalDevice, surface: SurfaceKHR, pRectCount: ^u32, pRects: [^]Rect2D) -> Result
ProcGetPhysicalDeviceProperties                                     :: #type proc "system" (physicalDevice: PhysicalDevice, pProperties: [^]PhysicalDeviceProperties)
ProcGetPhysicalDeviceProperties2                                    :: #type proc "system" (physicalDevice: PhysicalDevice, pProperties: [^]PhysicalDeviceProperties2)
ProcGetPhysicalDeviceProperties2KHR                                 :: #type proc "system" (physicalDevice: PhysicalDevice, pProperties: [^]PhysicalDeviceProperties2)
ProcGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR           :: #type proc "system" (physicalDevice: PhysicalDevice, pPerformanceQueryCreateInfo: ^QueryPoolPerformanceCreateInfoKHR, pNumPasses: [^]u32)
ProcGetPhysicalDeviceQueueFamilyProperties                          :: #type proc "system" (physicalDevice: PhysicalDevice, pQueueFamilyPropertyCount: ^u32, pQueueFamilyProperties: [^]QueueFamilyProperties)
ProcGetPhysicalDeviceQueueFamilyProperties2                         :: #type proc "system" (physicalDevice: PhysicalDevice, pQueueFamilyPropertyCount: ^u32, pQueueFamilyProperties: [^]QueueFamilyProperties2)
ProcGetPhysicalDeviceQueueFamilyProperties2KHR                      :: #type proc "system" (physicalDevice: PhysicalDevice, pQueueFamilyPropertyCount: ^u32, pQueueFamilyProperties: [^]QueueFamilyProperties2)
ProcGetPhysicalDeviceSparseImageFormatProperties                    :: #type proc "system" (physicalDevice: PhysicalDevice, format: Format, type: ImageType, samples: SampleCountFlags, usage: ImageUsageFlags, tiling: ImageTiling, pPropertyCount: ^u32, pProperties: [^]SparseImageFormatProperties)
ProcGetPhysicalDeviceSparseImageFormatProperties2                   :: #type proc "system" (physicalDevice: PhysicalDevice, pFormatInfo: ^PhysicalDeviceSparseImageFormatInfo2, pPropertyCount: ^u32, pProperties: [^]SparseImageFormatProperties2)
ProcGetPhysicalDeviceSparseImageFormatProperties2KHR                :: #type proc "system" (physicalDevice: PhysicalDevice, pFormatInfo: ^PhysicalDeviceSparseImageFormatInfo2, pPropertyCount: ^u32, pProperties: [^]SparseImageFormatProperties2)
ProcGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV :: #type proc "system" (physicalDevice: PhysicalDevice, pCombinationCount: ^u32, pCombinations: [^]FramebufferMixedSamplesCombinationNV) -> Result
ProcGetPhysicalDeviceSurfaceCapabilities2EXT                        :: #type proc "system" (physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceCapabilities: [^]SurfaceCapabilities2EXT) -> Result
ProcGetPhysicalDeviceSurfaceCapabilities2KHR                        :: #type proc "system" (physicalDevice: PhysicalDevice, pSurfaceInfo: ^PhysicalDeviceSurfaceInfo2KHR, pSurfaceCapabilities: [^]SurfaceCapabilities2KHR) -> Result
ProcGetPhysicalDeviceSurfaceCapabilitiesKHR                         :: #type proc "system" (physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceCapabilities: [^]SurfaceCapabilitiesKHR) -> Result
ProcGetPhysicalDeviceSurfaceFormats2KHR                             :: #type proc "system" (physicalDevice: PhysicalDevice, pSurfaceInfo: ^PhysicalDeviceSurfaceInfo2KHR, pSurfaceFormatCount: ^u32, pSurfaceFormats: [^]SurfaceFormat2KHR) -> Result
ProcGetPhysicalDeviceSurfaceFormatsKHR                              :: #type proc "system" (physicalDevice: PhysicalDevice, surface: SurfaceKHR, pSurfaceFormatCount: ^u32, pSurfaceFormats: [^]SurfaceFormatKHR) -> Result
ProcGetPhysicalDeviceSurfacePresentModes2EXT                        :: #type proc "system" (physicalDevice: PhysicalDevice, pSurfaceInfo: ^PhysicalDeviceSurfaceInfo2KHR, pPresentModeCount: ^u32, pPresentModes: [^]PresentModeKHR) -> Result
ProcGetPhysicalDeviceSurfacePresentModesKHR                         :: #type proc "system" (physicalDevice: PhysicalDevice, surface: SurfaceKHR, pPresentModeCount: ^u32, pPresentModes: [^]PresentModeKHR) -> Result
ProcGetPhysicalDeviceSurfaceSupportKHR                              :: #type proc "system" (physicalDevice: PhysicalDevice, queueFamilyIndex: u32, surface: SurfaceKHR, pSupported: ^b32) -> Result
ProcGetPhysicalDeviceToolProperties                                 :: #type proc "system" (physicalDevice: PhysicalDevice, pToolCount: ^u32, pToolProperties: [^]PhysicalDeviceToolProperties) -> Result
ProcGetPhysicalDeviceToolPropertiesEXT                              :: #type proc "system" (physicalDevice: PhysicalDevice, pToolCount: ^u32, pToolProperties: [^]PhysicalDeviceToolProperties) -> Result
ProcGetPhysicalDeviceVideoCapabilitiesKHR                           :: #type proc "system" (physicalDevice: PhysicalDevice, pVideoProfile: ^VideoProfileInfoKHR, pCapabilities: [^]VideoCapabilitiesKHR) -> Result
ProcGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR           :: #type proc "system" (physicalDevice: PhysicalDevice, pQualityLevelInfo: ^PhysicalDeviceVideoEncodeQualityLevelInfoKHR, pQualityLevelProperties: [^]VideoEncodeQualityLevelPropertiesKHR) -> Result
ProcGetPhysicalDeviceVideoFormatPropertiesKHR                       :: #type proc "system" (physicalDevice: PhysicalDevice, pVideoFormatInfo: ^PhysicalDeviceVideoFormatInfoKHR, pVideoFormatPropertyCount: ^u32, pVideoFormatProperties: [^]VideoFormatPropertiesKHR) -> Result
ProcGetPhysicalDeviceWaylandPresentationSupportKHR                  :: #type proc "system" (physicalDevice: PhysicalDevice, queueFamilyIndex: u32, display: ^wl_display) -> b32
ProcGetPhysicalDeviceWin32PresentationSupportKHR                    :: #type proc "system" (physicalDevice: PhysicalDevice, queueFamilyIndex: u32) -> b32
ProcGetWinrtDisplayNV                                               :: #type proc "system" (physicalDevice: PhysicalDevice, deviceRelativeId: u32, pDisplay: ^DisplayKHR) -> Result
ProcReleaseDisplayEXT                                               :: #type proc "system" (physicalDevice: PhysicalDevice, display: DisplayKHR) -> Result
ProcSubmitDebugUtilsMessageEXT                                      :: #type proc "system" (instance: Instance, messageSeverity: DebugUtilsMessageSeverityFlagsEXT, messageTypes: DebugUtilsMessageTypeFlagsEXT, pCallbackData: ^DebugUtilsMessengerCallbackDataEXT)

// Device Procedure Types
ProcAcquireFullScreenExclusiveModeEXT                      :: #type proc "system" (device: Device, swapchain: SwapchainKHR) -> Result
ProcAcquireNextImage2KHR                                   :: #type proc "system" (device: Device, pAcquireInfo: ^AcquireNextImageInfoKHR, pImageIndex: ^u32) -> Result
ProcAcquireNextImageKHR                                    :: #type proc "system" (device: Device, swapchain: SwapchainKHR, timeout: u64, semaphore: Semaphore, fence: Fence, pImageIndex: ^u32) -> Result
ProcAcquirePerformanceConfigurationINTEL                   :: #type proc "system" (device: Device, pAcquireInfo: ^PerformanceConfigurationAcquireInfoINTEL, pConfiguration: ^PerformanceConfigurationINTEL) -> Result
ProcAcquireProfilingLockKHR                                :: #type proc "system" (device: Device, pInfo: ^AcquireProfilingLockInfoKHR) -> Result
ProcAllocateCommandBuffers                                 :: #type proc "system" (device: Device, pAllocateInfo: ^CommandBufferAllocateInfo, pCommandBuffers: [^]CommandBuffer) -> Result
ProcAllocateDescriptorSets                                 :: #type proc "system" (device: Device, pAllocateInfo: ^DescriptorSetAllocateInfo, pDescriptorSets: [^]DescriptorSet) -> Result
ProcAllocateMemory                                         :: #type proc "system" (device: Device, pAllocateInfo: ^MemoryAllocateInfo, pAllocator: ^AllocationCallbacks, pMemory: ^DeviceMemory) -> Result
ProcAntiLagUpdateAMD                                       :: #type proc "system" (device: Device, pData: ^AntiLagDataAMD)
ProcBeginCommandBuffer                                     :: #type proc "system" (commandBuffer: CommandBuffer, pBeginInfo: ^CommandBufferBeginInfo) -> Result
ProcBindAccelerationStructureMemoryNV                      :: #type proc "system" (device: Device, bindInfoCount: u32, pBindInfos: [^]BindAccelerationStructureMemoryInfoNV) -> Result
ProcBindBufferMemory                                       :: #type proc "system" (device: Device, buffer: Buffer, memory: DeviceMemory, memoryOffset: DeviceSize) -> Result
ProcBindBufferMemory2                                      :: #type proc "system" (device: Device, bindInfoCount: u32, pBindInfos: [^]BindBufferMemoryInfo) -> Result
ProcBindBufferMemory2KHR                                   :: #type proc "system" (device: Device, bindInfoCount: u32, pBindInfos: [^]BindBufferMemoryInfo) -> Result
ProcBindImageMemory                                        :: #type proc "system" (device: Device, image: Image, memory: DeviceMemory, memoryOffset: DeviceSize) -> Result
ProcBindImageMemory2                                       :: #type proc "system" (device: Device, bindInfoCount: u32, pBindInfos: [^]BindImageMemoryInfo) -> Result
ProcBindImageMemory2KHR                                    :: #type proc "system" (device: Device, bindInfoCount: u32, pBindInfos: [^]BindImageMemoryInfo) -> Result
ProcBindOpticalFlowSessionImageNV                          :: #type proc "system" (device: Device, session: OpticalFlowSessionNV, bindingPoint: OpticalFlowSessionBindingPointNV, view: ImageView, layout: ImageLayout) -> Result
ProcBindVideoSessionMemoryKHR                              :: #type proc "system" (device: Device, videoSession: VideoSessionKHR, bindSessionMemoryInfoCount: u32, pBindSessionMemoryInfos: [^]BindVideoSessionMemoryInfoKHR) -> Result
ProcBuildAccelerationStructuresKHR                         :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, infoCount: u32, pInfos: [^]AccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: ^[^]AccelerationStructureBuildRangeInfoKHR) -> Result
ProcBuildMicromapsEXT                                      :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, infoCount: u32, pInfos: [^]MicromapBuildInfoEXT) -> Result
ProcCmdBeginConditionalRenderingEXT                        :: #type proc "system" (commandBuffer: CommandBuffer, pConditionalRenderingBegin: ^ConditionalRenderingBeginInfoEXT)
ProcCmdBeginDebugUtilsLabelEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, pLabelInfo: ^DebugUtilsLabelEXT)
ProcCmdBeginQuery                                          :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, query: u32, flags: QueryControlFlags)
ProcCmdBeginQueryIndexedEXT                                :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, query: u32, flags: QueryControlFlags, index: u32)
ProcCmdBeginRenderPass                                     :: #type proc "system" (commandBuffer: CommandBuffer, pRenderPassBegin: ^RenderPassBeginInfo, contents: SubpassContents)
ProcCmdBeginRenderPass2                                    :: #type proc "system" (commandBuffer: CommandBuffer, pRenderPassBegin: ^RenderPassBeginInfo, pSubpassBeginInfo: ^SubpassBeginInfo)
ProcCmdBeginRenderPass2KHR                                 :: #type proc "system" (commandBuffer: CommandBuffer, pRenderPassBegin: ^RenderPassBeginInfo, pSubpassBeginInfo: ^SubpassBeginInfo)
ProcCmdBeginRendering                                      :: #type proc "system" (commandBuffer: CommandBuffer, pRenderingInfo: ^RenderingInfo)
ProcCmdBeginRenderingKHR                                   :: #type proc "system" (commandBuffer: CommandBuffer, pRenderingInfo: ^RenderingInfo)
ProcCmdBeginTransformFeedbackEXT                           :: #type proc "system" (commandBuffer: CommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: [^]Buffer, pCounterBufferOffsets: [^]DeviceSize)
ProcCmdBeginVideoCodingKHR                                 :: #type proc "system" (commandBuffer: CommandBuffer, pBeginInfo: ^VideoBeginCodingInfoKHR)
ProcCmdBindDescriptorBufferEmbeddedSamplers2EXT            :: #type proc "system" (commandBuffer: CommandBuffer, pBindDescriptorBufferEmbeddedSamplersInfo: ^BindDescriptorBufferEmbeddedSamplersInfoEXT)
ProcCmdBindDescriptorBufferEmbeddedSamplersEXT             :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, set: u32)
ProcCmdBindDescriptorBuffersEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, bufferCount: u32, pBindingInfos: [^]DescriptorBufferBindingInfoEXT)
ProcCmdBindDescriptorSets                                  :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: [^]DescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: [^]u32)
ProcCmdBindDescriptorSets2KHR                              :: #type proc "system" (commandBuffer: CommandBuffer, pBindDescriptorSetsInfo: ^BindDescriptorSetsInfoKHR)
ProcCmdBindIndexBuffer                                     :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, indexType: IndexType)
ProcCmdBindIndexBuffer2KHR                                 :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, size: DeviceSize, indexType: IndexType)
ProcCmdBindInvocationMaskHUAWEI                            :: #type proc "system" (commandBuffer: CommandBuffer, imageView: ImageView, imageLayout: ImageLayout)
ProcCmdBindPipeline                                        :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, pipeline: Pipeline)
ProcCmdBindPipelineShaderGroupNV                           :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, pipeline: Pipeline, groupIndex: u32)
ProcCmdBindShadersEXT                                      :: #type proc "system" (commandBuffer: CommandBuffer, stageCount: u32, pStages: [^]ShaderStageFlags, pShaders: [^]ShaderEXT)
ProcCmdBindShadingRateImageNV                              :: #type proc "system" (commandBuffer: CommandBuffer, imageView: ImageView, imageLayout: ImageLayout)
ProcCmdBindTransformFeedbackBuffersEXT                     :: #type proc "system" (commandBuffer: CommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [^]Buffer, pOffsets: [^]DeviceSize, pSizes: [^]DeviceSize)
ProcCmdBindVertexBuffers                                   :: #type proc "system" (commandBuffer: CommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [^]Buffer, pOffsets: [^]DeviceSize)
ProcCmdBindVertexBuffers2                                  :: #type proc "system" (commandBuffer: CommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [^]Buffer, pOffsets: [^]DeviceSize, pSizes: [^]DeviceSize, pStrides: [^]DeviceSize)
ProcCmdBindVertexBuffers2EXT                               :: #type proc "system" (commandBuffer: CommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [^]Buffer, pOffsets: [^]DeviceSize, pSizes: [^]DeviceSize, pStrides: [^]DeviceSize)
ProcCmdBlitImage                                           :: #type proc "system" (commandBuffer: CommandBuffer, srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regionCount: u32, pRegions: [^]ImageBlit, filter: Filter)
ProcCmdBlitImage2                                          :: #type proc "system" (commandBuffer: CommandBuffer, pBlitImageInfo: ^BlitImageInfo2)
ProcCmdBlitImage2KHR                                       :: #type proc "system" (commandBuffer: CommandBuffer, pBlitImageInfo: ^BlitImageInfo2)
ProcCmdBuildAccelerationStructureNV                        :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^AccelerationStructureInfoNV, instanceData: Buffer, instanceOffset: DeviceSize, update: b32, dst: AccelerationStructureNV, src: AccelerationStructureNV, scratch: Buffer, scratchOffset: DeviceSize)
ProcCmdBuildAccelerationStructuresIndirectKHR              :: #type proc "system" (commandBuffer: CommandBuffer, infoCount: u32, pInfos: [^]AccelerationStructureBuildGeometryInfoKHR, pIndirectDeviceAddresses: [^]DeviceAddress, pIndirectStrides: [^]u32, ppMaxPrimitiveCounts: ^[^]u32)
ProcCmdBuildAccelerationStructuresKHR                      :: #type proc "system" (commandBuffer: CommandBuffer, infoCount: u32, pInfos: [^]AccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: ^[^]AccelerationStructureBuildRangeInfoKHR)
ProcCmdBuildMicromapsEXT                                   :: #type proc "system" (commandBuffer: CommandBuffer, infoCount: u32, pInfos: [^]MicromapBuildInfoEXT)
ProcCmdClearAttachments                                    :: #type proc "system" (commandBuffer: CommandBuffer, attachmentCount: u32, pAttachments: [^]ClearAttachment, rectCount: u32, pRects: [^]ClearRect)
ProcCmdClearColorImage                                     :: #type proc "system" (commandBuffer: CommandBuffer, image: Image, imageLayout: ImageLayout, pColor: ^ClearColorValue, rangeCount: u32, pRanges: [^]ImageSubresourceRange)
ProcCmdClearDepthStencilImage                              :: #type proc "system" (commandBuffer: CommandBuffer, image: Image, imageLayout: ImageLayout, pDepthStencil: ^ClearDepthStencilValue, rangeCount: u32, pRanges: [^]ImageSubresourceRange)
ProcCmdControlVideoCodingKHR                               :: #type proc "system" (commandBuffer: CommandBuffer, pCodingControlInfo: ^VideoCodingControlInfoKHR)
ProcCmdCopyAccelerationStructureKHR                        :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyAccelerationStructureInfoKHR)
ProcCmdCopyAccelerationStructureNV                         :: #type proc "system" (commandBuffer: CommandBuffer, dst: AccelerationStructureNV, src: AccelerationStructureNV, mode: CopyAccelerationStructureModeKHR)
ProcCmdCopyAccelerationStructureToMemoryKHR                :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyAccelerationStructureToMemoryInfoKHR)
ProcCmdCopyBuffer                                          :: #type proc "system" (commandBuffer: CommandBuffer, srcBuffer: Buffer, dstBuffer: Buffer, regionCount: u32, pRegions: [^]BufferCopy)
ProcCmdCopyBuffer2                                         :: #type proc "system" (commandBuffer: CommandBuffer, pCopyBufferInfo: ^CopyBufferInfo2)
ProcCmdCopyBuffer2KHR                                      :: #type proc "system" (commandBuffer: CommandBuffer, pCopyBufferInfo: ^CopyBufferInfo2)
ProcCmdCopyBufferToImage                                   :: #type proc "system" (commandBuffer: CommandBuffer, srcBuffer: Buffer, dstImage: Image, dstImageLayout: ImageLayout, regionCount: u32, pRegions: [^]BufferImageCopy)
ProcCmdCopyBufferToImage2                                  :: #type proc "system" (commandBuffer: CommandBuffer, pCopyBufferToImageInfo: ^CopyBufferToImageInfo2)
ProcCmdCopyBufferToImage2KHR                               :: #type proc "system" (commandBuffer: CommandBuffer, pCopyBufferToImageInfo: ^CopyBufferToImageInfo2)
ProcCmdCopyImage                                           :: #type proc "system" (commandBuffer: CommandBuffer, srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regionCount: u32, pRegions: [^]ImageCopy)
ProcCmdCopyImage2                                          :: #type proc "system" (commandBuffer: CommandBuffer, pCopyImageInfo: ^CopyImageInfo2)
ProcCmdCopyImage2KHR                                       :: #type proc "system" (commandBuffer: CommandBuffer, pCopyImageInfo: ^CopyImageInfo2)
ProcCmdCopyImageToBuffer                                   :: #type proc "system" (commandBuffer: CommandBuffer, srcImage: Image, srcImageLayout: ImageLayout, dstBuffer: Buffer, regionCount: u32, pRegions: [^]BufferImageCopy)
ProcCmdCopyImageToBuffer2                                  :: #type proc "system" (commandBuffer: CommandBuffer, pCopyImageToBufferInfo: ^CopyImageToBufferInfo2)
ProcCmdCopyImageToBuffer2KHR                               :: #type proc "system" (commandBuffer: CommandBuffer, pCopyImageToBufferInfo: ^CopyImageToBufferInfo2)
ProcCmdCopyMemoryIndirectNV                                :: #type proc "system" (commandBuffer: CommandBuffer, copyBufferAddress: DeviceAddress, copyCount: u32, stride: u32)
ProcCmdCopyMemoryToAccelerationStructureKHR                :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyMemoryToAccelerationStructureInfoKHR)
ProcCmdCopyMemoryToImageIndirectNV                         :: #type proc "system" (commandBuffer: CommandBuffer, copyBufferAddress: DeviceAddress, copyCount: u32, stride: u32, dstImage: Image, dstImageLayout: ImageLayout, pImageSubresources: [^]ImageSubresourceLayers)
ProcCmdCopyMemoryToMicromapEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyMemoryToMicromapInfoEXT)
ProcCmdCopyMicromapEXT                                     :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyMicromapInfoEXT)
ProcCmdCopyMicromapToMemoryEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, pInfo: ^CopyMicromapToMemoryInfoEXT)
ProcCmdCopyQueryPoolResults                                :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, firstQuery: u32, queryCount: u32, dstBuffer: Buffer, dstOffset: DeviceSize, stride: DeviceSize, flags: QueryResultFlags)
ProcCmdCuLaunchKernelNVX                                   :: #type proc "system" (commandBuffer: CommandBuffer, pLaunchInfo: ^CuLaunchInfoNVX)
ProcCmdCudaLaunchKernelNV                                  :: #type proc "system" (commandBuffer: CommandBuffer, pLaunchInfo: ^CudaLaunchInfoNV)
ProcCmdDebugMarkerBeginEXT                                 :: #type proc "system" (commandBuffer: CommandBuffer, pMarkerInfo: ^DebugMarkerMarkerInfoEXT)
ProcCmdDebugMarkerEndEXT                                   :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdDebugMarkerInsertEXT                                :: #type proc "system" (commandBuffer: CommandBuffer, pMarkerInfo: ^DebugMarkerMarkerInfoEXT)
ProcCmdDecodeVideoKHR                                      :: #type proc "system" (commandBuffer: CommandBuffer, pDecodeInfo: ^VideoDecodeInfoKHR)
ProcCmdDecompressMemoryIndirectCountNV                     :: #type proc "system" (commandBuffer: CommandBuffer, indirectCommandsAddress: DeviceAddress, indirectCommandsCountAddress: DeviceAddress, stride: u32)
ProcCmdDecompressMemoryNV                                  :: #type proc "system" (commandBuffer: CommandBuffer, decompressRegionCount: u32, pDecompressMemoryRegions: [^]DecompressMemoryRegionNV)
ProcCmdDispatch                                            :: #type proc "system" (commandBuffer: CommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32)
ProcCmdDispatchBase                                        :: #type proc "system" (commandBuffer: CommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32)
ProcCmdDispatchBaseKHR                                     :: #type proc "system" (commandBuffer: CommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32)
ProcCmdDispatchIndirect                                    :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize)
ProcCmdDraw                                                :: #type proc "system" (commandBuffer: CommandBuffer, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32)
ProcCmdDrawClusterHUAWEI                                   :: #type proc "system" (commandBuffer: CommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32)
ProcCmdDrawClusterIndirectHUAWEI                           :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize)
ProcCmdDrawIndexed                                         :: #type proc "system" (commandBuffer: CommandBuffer, indexCount: u32, instanceCount: u32, firstIndex: u32, vertexOffset: i32, firstInstance: u32)
ProcCmdDrawIndexedIndirect                                 :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, drawCount: u32, stride: u32)
ProcCmdDrawIndexedIndirectCount                            :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawIndexedIndirectCountAMD                         :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawIndexedIndirectCountKHR                         :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawIndirect                                        :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, drawCount: u32, stride: u32)
ProcCmdDrawIndirectByteCountEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, instanceCount: u32, firstInstance: u32, counterBuffer: Buffer, counterBufferOffset: DeviceSize, counterOffset: u32, vertexStride: u32)
ProcCmdDrawIndirectCount                                   :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawIndirectCountAMD                                :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawIndirectCountKHR                                :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawMeshTasksEXT                                    :: #type proc "system" (commandBuffer: CommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32)
ProcCmdDrawMeshTasksIndirectCountEXT                       :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawMeshTasksIndirectCountNV                        :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, countBuffer: Buffer, countBufferOffset: DeviceSize, maxDrawCount: u32, stride: u32)
ProcCmdDrawMeshTasksIndirectEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, drawCount: u32, stride: u32)
ProcCmdDrawMeshTasksIndirectNV                             :: #type proc "system" (commandBuffer: CommandBuffer, buffer: Buffer, offset: DeviceSize, drawCount: u32, stride: u32)
ProcCmdDrawMeshTasksNV                                     :: #type proc "system" (commandBuffer: CommandBuffer, taskCount: u32, firstTask: u32)
ProcCmdDrawMultiEXT                                        :: #type proc "system" (commandBuffer: CommandBuffer, drawCount: u32, pVertexInfo: ^MultiDrawInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32)
ProcCmdDrawMultiIndexedEXT                                 :: #type proc "system" (commandBuffer: CommandBuffer, drawCount: u32, pIndexInfo: ^MultiDrawIndexedInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32, pVertexOffset: ^i32)
ProcCmdEncodeVideoKHR                                      :: #type proc "system" (commandBuffer: CommandBuffer, pEncodeInfo: ^VideoEncodeInfoKHR)
ProcCmdEndConditionalRenderingEXT                          :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdEndDebugUtilsLabelEXT                               :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdEndQuery                                            :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, query: u32)
ProcCmdEndQueryIndexedEXT                                  :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, query: u32, index: u32)
ProcCmdEndRenderPass                                       :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdEndRenderPass2                                      :: #type proc "system" (commandBuffer: CommandBuffer, pSubpassEndInfo: ^SubpassEndInfo)
ProcCmdEndRenderPass2KHR                                   :: #type proc "system" (commandBuffer: CommandBuffer, pSubpassEndInfo: ^SubpassEndInfo)
ProcCmdEndRendering                                        :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdEndRenderingKHR                                     :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdEndTransformFeedbackEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: [^]Buffer, pCounterBufferOffsets: [^]DeviceSize)
ProcCmdEndVideoCodingKHR                                   :: #type proc "system" (commandBuffer: CommandBuffer, pEndCodingInfo: ^VideoEndCodingInfoKHR)
ProcCmdExecuteCommands                                     :: #type proc "system" (commandBuffer: CommandBuffer, commandBufferCount: u32, pCommandBuffers: [^]CommandBuffer)
ProcCmdExecuteGeneratedCommandsEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, isPreprocessed: b32, pGeneratedCommandsInfo: ^GeneratedCommandsInfoEXT)
ProcCmdExecuteGeneratedCommandsNV                          :: #type proc "system" (commandBuffer: CommandBuffer, isPreprocessed: b32, pGeneratedCommandsInfo: ^GeneratedCommandsInfoNV)
ProcCmdFillBuffer                                          :: #type proc "system" (commandBuffer: CommandBuffer, dstBuffer: Buffer, dstOffset: DeviceSize, size: DeviceSize, data: u32)
ProcCmdInsertDebugUtilsLabelEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, pLabelInfo: ^DebugUtilsLabelEXT)
ProcCmdNextSubpass                                         :: #type proc "system" (commandBuffer: CommandBuffer, contents: SubpassContents)
ProcCmdNextSubpass2                                        :: #type proc "system" (commandBuffer: CommandBuffer, pSubpassBeginInfo: ^SubpassBeginInfo, pSubpassEndInfo: ^SubpassEndInfo)
ProcCmdNextSubpass2KHR                                     :: #type proc "system" (commandBuffer: CommandBuffer, pSubpassBeginInfo: ^SubpassBeginInfo, pSubpassEndInfo: ^SubpassEndInfo)
ProcCmdOpticalFlowExecuteNV                                :: #type proc "system" (commandBuffer: CommandBuffer, session: OpticalFlowSessionNV, pExecuteInfo: ^OpticalFlowExecuteInfoNV)
ProcCmdPipelineBarrier                                     :: #type proc "system" (commandBuffer: CommandBuffer, srcStageMask: PipelineStageFlags, dstStageMask: PipelineStageFlags, dependencyFlags: DependencyFlags, memoryBarrierCount: u32, pMemoryBarriers: [^]MemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: [^]BufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: [^]ImageMemoryBarrier)
ProcCmdPipelineBarrier2                                    :: #type proc "system" (commandBuffer: CommandBuffer, pDependencyInfo: ^DependencyInfo)
ProcCmdPipelineBarrier2KHR                                 :: #type proc "system" (commandBuffer: CommandBuffer, pDependencyInfo: ^DependencyInfo)
ProcCmdPreprocessGeneratedCommandsEXT                      :: #type proc "system" (commandBuffer: CommandBuffer, pGeneratedCommandsInfo: ^GeneratedCommandsInfoEXT, stateCommandBuffer: CommandBuffer)
ProcCmdPreprocessGeneratedCommandsNV                       :: #type proc "system" (commandBuffer: CommandBuffer, pGeneratedCommandsInfo: ^GeneratedCommandsInfoNV)
ProcCmdPushConstants                                       :: #type proc "system" (commandBuffer: CommandBuffer, layout: PipelineLayout, stageFlags: ShaderStageFlags, offset: u32, size: u32, pValues: rawptr)
ProcCmdPushConstants2KHR                                   :: #type proc "system" (commandBuffer: CommandBuffer, pPushConstantsInfo: ^PushConstantsInfoKHR)
ProcCmdPushDescriptorSet2KHR                               :: #type proc "system" (commandBuffer: CommandBuffer, pPushDescriptorSetInfo: ^PushDescriptorSetInfoKHR)
ProcCmdPushDescriptorSetKHR                                :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, set: u32, descriptorWriteCount: u32, pDescriptorWrites: [^]WriteDescriptorSet)
ProcCmdPushDescriptorSetWithTemplate2KHR                   :: #type proc "system" (commandBuffer: CommandBuffer, pPushDescriptorSetWithTemplateInfo: ^PushDescriptorSetWithTemplateInfoKHR)
ProcCmdPushDescriptorSetWithTemplateKHR                    :: #type proc "system" (commandBuffer: CommandBuffer, descriptorUpdateTemplate: DescriptorUpdateTemplate, layout: PipelineLayout, set: u32, pData: rawptr)
ProcCmdResetEvent                                          :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, stageMask: PipelineStageFlags)
ProcCmdResetEvent2                                         :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, stageMask: PipelineStageFlags2)
ProcCmdResetEvent2KHR                                      :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, stageMask: PipelineStageFlags2)
ProcCmdResetQueryPool                                      :: #type proc "system" (commandBuffer: CommandBuffer, queryPool: QueryPool, firstQuery: u32, queryCount: u32)
ProcCmdResolveImage                                        :: #type proc "system" (commandBuffer: CommandBuffer, srcImage: Image, srcImageLayout: ImageLayout, dstImage: Image, dstImageLayout: ImageLayout, regionCount: u32, pRegions: [^]ImageResolve)
ProcCmdResolveImage2                                       :: #type proc "system" (commandBuffer: CommandBuffer, pResolveImageInfo: ^ResolveImageInfo2)
ProcCmdResolveImage2KHR                                    :: #type proc "system" (commandBuffer: CommandBuffer, pResolveImageInfo: ^ResolveImageInfo2)
ProcCmdSetAlphaToCoverageEnableEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, alphaToCoverageEnable: b32)
ProcCmdSetAlphaToOneEnableEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, alphaToOneEnable: b32)
ProcCmdSetAttachmentFeedbackLoopEnableEXT                  :: #type proc "system" (commandBuffer: CommandBuffer, aspectMask: ImageAspectFlags)
ProcCmdSetBlendConstants                                   :: #type proc "system" (commandBuffer: CommandBuffer, blendConstants: ^[4]f32)
ProcCmdSetCheckpointNV                                     :: #type proc "system" (commandBuffer: CommandBuffer, pCheckpointMarker: rawptr)
ProcCmdSetCoarseSampleOrderNV                              :: #type proc "system" (commandBuffer: CommandBuffer, sampleOrderType: CoarseSampleOrderTypeNV, customSampleOrderCount: u32, pCustomSampleOrders: [^]CoarseSampleOrderCustomNV)
ProcCmdSetColorBlendAdvancedEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendAdvanced: ^ColorBlendAdvancedEXT)
ProcCmdSetColorBlendEnableEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendEnables: [^]b32)
ProcCmdSetColorBlendEquationEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorBlendEquations: [^]ColorBlendEquationEXT)
ProcCmdSetColorWriteMaskEXT                                :: #type proc "system" (commandBuffer: CommandBuffer, firstAttachment: u32, attachmentCount: u32, pColorWriteMasks: [^]ColorComponentFlags)
ProcCmdSetConservativeRasterizationModeEXT                 :: #type proc "system" (commandBuffer: CommandBuffer, conservativeRasterizationMode: ConservativeRasterizationModeEXT)
ProcCmdSetCoverageModulationModeNV                         :: #type proc "system" (commandBuffer: CommandBuffer, coverageModulationMode: CoverageModulationModeNV)
ProcCmdSetCoverageModulationTableEnableNV                  :: #type proc "system" (commandBuffer: CommandBuffer, coverageModulationTableEnable: b32)
ProcCmdSetCoverageModulationTableNV                        :: #type proc "system" (commandBuffer: CommandBuffer, coverageModulationTableCount: u32, pCoverageModulationTable: [^]f32)
ProcCmdSetCoverageReductionModeNV                          :: #type proc "system" (commandBuffer: CommandBuffer, coverageReductionMode: CoverageReductionModeNV)
ProcCmdSetCoverageToColorEnableNV                          :: #type proc "system" (commandBuffer: CommandBuffer, coverageToColorEnable: b32)
ProcCmdSetCoverageToColorLocationNV                        :: #type proc "system" (commandBuffer: CommandBuffer, coverageToColorLocation: u32)
ProcCmdSetCullMode                                         :: #type proc "system" (commandBuffer: CommandBuffer, cullMode: CullModeFlags)
ProcCmdSetCullModeEXT                                      :: #type proc "system" (commandBuffer: CommandBuffer, cullMode: CullModeFlags)
ProcCmdSetDepthBias                                        :: #type proc "system" (commandBuffer: CommandBuffer, depthBiasConstantFactor: f32, depthBiasClamp: f32, depthBiasSlopeFactor: f32)
ProcCmdSetDepthBias2EXT                                    :: #type proc "system" (commandBuffer: CommandBuffer, pDepthBiasInfo: ^DepthBiasInfoEXT)
ProcCmdSetDepthBiasEnable                                  :: #type proc "system" (commandBuffer: CommandBuffer, depthBiasEnable: b32)
ProcCmdSetDepthBiasEnableEXT                               :: #type proc "system" (commandBuffer: CommandBuffer, depthBiasEnable: b32)
ProcCmdSetDepthBounds                                      :: #type proc "system" (commandBuffer: CommandBuffer, minDepthBounds: f32, maxDepthBounds: f32)
ProcCmdSetDepthBoundsTestEnable                            :: #type proc "system" (commandBuffer: CommandBuffer, depthBoundsTestEnable: b32)
ProcCmdSetDepthBoundsTestEnableEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, depthBoundsTestEnable: b32)
ProcCmdSetDepthClampEnableEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, depthClampEnable: b32)
ProcCmdSetDepthClampRangeEXT                               :: #type proc "system" (commandBuffer: CommandBuffer, depthClampMode: DepthClampModeEXT, pDepthClampRange: ^DepthClampRangeEXT)
ProcCmdSetDepthClipEnableEXT                               :: #type proc "system" (commandBuffer: CommandBuffer, depthClipEnable: b32)
ProcCmdSetDepthClipNegativeOneToOneEXT                     :: #type proc "system" (commandBuffer: CommandBuffer, negativeOneToOne: b32)
ProcCmdSetDepthCompareOp                                   :: #type proc "system" (commandBuffer: CommandBuffer, depthCompareOp: CompareOp)
ProcCmdSetDepthCompareOpEXT                                :: #type proc "system" (commandBuffer: CommandBuffer, depthCompareOp: CompareOp)
ProcCmdSetDepthTestEnable                                  :: #type proc "system" (commandBuffer: CommandBuffer, depthTestEnable: b32)
ProcCmdSetDepthTestEnableEXT                               :: #type proc "system" (commandBuffer: CommandBuffer, depthTestEnable: b32)
ProcCmdSetDepthWriteEnable                                 :: #type proc "system" (commandBuffer: CommandBuffer, depthWriteEnable: b32)
ProcCmdSetDepthWriteEnableEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, depthWriteEnable: b32)
ProcCmdSetDescriptorBufferOffsets2EXT                      :: #type proc "system" (commandBuffer: CommandBuffer, pSetDescriptorBufferOffsetsInfo: ^SetDescriptorBufferOffsetsInfoEXT)
ProcCmdSetDescriptorBufferOffsetsEXT                       :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, layout: PipelineLayout, firstSet: u32, setCount: u32, pBufferIndices: [^]u32, pOffsets: [^]DeviceSize)
ProcCmdSetDeviceMask                                       :: #type proc "system" (commandBuffer: CommandBuffer, deviceMask: u32)
ProcCmdSetDeviceMaskKHR                                    :: #type proc "system" (commandBuffer: CommandBuffer, deviceMask: u32)
ProcCmdSetDiscardRectangleEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, firstDiscardRectangle: u32, discardRectangleCount: u32, pDiscardRectangles: [^]Rect2D)
ProcCmdSetDiscardRectangleEnableEXT                        :: #type proc "system" (commandBuffer: CommandBuffer, discardRectangleEnable: b32)
ProcCmdSetDiscardRectangleModeEXT                          :: #type proc "system" (commandBuffer: CommandBuffer, discardRectangleMode: DiscardRectangleModeEXT)
ProcCmdSetEvent                                            :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, stageMask: PipelineStageFlags)
ProcCmdSetEvent2                                           :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, pDependencyInfo: ^DependencyInfo)
ProcCmdSetEvent2KHR                                        :: #type proc "system" (commandBuffer: CommandBuffer, event: Event, pDependencyInfo: ^DependencyInfo)
ProcCmdSetExclusiveScissorEnableNV                         :: #type proc "system" (commandBuffer: CommandBuffer, firstExclusiveScissor: u32, exclusiveScissorCount: u32, pExclusiveScissorEnables: [^]b32)
ProcCmdSetExclusiveScissorNV                               :: #type proc "system" (commandBuffer: CommandBuffer, firstExclusiveScissor: u32, exclusiveScissorCount: u32, pExclusiveScissors: [^]Rect2D)
ProcCmdSetExtraPrimitiveOverestimationSizeEXT              :: #type proc "system" (commandBuffer: CommandBuffer, extraPrimitiveOverestimationSize: f32)
ProcCmdSetFragmentShadingRateEnumNV                        :: #type proc "system" (commandBuffer: CommandBuffer, shadingRate: FragmentShadingRateNV, combinerOps: ^[2]FragmentShadingRateCombinerOpKHR)
ProcCmdSetFragmentShadingRateKHR                           :: #type proc "system" (commandBuffer: CommandBuffer, pFragmentSize: ^Extent2D, combinerOps: ^[2]FragmentShadingRateCombinerOpKHR)
ProcCmdSetFrontFace                                        :: #type proc "system" (commandBuffer: CommandBuffer, frontFace: FrontFace)
ProcCmdSetFrontFaceEXT                                     :: #type proc "system" (commandBuffer: CommandBuffer, frontFace: FrontFace)
ProcCmdSetLineRasterizationModeEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, lineRasterizationMode: LineRasterizationModeEXT)
ProcCmdSetLineStippleEXT                                   :: #type proc "system" (commandBuffer: CommandBuffer, lineStippleFactor: u32, lineStipplePattern: u16)
ProcCmdSetLineStippleEnableEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, stippledLineEnable: b32)
ProcCmdSetLineStippleKHR                                   :: #type proc "system" (commandBuffer: CommandBuffer, lineStippleFactor: u32, lineStipplePattern: u16)
ProcCmdSetLineWidth                                        :: #type proc "system" (commandBuffer: CommandBuffer, lineWidth: f32)
ProcCmdSetLogicOpEXT                                       :: #type proc "system" (commandBuffer: CommandBuffer, logicOp: LogicOp)
ProcCmdSetLogicOpEnableEXT                                 :: #type proc "system" (commandBuffer: CommandBuffer, logicOpEnable: b32)
ProcCmdSetPatchControlPointsEXT                            :: #type proc "system" (commandBuffer: CommandBuffer, patchControlPoints: u32)
ProcCmdSetPerformanceMarkerINTEL                           :: #type proc "system" (commandBuffer: CommandBuffer, pMarkerInfo: ^PerformanceMarkerInfoINTEL) -> Result
ProcCmdSetPerformanceOverrideINTEL                         :: #type proc "system" (commandBuffer: CommandBuffer, pOverrideInfo: ^PerformanceOverrideInfoINTEL) -> Result
ProcCmdSetPerformanceStreamMarkerINTEL                     :: #type proc "system" (commandBuffer: CommandBuffer, pMarkerInfo: ^PerformanceStreamMarkerInfoINTEL) -> Result
ProcCmdSetPolygonModeEXT                                   :: #type proc "system" (commandBuffer: CommandBuffer, polygonMode: PolygonMode)
ProcCmdSetPrimitiveRestartEnable                           :: #type proc "system" (commandBuffer: CommandBuffer, primitiveRestartEnable: b32)
ProcCmdSetPrimitiveRestartEnableEXT                        :: #type proc "system" (commandBuffer: CommandBuffer, primitiveRestartEnable: b32)
ProcCmdSetPrimitiveTopology                                :: #type proc "system" (commandBuffer: CommandBuffer, primitiveTopology: PrimitiveTopology)
ProcCmdSetPrimitiveTopologyEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, primitiveTopology: PrimitiveTopology)
ProcCmdSetProvokingVertexModeEXT                           :: #type proc "system" (commandBuffer: CommandBuffer, provokingVertexMode: ProvokingVertexModeEXT)
ProcCmdSetRasterizationSamplesEXT                          :: #type proc "system" (commandBuffer: CommandBuffer, rasterizationSamples: SampleCountFlags)
ProcCmdSetRasterizationStreamEXT                           :: #type proc "system" (commandBuffer: CommandBuffer, rasterizationStream: u32)
ProcCmdSetRasterizerDiscardEnable                          :: #type proc "system" (commandBuffer: CommandBuffer, rasterizerDiscardEnable: b32)
ProcCmdSetRasterizerDiscardEnableEXT                       :: #type proc "system" (commandBuffer: CommandBuffer, rasterizerDiscardEnable: b32)
ProcCmdSetRayTracingPipelineStackSizeKHR                   :: #type proc "system" (commandBuffer: CommandBuffer, pipelineStackSize: u32)
ProcCmdSetRenderingAttachmentLocationsKHR                  :: #type proc "system" (commandBuffer: CommandBuffer, pLocationInfo: ^RenderingAttachmentLocationInfoKHR)
ProcCmdSetRenderingInputAttachmentIndicesKHR               :: #type proc "system" (commandBuffer: CommandBuffer, pInputAttachmentIndexInfo: ^RenderingInputAttachmentIndexInfoKHR)
ProcCmdSetRepresentativeFragmentTestEnableNV               :: #type proc "system" (commandBuffer: CommandBuffer, representativeFragmentTestEnable: b32)
ProcCmdSetSampleLocationsEXT                               :: #type proc "system" (commandBuffer: CommandBuffer, pSampleLocationsInfo: ^SampleLocationsInfoEXT)
ProcCmdSetSampleLocationsEnableEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, sampleLocationsEnable: b32)
ProcCmdSetSampleMaskEXT                                    :: #type proc "system" (commandBuffer: CommandBuffer, samples: SampleCountFlags, pSampleMask: ^SampleMask)
ProcCmdSetScissor                                          :: #type proc "system" (commandBuffer: CommandBuffer, firstScissor: u32, scissorCount: u32, pScissors: [^]Rect2D)
ProcCmdSetScissorWithCount                                 :: #type proc "system" (commandBuffer: CommandBuffer, scissorCount: u32, pScissors: [^]Rect2D)
ProcCmdSetScissorWithCountEXT                              :: #type proc "system" (commandBuffer: CommandBuffer, scissorCount: u32, pScissors: [^]Rect2D)
ProcCmdSetShadingRateImageEnableNV                         :: #type proc "system" (commandBuffer: CommandBuffer, shadingRateImageEnable: b32)
ProcCmdSetStencilCompareMask                               :: #type proc "system" (commandBuffer: CommandBuffer, faceMask: StencilFaceFlags, compareMask: u32)
ProcCmdSetStencilOp                                        :: #type proc "system" (commandBuffer: CommandBuffer, faceMask: StencilFaceFlags, failOp: StencilOp, passOp: StencilOp, depthFailOp: StencilOp, compareOp: CompareOp)
ProcCmdSetStencilOpEXT                                     :: #type proc "system" (commandBuffer: CommandBuffer, faceMask: StencilFaceFlags, failOp: StencilOp, passOp: StencilOp, depthFailOp: StencilOp, compareOp: CompareOp)
ProcCmdSetStencilReference                                 :: #type proc "system" (commandBuffer: CommandBuffer, faceMask: StencilFaceFlags, reference: u32)
ProcCmdSetStencilTestEnable                                :: #type proc "system" (commandBuffer: CommandBuffer, stencilTestEnable: b32)
ProcCmdSetStencilTestEnableEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, stencilTestEnable: b32)
ProcCmdSetStencilWriteMask                                 :: #type proc "system" (commandBuffer: CommandBuffer, faceMask: StencilFaceFlags, writeMask: u32)
ProcCmdSetTessellationDomainOriginEXT                      :: #type proc "system" (commandBuffer: CommandBuffer, domainOrigin: TessellationDomainOrigin)
ProcCmdSetVertexInputEXT                                   :: #type proc "system" (commandBuffer: CommandBuffer, vertexBindingDescriptionCount: u32, pVertexBindingDescriptions: [^]VertexInputBindingDescription2EXT, vertexAttributeDescriptionCount: u32, pVertexAttributeDescriptions: [^]VertexInputAttributeDescription2EXT)
ProcCmdSetViewport                                         :: #type proc "system" (commandBuffer: CommandBuffer, firstViewport: u32, viewportCount: u32, pViewports: [^]Viewport)
ProcCmdSetViewportShadingRatePaletteNV                     :: #type proc "system" (commandBuffer: CommandBuffer, firstViewport: u32, viewportCount: u32, pShadingRatePalettes: [^]ShadingRatePaletteNV)
ProcCmdSetViewportSwizzleNV                                :: #type proc "system" (commandBuffer: CommandBuffer, firstViewport: u32, viewportCount: u32, pViewportSwizzles: [^]ViewportSwizzleNV)
ProcCmdSetViewportWScalingEnableNV                         :: #type proc "system" (commandBuffer: CommandBuffer, viewportWScalingEnable: b32)
ProcCmdSetViewportWScalingNV                               :: #type proc "system" (commandBuffer: CommandBuffer, firstViewport: u32, viewportCount: u32, pViewportWScalings: [^]ViewportWScalingNV)
ProcCmdSetViewportWithCount                                :: #type proc "system" (commandBuffer: CommandBuffer, viewportCount: u32, pViewports: [^]Viewport)
ProcCmdSetViewportWithCountEXT                             :: #type proc "system" (commandBuffer: CommandBuffer, viewportCount: u32, pViewports: [^]Viewport)
ProcCmdSubpassShadingHUAWEI                                :: #type proc "system" (commandBuffer: CommandBuffer)
ProcCmdTraceRaysIndirect2KHR                               :: #type proc "system" (commandBuffer: CommandBuffer, indirectDeviceAddress: DeviceAddress)
ProcCmdTraceRaysIndirectKHR                                :: #type proc "system" (commandBuffer: CommandBuffer, pRaygenShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pMissShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pHitShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pCallableShaderBindingTable: [^]StridedDeviceAddressRegionKHR, indirectDeviceAddress: DeviceAddress)
ProcCmdTraceRaysKHR                                        :: #type proc "system" (commandBuffer: CommandBuffer, pRaygenShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pMissShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pHitShaderBindingTable: [^]StridedDeviceAddressRegionKHR, pCallableShaderBindingTable: [^]StridedDeviceAddressRegionKHR, width: u32, height: u32, depth: u32)
ProcCmdTraceRaysNV                                         :: #type proc "system" (commandBuffer: CommandBuffer, raygenShaderBindingTableBuffer: Buffer, raygenShaderBindingOffset: DeviceSize, missShaderBindingTableBuffer: Buffer, missShaderBindingOffset: DeviceSize, missShaderBindingStride: DeviceSize, hitShaderBindingTableBuffer: Buffer, hitShaderBindingOffset: DeviceSize, hitShaderBindingStride: DeviceSize, callableShaderBindingTableBuffer: Buffer, callableShaderBindingOffset: DeviceSize, callableShaderBindingStride: DeviceSize, width: u32, height: u32, depth: u32)
ProcCmdUpdateBuffer                                        :: #type proc "system" (commandBuffer: CommandBuffer, dstBuffer: Buffer, dstOffset: DeviceSize, dataSize: DeviceSize, pData: rawptr)
ProcCmdUpdatePipelineIndirectBufferNV                      :: #type proc "system" (commandBuffer: CommandBuffer, pipelineBindPoint: PipelineBindPoint, pipeline: Pipeline)
ProcCmdWaitEvents                                          :: #type proc "system" (commandBuffer: CommandBuffer, eventCount: u32, pEvents: [^]Event, srcStageMask: PipelineStageFlags, dstStageMask: PipelineStageFlags, memoryBarrierCount: u32, pMemoryBarriers: [^]MemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: [^]BufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: [^]ImageMemoryBarrier)
ProcCmdWaitEvents2                                         :: #type proc "system" (commandBuffer: CommandBuffer, eventCount: u32, pEvents: [^]Event, pDependencyInfos: [^]DependencyInfo)
ProcCmdWaitEvents2KHR                                      :: #type proc "system" (commandBuffer: CommandBuffer, eventCount: u32, pEvents: [^]Event, pDependencyInfos: [^]DependencyInfo)
ProcCmdWriteAccelerationStructuresPropertiesKHR            :: #type proc "system" (commandBuffer: CommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: [^]AccelerationStructureKHR, queryType: QueryType, queryPool: QueryPool, firstQuery: u32)
ProcCmdWriteAccelerationStructuresPropertiesNV             :: #type proc "system" (commandBuffer: CommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: [^]AccelerationStructureNV, queryType: QueryType, queryPool: QueryPool, firstQuery: u32)
ProcCmdWriteBufferMarker2AMD                               :: #type proc "system" (commandBuffer: CommandBuffer, stage: PipelineStageFlags2, dstBuffer: Buffer, dstOffset: DeviceSize, marker: u32)
ProcCmdWriteBufferMarkerAMD                                :: #type proc "system" (commandBuffer: CommandBuffer, pipelineStage: PipelineStageFlags, dstBuffer: Buffer, dstOffset: DeviceSize, marker: u32)
ProcCmdWriteMicromapsPropertiesEXT                         :: #type proc "system" (commandBuffer: CommandBuffer, micromapCount: u32, pMicromaps: [^]MicromapEXT, queryType: QueryType, queryPool: QueryPool, firstQuery: u32)
ProcCmdWriteTimestamp                                      :: #type proc "system" (commandBuffer: CommandBuffer, pipelineStage: PipelineStageFlags, queryPool: QueryPool, query: u32)
ProcCmdWriteTimestamp2                                     :: #type proc "system" (commandBuffer: CommandBuffer, stage: PipelineStageFlags2, queryPool: QueryPool, query: u32)
ProcCmdWriteTimestamp2KHR                                  :: #type proc "system" (commandBuffer: CommandBuffer, stage: PipelineStageFlags2, queryPool: QueryPool, query: u32)
ProcCompileDeferredNV                                      :: #type proc "system" (device: Device, pipeline: Pipeline, shader: u32) -> Result
ProcCopyAccelerationStructureKHR                           :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyAccelerationStructureInfoKHR) -> Result
ProcCopyAccelerationStructureToMemoryKHR                   :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyAccelerationStructureToMemoryInfoKHR) -> Result
ProcCopyImageToImageEXT                                    :: #type proc "system" (device: Device, pCopyImageToImageInfo: ^CopyImageToImageInfoEXT) -> Result
ProcCopyImageToMemoryEXT                                   :: #type proc "system" (device: Device, pCopyImageToMemoryInfo: ^CopyImageToMemoryInfoEXT) -> Result
ProcCopyMemoryToAccelerationStructureKHR                   :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyMemoryToAccelerationStructureInfoKHR) -> Result
ProcCopyMemoryToImageEXT                                   :: #type proc "system" (device: Device, pCopyMemoryToImageInfo: ^CopyMemoryToImageInfoEXT) -> Result
ProcCopyMemoryToMicromapEXT                                :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyMemoryToMicromapInfoEXT) -> Result
ProcCopyMicromapEXT                                        :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyMicromapInfoEXT) -> Result
ProcCopyMicromapToMemoryEXT                                :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pInfo: ^CopyMicromapToMemoryInfoEXT) -> Result
ProcCreateAccelerationStructureKHR                         :: #type proc "system" (device: Device, pCreateInfo: ^AccelerationStructureCreateInfoKHR, pAllocator: ^AllocationCallbacks, pAccelerationStructure: ^AccelerationStructureKHR) -> Result
ProcCreateAccelerationStructureNV                          :: #type proc "system" (device: Device, pCreateInfo: ^AccelerationStructureCreateInfoNV, pAllocator: ^AllocationCallbacks, pAccelerationStructure: ^AccelerationStructureNV) -> Result
ProcCreateBuffer                                           :: #type proc "system" (device: Device, pCreateInfo: ^BufferCreateInfo, pAllocator: ^AllocationCallbacks, pBuffer: ^Buffer) -> Result
ProcCreateBufferView                                       :: #type proc "system" (device: Device, pCreateInfo: ^BufferViewCreateInfo, pAllocator: ^AllocationCallbacks, pView: ^BufferView) -> Result
ProcCreateCommandPool                                      :: #type proc "system" (device: Device, pCreateInfo: ^CommandPoolCreateInfo, pAllocator: ^AllocationCallbacks, pCommandPool: ^CommandPool) -> Result
ProcCreateComputePipelines                                 :: #type proc "system" (device: Device, pipelineCache: PipelineCache, createInfoCount: u32, pCreateInfos: [^]ComputePipelineCreateInfo, pAllocator: ^AllocationCallbacks, pPipelines: [^]Pipeline) -> Result
ProcCreateCuFunctionNVX                                    :: #type proc "system" (device: Device, pCreateInfo: ^CuFunctionCreateInfoNVX, pAllocator: ^AllocationCallbacks, pFunction: ^CuFunctionNVX) -> Result
ProcCreateCuModuleNVX                                      :: #type proc "system" (device: Device, pCreateInfo: ^CuModuleCreateInfoNVX, pAllocator: ^AllocationCallbacks, pModule: ^CuModuleNVX) -> Result
ProcCreateCudaFunctionNV                                   :: #type proc "system" (device: Device, pCreateInfo: ^CudaFunctionCreateInfoNV, pAllocator: ^AllocationCallbacks, pFunction: ^CudaFunctionNV) -> Result
ProcCreateCudaModuleNV                                     :: #type proc "system" (device: Device, pCreateInfo: ^CudaModuleCreateInfoNV, pAllocator: ^AllocationCallbacks, pModule: ^CudaModuleNV) -> Result
ProcCreateDeferredOperationKHR                             :: #type proc "system" (device: Device, pAllocator: ^AllocationCallbacks, pDeferredOperation: ^DeferredOperationKHR) -> Result
ProcCreateDescriptorPool                                   :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorPoolCreateInfo, pAllocator: ^AllocationCallbacks, pDescriptorPool: ^DescriptorPool) -> Result
ProcCreateDescriptorSetLayout                              :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorSetLayoutCreateInfo, pAllocator: ^AllocationCallbacks, pSetLayout: ^DescriptorSetLayout) -> Result
ProcCreateDescriptorUpdateTemplate                         :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorUpdateTemplateCreateInfo, pAllocator: ^AllocationCallbacks, pDescriptorUpdateTemplate: ^DescriptorUpdateTemplate) -> Result
ProcCreateDescriptorUpdateTemplateKHR                      :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorUpdateTemplateCreateInfo, pAllocator: ^AllocationCallbacks, pDescriptorUpdateTemplate: ^DescriptorUpdateTemplate) -> Result
ProcCreateEvent                                            :: #type proc "system" (device: Device, pCreateInfo: ^EventCreateInfo, pAllocator: ^AllocationCallbacks, pEvent: ^Event) -> Result
ProcCreateFence                                            :: #type proc "system" (device: Device, pCreateInfo: ^FenceCreateInfo, pAllocator: ^AllocationCallbacks, pFence: ^Fence) -> Result
ProcCreateFramebuffer                                      :: #type proc "system" (device: Device, pCreateInfo: ^FramebufferCreateInfo, pAllocator: ^AllocationCallbacks, pFramebuffer: ^Framebuffer) -> Result
ProcCreateGraphicsPipelines                                :: #type proc "system" (device: Device, pipelineCache: PipelineCache, createInfoCount: u32, pCreateInfos: [^]GraphicsPipelineCreateInfo, pAllocator: ^AllocationCallbacks, pPipelines: [^]Pipeline) -> Result
ProcCreateImage                                            :: #type proc "system" (device: Device, pCreateInfo: ^ImageCreateInfo, pAllocator: ^AllocationCallbacks, pImage: ^Image) -> Result
ProcCreateImageView                                        :: #type proc "system" (device: Device, pCreateInfo: ^ImageViewCreateInfo, pAllocator: ^AllocationCallbacks, pView: ^ImageView) -> Result
ProcCreateIndirectCommandsLayoutEXT                        :: #type proc "system" (device: Device, pCreateInfo: ^IndirectCommandsLayoutCreateInfoEXT, pAllocator: ^AllocationCallbacks, pIndirectCommandsLayout: ^IndirectCommandsLayoutEXT) -> Result
ProcCreateIndirectCommandsLayoutNV                         :: #type proc "system" (device: Device, pCreateInfo: ^IndirectCommandsLayoutCreateInfoNV, pAllocator: ^AllocationCallbacks, pIndirectCommandsLayout: ^IndirectCommandsLayoutNV) -> Result
ProcCreateIndirectExecutionSetEXT                          :: #type proc "system" (device: Device, pCreateInfo: ^IndirectExecutionSetCreateInfoEXT, pAllocator: ^AllocationCallbacks, pIndirectExecutionSet: ^IndirectExecutionSetEXT) -> Result
ProcCreateMicromapEXT                                      :: #type proc "system" (device: Device, pCreateInfo: ^MicromapCreateInfoEXT, pAllocator: ^AllocationCallbacks, pMicromap: ^MicromapEXT) -> Result
ProcCreateOpticalFlowSessionNV                             :: #type proc "system" (device: Device, pCreateInfo: ^OpticalFlowSessionCreateInfoNV, pAllocator: ^AllocationCallbacks, pSession: ^OpticalFlowSessionNV) -> Result
ProcCreatePipelineBinariesKHR                              :: #type proc "system" (device: Device, pCreateInfo: ^PipelineBinaryCreateInfoKHR, pAllocator: ^AllocationCallbacks, pBinaries: [^]PipelineBinaryHandlesInfoKHR) -> Result
ProcCreatePipelineCache                                    :: #type proc "system" (device: Device, pCreateInfo: ^PipelineCacheCreateInfo, pAllocator: ^AllocationCallbacks, pPipelineCache: ^PipelineCache) -> Result
ProcCreatePipelineLayout                                   :: #type proc "system" (device: Device, pCreateInfo: ^PipelineLayoutCreateInfo, pAllocator: ^AllocationCallbacks, pPipelineLayout: ^PipelineLayout) -> Result
ProcCreatePrivateDataSlot                                  :: #type proc "system" (device: Device, pCreateInfo: ^PrivateDataSlotCreateInfo, pAllocator: ^AllocationCallbacks, pPrivateDataSlot: ^PrivateDataSlot) -> Result
ProcCreatePrivateDataSlotEXT                               :: #type proc "system" (device: Device, pCreateInfo: ^PrivateDataSlotCreateInfo, pAllocator: ^AllocationCallbacks, pPrivateDataSlot: ^PrivateDataSlot) -> Result
ProcCreateQueryPool                                        :: #type proc "system" (device: Device, pCreateInfo: ^QueryPoolCreateInfo, pAllocator: ^AllocationCallbacks, pQueryPool: ^QueryPool) -> Result
ProcCreateRayTracingPipelinesKHR                           :: #type proc "system" (device: Device, deferredOperation: DeferredOperationKHR, pipelineCache: PipelineCache, createInfoCount: u32, pCreateInfos: [^]RayTracingPipelineCreateInfoKHR, pAllocator: ^AllocationCallbacks, pPipelines: [^]Pipeline) -> Result
ProcCreateRayTracingPipelinesNV                            :: #type proc "system" (device: Device, pipelineCache: PipelineCache, createInfoCount: u32, pCreateInfos: [^]RayTracingPipelineCreateInfoNV, pAllocator: ^AllocationCallbacks, pPipelines: [^]Pipeline) -> Result
ProcCreateRenderPass                                       :: #type proc "system" (device: Device, pCreateInfo: ^RenderPassCreateInfo, pAllocator: ^AllocationCallbacks, pRenderPass: [^]RenderPass) -> Result
ProcCreateRenderPass2                                      :: #type proc "system" (device: Device, pCreateInfo: ^RenderPassCreateInfo2, pAllocator: ^AllocationCallbacks, pRenderPass: [^]RenderPass) -> Result
ProcCreateRenderPass2KHR                                   :: #type proc "system" (device: Device, pCreateInfo: ^RenderPassCreateInfo2, pAllocator: ^AllocationCallbacks, pRenderPass: [^]RenderPass) -> Result
ProcCreateSampler                                          :: #type proc "system" (device: Device, pCreateInfo: ^SamplerCreateInfo, pAllocator: ^AllocationCallbacks, pSampler: ^Sampler) -> Result
ProcCreateSamplerYcbcrConversion                           :: #type proc "system" (device: Device, pCreateInfo: ^SamplerYcbcrConversionCreateInfo, pAllocator: ^AllocationCallbacks, pYcbcrConversion: ^SamplerYcbcrConversion) -> Result
ProcCreateSamplerYcbcrConversionKHR                        :: #type proc "system" (device: Device, pCreateInfo: ^SamplerYcbcrConversionCreateInfo, pAllocator: ^AllocationCallbacks, pYcbcrConversion: ^SamplerYcbcrConversion) -> Result
ProcCreateSemaphore                                        :: #type proc "system" (device: Device, pCreateInfo: ^SemaphoreCreateInfo, pAllocator: ^AllocationCallbacks, pSemaphore: ^Semaphore) -> Result
ProcCreateShaderModule                                     :: #type proc "system" (device: Device, pCreateInfo: ^ShaderModuleCreateInfo, pAllocator: ^AllocationCallbacks, pShaderModule: ^ShaderModule) -> Result
ProcCreateShadersEXT                                       :: #type proc "system" (device: Device, createInfoCount: u32, pCreateInfos: [^]ShaderCreateInfoEXT, pAllocator: ^AllocationCallbacks, pShaders: [^]ShaderEXT) -> Result
ProcCreateSharedSwapchainsKHR                              :: #type proc "system" (device: Device, swapchainCount: u32, pCreateInfos: [^]SwapchainCreateInfoKHR, pAllocator: ^AllocationCallbacks, pSwapchains: [^]SwapchainKHR) -> Result
ProcCreateSwapchainKHR                                     :: #type proc "system" (device: Device, pCreateInfo: ^SwapchainCreateInfoKHR, pAllocator: ^AllocationCallbacks, pSwapchain: ^SwapchainKHR) -> Result
ProcCreateValidationCacheEXT                               :: #type proc "system" (device: Device, pCreateInfo: ^ValidationCacheCreateInfoEXT, pAllocator: ^AllocationCallbacks, pValidationCache: ^ValidationCacheEXT) -> Result
ProcCreateVideoSessionKHR                                  :: #type proc "system" (device: Device, pCreateInfo: ^VideoSessionCreateInfoKHR, pAllocator: ^AllocationCallbacks, pVideoSession: ^VideoSessionKHR) -> Result
ProcCreateVideoSessionParametersKHR                        :: #type proc "system" (device: Device, pCreateInfo: ^VideoSessionParametersCreateInfoKHR, pAllocator: ^AllocationCallbacks, pVideoSessionParameters: [^]VideoSessionParametersKHR) -> Result
ProcDebugMarkerSetObjectNameEXT                            :: #type proc "system" (device: Device, pNameInfo: ^DebugMarkerObjectNameInfoEXT) -> Result
ProcDebugMarkerSetObjectTagEXT                             :: #type proc "system" (device: Device, pTagInfo: ^DebugMarkerObjectTagInfoEXT) -> Result
ProcDeferredOperationJoinKHR                               :: #type proc "system" (device: Device, operation: DeferredOperationKHR) -> Result
ProcDestroyAccelerationStructureKHR                        :: #type proc "system" (device: Device, accelerationStructure: AccelerationStructureKHR, pAllocator: ^AllocationCallbacks)
ProcDestroyAccelerationStructureNV                         :: #type proc "system" (device: Device, accelerationStructure: AccelerationStructureNV, pAllocator: ^AllocationCallbacks)
ProcDestroyBuffer                                          :: #type proc "system" (device: Device, buffer: Buffer, pAllocator: ^AllocationCallbacks)
ProcDestroyBufferView                                      :: #type proc "system" (device: Device, bufferView: BufferView, pAllocator: ^AllocationCallbacks)
ProcDestroyCommandPool                                     :: #type proc "system" (device: Device, commandPool: CommandPool, pAllocator: ^AllocationCallbacks)
ProcDestroyCuFunctionNVX                                   :: #type proc "system" (device: Device, function: CuFunctionNVX, pAllocator: ^AllocationCallbacks)
ProcDestroyCuModuleNVX                                     :: #type proc "system" (device: Device, module: CuModuleNVX, pAllocator: ^AllocationCallbacks)
ProcDestroyCudaFunctionNV                                  :: #type proc "system" (device: Device, function: CudaFunctionNV, pAllocator: ^AllocationCallbacks)
ProcDestroyCudaModuleNV                                    :: #type proc "system" (device: Device, module: CudaModuleNV, pAllocator: ^AllocationCallbacks)
ProcDestroyDeferredOperationKHR                            :: #type proc "system" (device: Device, operation: DeferredOperationKHR, pAllocator: ^AllocationCallbacks)
ProcDestroyDescriptorPool                                  :: #type proc "system" (device: Device, descriptorPool: DescriptorPool, pAllocator: ^AllocationCallbacks)
ProcDestroyDescriptorSetLayout                             :: #type proc "system" (device: Device, descriptorSetLayout: DescriptorSetLayout, pAllocator: ^AllocationCallbacks)
ProcDestroyDescriptorUpdateTemplate                        :: #type proc "system" (device: Device, descriptorUpdateTemplate: DescriptorUpdateTemplate, pAllocator: ^AllocationCallbacks)
ProcDestroyDescriptorUpdateTemplateKHR                     :: #type proc "system" (device: Device, descriptorUpdateTemplate: DescriptorUpdateTemplate, pAllocator: ^AllocationCallbacks)
ProcDestroyDevice                                          :: #type proc "system" (device: Device, pAllocator: ^AllocationCallbacks)
ProcDestroyEvent                                           :: #type proc "system" (device: Device, event: Event, pAllocator: ^AllocationCallbacks)
ProcDestroyFence                                           :: #type proc "system" (device: Device, fence: Fence, pAllocator: ^AllocationCallbacks)
ProcDestroyFramebuffer                                     :: #type proc "system" (device: Device, framebuffer: Framebuffer, pAllocator: ^AllocationCallbacks)
ProcDestroyImage                                           :: #type proc "system" (device: Device, image: Image, pAllocator: ^AllocationCallbacks)
ProcDestroyImageView                                       :: #type proc "system" (device: Device, imageView: ImageView, pAllocator: ^AllocationCallbacks)
ProcDestroyIndirectCommandsLayoutEXT                       :: #type proc "system" (device: Device, indirectCommandsLayout: IndirectCommandsLayoutEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyIndirectCommandsLayoutNV                        :: #type proc "system" (device: Device, indirectCommandsLayout: IndirectCommandsLayoutNV, pAllocator: ^AllocationCallbacks)
ProcDestroyIndirectExecutionSetEXT                         :: #type proc "system" (device: Device, indirectExecutionSet: IndirectExecutionSetEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyMicromapEXT                                     :: #type proc "system" (device: Device, micromap: MicromapEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyOpticalFlowSessionNV                            :: #type proc "system" (device: Device, session: OpticalFlowSessionNV, pAllocator: ^AllocationCallbacks)
ProcDestroyPipeline                                        :: #type proc "system" (device: Device, pipeline: Pipeline, pAllocator: ^AllocationCallbacks)
ProcDestroyPipelineBinaryKHR                               :: #type proc "system" (device: Device, pipelineBinary: PipelineBinaryKHR, pAllocator: ^AllocationCallbacks)
ProcDestroyPipelineCache                                   :: #type proc "system" (device: Device, pipelineCache: PipelineCache, pAllocator: ^AllocationCallbacks)
ProcDestroyPipelineLayout                                  :: #type proc "system" (device: Device, pipelineLayout: PipelineLayout, pAllocator: ^AllocationCallbacks)
ProcDestroyPrivateDataSlot                                 :: #type proc "system" (device: Device, privateDataSlot: PrivateDataSlot, pAllocator: ^AllocationCallbacks)
ProcDestroyPrivateDataSlotEXT                              :: #type proc "system" (device: Device, privateDataSlot: PrivateDataSlot, pAllocator: ^AllocationCallbacks)
ProcDestroyQueryPool                                       :: #type proc "system" (device: Device, queryPool: QueryPool, pAllocator: ^AllocationCallbacks)
ProcDestroyRenderPass                                      :: #type proc "system" (device: Device, renderPass: RenderPass, pAllocator: ^AllocationCallbacks)
ProcDestroySampler                                         :: #type proc "system" (device: Device, sampler: Sampler, pAllocator: ^AllocationCallbacks)
ProcDestroySamplerYcbcrConversion                          :: #type proc "system" (device: Device, ycbcrConversion: SamplerYcbcrConversion, pAllocator: ^AllocationCallbacks)
ProcDestroySamplerYcbcrConversionKHR                       :: #type proc "system" (device: Device, ycbcrConversion: SamplerYcbcrConversion, pAllocator: ^AllocationCallbacks)
ProcDestroySemaphore                                       :: #type proc "system" (device: Device, semaphore: Semaphore, pAllocator: ^AllocationCallbacks)
ProcDestroyShaderEXT                                       :: #type proc "system" (device: Device, shader: ShaderEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyShaderModule                                    :: #type proc "system" (device: Device, shaderModule: ShaderModule, pAllocator: ^AllocationCallbacks)
ProcDestroySwapchainKHR                                    :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pAllocator: ^AllocationCallbacks)
ProcDestroyValidationCacheEXT                              :: #type proc "system" (device: Device, validationCache: ValidationCacheEXT, pAllocator: ^AllocationCallbacks)
ProcDestroyVideoSessionKHR                                 :: #type proc "system" (device: Device, videoSession: VideoSessionKHR, pAllocator: ^AllocationCallbacks)
ProcDestroyVideoSessionParametersKHR                       :: #type proc "system" (device: Device, videoSessionParameters: VideoSessionParametersKHR, pAllocator: ^AllocationCallbacks)
ProcDeviceWaitIdle                                         :: #type proc "system" (device: Device) -> Result
ProcDisplayPowerControlEXT                                 :: #type proc "system" (device: Device, display: DisplayKHR, pDisplayPowerInfo: ^DisplayPowerInfoEXT) -> Result
ProcEndCommandBuffer                                       :: #type proc "system" (commandBuffer: CommandBuffer) -> Result
ProcExportMetalObjectsEXT                                  :: #type proc "system" (device: Device, pMetalObjectsInfo: ^ExportMetalObjectsInfoEXT)
ProcFlushMappedMemoryRanges                                :: #type proc "system" (device: Device, memoryRangeCount: u32, pMemoryRanges: [^]MappedMemoryRange) -> Result
ProcFreeCommandBuffers                                     :: #type proc "system" (device: Device, commandPool: CommandPool, commandBufferCount: u32, pCommandBuffers: [^]CommandBuffer)
ProcFreeDescriptorSets                                     :: #type proc "system" (device: Device, descriptorPool: DescriptorPool, descriptorSetCount: u32, pDescriptorSets: [^]DescriptorSet) -> Result
ProcFreeMemory                                             :: #type proc "system" (device: Device, memory: DeviceMemory, pAllocator: ^AllocationCallbacks)
ProcGetAccelerationStructureBuildSizesKHR                  :: #type proc "system" (device: Device, buildType: AccelerationStructureBuildTypeKHR, pBuildInfo: ^AccelerationStructureBuildGeometryInfoKHR, pMaxPrimitiveCounts: [^]u32, pSizeInfo: ^AccelerationStructureBuildSizesInfoKHR)
ProcGetAccelerationStructureDeviceAddressKHR               :: #type proc "system" (device: Device, pInfo: ^AccelerationStructureDeviceAddressInfoKHR) -> DeviceAddress
ProcGetAccelerationStructureHandleNV                       :: #type proc "system" (device: Device, accelerationStructure: AccelerationStructureNV, dataSize: int, pData: rawptr) -> Result
ProcGetAccelerationStructureMemoryRequirementsNV           :: #type proc "system" (device: Device, pInfo: ^AccelerationStructureMemoryRequirementsInfoNV, pMemoryRequirements: [^]MemoryRequirements2KHR)
ProcGetAccelerationStructureOpaqueCaptureDescriptorDataEXT :: #type proc "system" (device: Device, pInfo: ^AccelerationStructureCaptureDescriptorDataInfoEXT, pData: rawptr) -> Result
ProcGetBufferDeviceAddress                                 :: #type proc "system" (device: Device, pInfo: ^BufferDeviceAddressInfo) -> DeviceAddress
ProcGetBufferDeviceAddressEXT                              :: #type proc "system" (device: Device, pInfo: ^BufferDeviceAddressInfo) -> DeviceAddress
ProcGetBufferDeviceAddressKHR                              :: #type proc "system" (device: Device, pInfo: ^BufferDeviceAddressInfo) -> DeviceAddress
ProcGetBufferMemoryRequirements                            :: #type proc "system" (device: Device, buffer: Buffer, pMemoryRequirements: [^]MemoryRequirements)
ProcGetBufferMemoryRequirements2                           :: #type proc "system" (device: Device, pInfo: ^BufferMemoryRequirementsInfo2, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetBufferMemoryRequirements2KHR                        :: #type proc "system" (device: Device, pInfo: ^BufferMemoryRequirementsInfo2, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetBufferOpaqueCaptureAddress                          :: #type proc "system" (device: Device, pInfo: ^BufferDeviceAddressInfo) -> u64
ProcGetBufferOpaqueCaptureAddressKHR                       :: #type proc "system" (device: Device, pInfo: ^BufferDeviceAddressInfo) -> u64
ProcGetBufferOpaqueCaptureDescriptorDataEXT                :: #type proc "system" (device: Device, pInfo: ^BufferCaptureDescriptorDataInfoEXT, pData: rawptr) -> Result
ProcGetCalibratedTimestampsEXT                             :: #type proc "system" (device: Device, timestampCount: u32, pTimestampInfos: [^]CalibratedTimestampInfoKHR, pTimestamps: [^]u64, pMaxDeviation: ^u64) -> Result
ProcGetCalibratedTimestampsKHR                             :: #type proc "system" (device: Device, timestampCount: u32, pTimestampInfos: [^]CalibratedTimestampInfoKHR, pTimestamps: [^]u64, pMaxDeviation: ^u64) -> Result
ProcGetCudaModuleCacheNV                                   :: #type proc "system" (device: Device, module: CudaModuleNV, pCacheSize: ^int, pCacheData: rawptr) -> Result
ProcGetDeferredOperationMaxConcurrencyKHR                  :: #type proc "system" (device: Device, operation: DeferredOperationKHR) -> u32
ProcGetDeferredOperationResultKHR                          :: #type proc "system" (device: Device, operation: DeferredOperationKHR) -> Result
ProcGetDescriptorEXT                                       :: #type proc "system" (device: Device, pDescriptorInfo: ^DescriptorGetInfoEXT, dataSize: int, pDescriptor: rawptr)
ProcGetDescriptorSetHostMappingVALVE                       :: #type proc "system" (device: Device, descriptorSet: DescriptorSet, ppData: ^rawptr)
ProcGetDescriptorSetLayoutBindingOffsetEXT                 :: #type proc "system" (device: Device, layout: DescriptorSetLayout, binding: u32, pOffset: ^DeviceSize)
ProcGetDescriptorSetLayoutHostMappingInfoVALVE             :: #type proc "system" (device: Device, pBindingReference: ^DescriptorSetBindingReferenceVALVE, pHostMapping: ^DescriptorSetLayoutHostMappingInfoVALVE)
ProcGetDescriptorSetLayoutSizeEXT                          :: #type proc "system" (device: Device, layout: DescriptorSetLayout, pLayoutSizeInBytes: [^]DeviceSize)
ProcGetDescriptorSetLayoutSupport                          :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorSetLayoutCreateInfo, pSupport: ^DescriptorSetLayoutSupport)
ProcGetDescriptorSetLayoutSupportKHR                       :: #type proc "system" (device: Device, pCreateInfo: ^DescriptorSetLayoutCreateInfo, pSupport: ^DescriptorSetLayoutSupport)
ProcGetDeviceAccelerationStructureCompatibilityKHR         :: #type proc "system" (device: Device, pVersionInfo: ^AccelerationStructureVersionInfoKHR, pCompatibility: ^AccelerationStructureCompatibilityKHR)
ProcGetDeviceBufferMemoryRequirements                      :: #type proc "system" (device: Device, pInfo: ^DeviceBufferMemoryRequirements, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetDeviceBufferMemoryRequirementsKHR                   :: #type proc "system" (device: Device, pInfo: ^DeviceBufferMemoryRequirements, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetDeviceFaultInfoEXT                                  :: #type proc "system" (device: Device, pFaultCounts: [^]DeviceFaultCountsEXT, pFaultInfo: ^DeviceFaultInfoEXT) -> Result
ProcGetDeviceGroupPeerMemoryFeatures                       :: #type proc "system" (device: Device, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: [^]PeerMemoryFeatureFlags)
ProcGetDeviceGroupPeerMemoryFeaturesKHR                    :: #type proc "system" (device: Device, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: [^]PeerMemoryFeatureFlags)
ProcGetDeviceGroupPresentCapabilitiesKHR                   :: #type proc "system" (device: Device, pDeviceGroupPresentCapabilities: [^]DeviceGroupPresentCapabilitiesKHR) -> Result
ProcGetDeviceGroupSurfacePresentModes2EXT                  :: #type proc "system" (device: Device, pSurfaceInfo: ^PhysicalDeviceSurfaceInfo2KHR, pModes: [^]DeviceGroupPresentModeFlagsKHR) -> Result
ProcGetDeviceGroupSurfacePresentModesKHR                   :: #type proc "system" (device: Device, surface: SurfaceKHR, pModes: [^]DeviceGroupPresentModeFlagsKHR) -> Result
ProcGetDeviceImageMemoryRequirements                       :: #type proc "system" (device: Device, pInfo: ^DeviceImageMemoryRequirements, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetDeviceImageMemoryRequirementsKHR                    :: #type proc "system" (device: Device, pInfo: ^DeviceImageMemoryRequirements, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetDeviceImageSparseMemoryRequirements                 :: #type proc "system" (device: Device, pInfo: ^DeviceImageMemoryRequirements, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: [^]SparseImageMemoryRequirements2)
ProcGetDeviceImageSparseMemoryRequirementsKHR              :: #type proc "system" (device: Device, pInfo: ^DeviceImageMemoryRequirements, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: [^]SparseImageMemoryRequirements2)
ProcGetDeviceImageSubresourceLayoutKHR                     :: #type proc "system" (device: Device, pInfo: ^DeviceImageSubresourceInfoKHR, pLayout: ^SubresourceLayout2KHR)
ProcGetDeviceMemoryCommitment                              :: #type proc "system" (device: Device, memory: DeviceMemory, pCommittedMemoryInBytes: [^]DeviceSize)
ProcGetDeviceMemoryOpaqueCaptureAddress                    :: #type proc "system" (device: Device, pInfo: ^DeviceMemoryOpaqueCaptureAddressInfo) -> u64
ProcGetDeviceMemoryOpaqueCaptureAddressKHR                 :: #type proc "system" (device: Device, pInfo: ^DeviceMemoryOpaqueCaptureAddressInfo) -> u64
ProcGetDeviceMicromapCompatibilityEXT                      :: #type proc "system" (device: Device, pVersionInfo: ^MicromapVersionInfoEXT, pCompatibility: ^AccelerationStructureCompatibilityKHR)
ProcGetDeviceProcAddr                                      :: #type proc "system" (device: Device, pName: cstring) -> ProcVoidFunction
ProcGetDeviceQueue                                         :: #type proc "system" (device: Device, queueFamilyIndex: u32, queueIndex: u32, pQueue: ^Queue)
ProcGetDeviceQueue2                                        :: #type proc "system" (device: Device, pQueueInfo: ^DeviceQueueInfo2, pQueue: ^Queue)
ProcGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI          :: #type proc "system" (device: Device, renderpass: RenderPass, pMaxWorkgroupSize: ^Extent2D) -> Result
ProcGetDynamicRenderingTilePropertiesQCOM                  :: #type proc "system" (device: Device, pRenderingInfo: ^RenderingInfo, pProperties: [^]TilePropertiesQCOM) -> Result
ProcGetEncodedVideoSessionParametersKHR                    :: #type proc "system" (device: Device, pVideoSessionParametersInfo: ^VideoEncodeSessionParametersGetInfoKHR, pFeedbackInfo: ^VideoEncodeSessionParametersFeedbackInfoKHR, pDataSize: ^int, pData: rawptr) -> Result
ProcGetEventStatus                                         :: #type proc "system" (device: Device, event: Event) -> Result
ProcGetFenceFdKHR                                          :: #type proc "system" (device: Device, pGetFdInfo: ^FenceGetFdInfoKHR, pFd: ^c.int) -> Result
ProcGetFenceStatus                                         :: #type proc "system" (device: Device, fence: Fence) -> Result
ProcGetFenceWin32HandleKHR                                 :: #type proc "system" (device: Device, pGetWin32HandleInfo: ^FenceGetWin32HandleInfoKHR, pHandle: ^HANDLE) -> Result
ProcGetFramebufferTilePropertiesQCOM                       :: #type proc "system" (device: Device, framebuffer: Framebuffer, pPropertiesCount: ^u32, pProperties: [^]TilePropertiesQCOM) -> Result
ProcGetGeneratedCommandsMemoryRequirementsEXT              :: #type proc "system" (device: Device, pInfo: ^GeneratedCommandsMemoryRequirementsInfoEXT, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetGeneratedCommandsMemoryRequirementsNV               :: #type proc "system" (device: Device, pInfo: ^GeneratedCommandsMemoryRequirementsInfoNV, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetImageDrmFormatModifierPropertiesEXT                 :: #type proc "system" (device: Device, image: Image, pProperties: [^]ImageDrmFormatModifierPropertiesEXT) -> Result
ProcGetImageMemoryRequirements                             :: #type proc "system" (device: Device, image: Image, pMemoryRequirements: [^]MemoryRequirements)
ProcGetImageMemoryRequirements2                            :: #type proc "system" (device: Device, pInfo: ^ImageMemoryRequirementsInfo2, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetImageMemoryRequirements2KHR                         :: #type proc "system" (device: Device, pInfo: ^ImageMemoryRequirementsInfo2, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetImageOpaqueCaptureDescriptorDataEXT                 :: #type proc "system" (device: Device, pInfo: ^ImageCaptureDescriptorDataInfoEXT, pData: rawptr) -> Result
ProcGetImageSparseMemoryRequirements                       :: #type proc "system" (device: Device, image: Image, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: [^]SparseImageMemoryRequirements)
ProcGetImageSparseMemoryRequirements2                      :: #type proc "system" (device: Device, pInfo: ^ImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: [^]SparseImageMemoryRequirements2)
ProcGetImageSparseMemoryRequirements2KHR                   :: #type proc "system" (device: Device, pInfo: ^ImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: ^u32, pSparseMemoryRequirements: [^]SparseImageMemoryRequirements2)
ProcGetImageSubresourceLayout                              :: #type proc "system" (device: Device, image: Image, pSubresource: ^ImageSubresource, pLayout: ^SubresourceLayout)
ProcGetImageSubresourceLayout2EXT                          :: #type proc "system" (device: Device, image: Image, pSubresource: ^ImageSubresource2KHR, pLayout: ^SubresourceLayout2KHR)
ProcGetImageSubresourceLayout2KHR                          :: #type proc "system" (device: Device, image: Image, pSubresource: ^ImageSubresource2KHR, pLayout: ^SubresourceLayout2KHR)
ProcGetImageViewAddressNVX                                 :: #type proc "system" (device: Device, imageView: ImageView, pProperties: [^]ImageViewAddressPropertiesNVX) -> Result
ProcGetImageViewHandleNVX                                  :: #type proc "system" (device: Device, pInfo: ^ImageViewHandleInfoNVX) -> u32
ProcGetImageViewOpaqueCaptureDescriptorDataEXT             :: #type proc "system" (device: Device, pInfo: ^ImageViewCaptureDescriptorDataInfoEXT, pData: rawptr) -> Result
ProcGetLatencyTimingsNV                                    :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pLatencyMarkerInfo: ^GetLatencyMarkerInfoNV)
ProcGetMemoryFdKHR                                         :: #type proc "system" (device: Device, pGetFdInfo: ^MemoryGetFdInfoKHR, pFd: ^c.int) -> Result
ProcGetMemoryFdPropertiesKHR                               :: #type proc "system" (device: Device, handleType: ExternalMemoryHandleTypeFlags, fd: c.int, pMemoryFdProperties: [^]MemoryFdPropertiesKHR) -> Result
ProcGetMemoryHostPointerPropertiesEXT                      :: #type proc "system" (device: Device, handleType: ExternalMemoryHandleTypeFlags, pHostPointer: rawptr, pMemoryHostPointerProperties: [^]MemoryHostPointerPropertiesEXT) -> Result
ProcGetMemoryRemoteAddressNV                               :: #type proc "system" (device: Device, pMemoryGetRemoteAddressInfo: ^MemoryGetRemoteAddressInfoNV, pAddress: [^]RemoteAddressNV) -> Result
ProcGetMemoryWin32HandleKHR                                :: #type proc "system" (device: Device, pGetWin32HandleInfo: ^MemoryGetWin32HandleInfoKHR, pHandle: ^HANDLE) -> Result
ProcGetMemoryWin32HandleNV                                 :: #type proc "system" (device: Device, memory: DeviceMemory, handleType: ExternalMemoryHandleTypeFlagsNV, pHandle: ^HANDLE) -> Result
ProcGetMemoryWin32HandlePropertiesKHR                      :: #type proc "system" (device: Device, handleType: ExternalMemoryHandleTypeFlags, handle: HANDLE, pMemoryWin32HandleProperties: [^]MemoryWin32HandlePropertiesKHR) -> Result
ProcGetMicromapBuildSizesEXT                               :: #type proc "system" (device: Device, buildType: AccelerationStructureBuildTypeKHR, pBuildInfo: ^MicromapBuildInfoEXT, pSizeInfo: ^MicromapBuildSizesInfoEXT)
ProcGetPastPresentationTimingGOOGLE                        :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pPresentationTimingCount: ^u32, pPresentationTimings: [^]PastPresentationTimingGOOGLE) -> Result
ProcGetPerformanceParameterINTEL                           :: #type proc "system" (device: Device, parameter: PerformanceParameterTypeINTEL, pValue: ^PerformanceValueINTEL) -> Result
ProcGetPipelineBinaryDataKHR                               :: #type proc "system" (device: Device, pInfo: ^PipelineBinaryDataInfoKHR, pPipelineBinaryKey: ^PipelineBinaryKeyKHR, pPipelineBinaryDataSize: ^int, pPipelineBinaryData: rawptr) -> Result
ProcGetPipelineCacheData                                   :: #type proc "system" (device: Device, pipelineCache: PipelineCache, pDataSize: ^int, pData: rawptr) -> Result
ProcGetPipelineExecutableInternalRepresentationsKHR        :: #type proc "system" (device: Device, pExecutableInfo: ^PipelineExecutableInfoKHR, pInternalRepresentationCount: ^u32, pInternalRepresentations: [^]PipelineExecutableInternalRepresentationKHR) -> Result
ProcGetPipelineExecutablePropertiesKHR                     :: #type proc "system" (device: Device, pPipelineInfo: ^PipelineInfoKHR, pExecutableCount: ^u32, pProperties: [^]PipelineExecutablePropertiesKHR) -> Result
ProcGetPipelineExecutableStatisticsKHR                     :: #type proc "system" (device: Device, pExecutableInfo: ^PipelineExecutableInfoKHR, pStatisticCount: ^u32, pStatistics: [^]PipelineExecutableStatisticKHR) -> Result
ProcGetPipelineIndirectDeviceAddressNV                     :: #type proc "system" (device: Device, pInfo: ^PipelineIndirectDeviceAddressInfoNV) -> DeviceAddress
ProcGetPipelineIndirectMemoryRequirementsNV                :: #type proc "system" (device: Device, pCreateInfo: ^ComputePipelineCreateInfo, pMemoryRequirements: [^]MemoryRequirements2)
ProcGetPipelineKeyKHR                                      :: #type proc "system" (device: Device, pPipelineCreateInfo: ^PipelineCreateInfoKHR, pPipelineKey: ^PipelineBinaryKeyKHR) -> Result
ProcGetPipelinePropertiesEXT                               :: #type proc "system" (device: Device, pPipelineInfo: ^PipelineInfoEXT, pPipelineProperties: [^]BaseOutStructure) -> Result
ProcGetPrivateData                                         :: #type proc "system" (device: Device, objectType: ObjectType, objectHandle: u64, privateDataSlot: PrivateDataSlot, pData: ^u64)
ProcGetPrivateDataEXT                                      :: #type proc "system" (device: Device, objectType: ObjectType, objectHandle: u64, privateDataSlot: PrivateDataSlot, pData: ^u64)
ProcGetQueryPoolResults                                    :: #type proc "system" (device: Device, queryPool: QueryPool, firstQuery: u32, queryCount: u32, dataSize: int, pData: rawptr, stride: DeviceSize, flags: QueryResultFlags) -> Result
ProcGetQueueCheckpointData2NV                              :: #type proc "system" (queue: Queue, pCheckpointDataCount: ^u32, pCheckpointData: ^CheckpointData2NV)
ProcGetQueueCheckpointDataNV                               :: #type proc "system" (queue: Queue, pCheckpointDataCount: ^u32, pCheckpointData: ^CheckpointDataNV)
ProcGetRayTracingCaptureReplayShaderGroupHandlesKHR        :: #type proc "system" (device: Device, pipeline: Pipeline, firstGroup: u32, groupCount: u32, dataSize: int, pData: rawptr) -> Result
ProcGetRayTracingShaderGroupHandlesKHR                     :: #type proc "system" (device: Device, pipeline: Pipeline, firstGroup: u32, groupCount: u32, dataSize: int, pData: rawptr) -> Result
ProcGetRayTracingShaderGroupHandlesNV                      :: #type proc "system" (device: Device, pipeline: Pipeline, firstGroup: u32, groupCount: u32, dataSize: int, pData: rawptr) -> Result
ProcGetRayTracingShaderGroupStackSizeKHR                   :: #type proc "system" (device: Device, pipeline: Pipeline, group: u32, groupShader: ShaderGroupShaderKHR) -> DeviceSize
ProcGetRefreshCycleDurationGOOGLE                          :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pDisplayTimingProperties: [^]RefreshCycleDurationGOOGLE) -> Result
ProcGetRenderAreaGranularity                               :: #type proc "system" (device: Device, renderPass: RenderPass, pGranularity: ^Extent2D)
ProcGetRenderingAreaGranularityKHR                         :: #type proc "system" (device: Device, pRenderingAreaInfo: ^RenderingAreaInfoKHR, pGranularity: ^Extent2D)
ProcGetSamplerOpaqueCaptureDescriptorDataEXT               :: #type proc "system" (device: Device, pInfo: ^SamplerCaptureDescriptorDataInfoEXT, pData: rawptr) -> Result
ProcGetSemaphoreCounterValue                               :: #type proc "system" (device: Device, semaphore: Semaphore, pValue: ^u64) -> Result
ProcGetSemaphoreCounterValueKHR                            :: #type proc "system" (device: Device, semaphore: Semaphore, pValue: ^u64) -> Result
ProcGetSemaphoreFdKHR                                      :: #type proc "system" (device: Device, pGetFdInfo: ^SemaphoreGetFdInfoKHR, pFd: ^c.int) -> Result
ProcGetSemaphoreWin32HandleKHR                             :: #type proc "system" (device: Device, pGetWin32HandleInfo: ^SemaphoreGetWin32HandleInfoKHR, pHandle: ^HANDLE) -> Result
ProcGetShaderBinaryDataEXT                                 :: #type proc "system" (device: Device, shader: ShaderEXT, pDataSize: ^int, pData: rawptr) -> Result
ProcGetShaderInfoAMD                                       :: #type proc "system" (device: Device, pipeline: Pipeline, shaderStage: ShaderStageFlags, infoType: ShaderInfoTypeAMD, pInfoSize: ^int, pInfo: rawptr) -> Result
ProcGetShaderModuleCreateInfoIdentifierEXT                 :: #type proc "system" (device: Device, pCreateInfo: ^ShaderModuleCreateInfo, pIdentifier: ^ShaderModuleIdentifierEXT)
ProcGetShaderModuleIdentifierEXT                           :: #type proc "system" (device: Device, shaderModule: ShaderModule, pIdentifier: ^ShaderModuleIdentifierEXT)
ProcGetSwapchainCounterEXT                                 :: #type proc "system" (device: Device, swapchain: SwapchainKHR, counter: SurfaceCounterFlagsEXT, pCounterValue: ^u64) -> Result
ProcGetSwapchainImagesKHR                                  :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pSwapchainImageCount: ^u32, pSwapchainImages: [^]Image) -> Result
ProcGetSwapchainStatusKHR                                  :: #type proc "system" (device: Device, swapchain: SwapchainKHR) -> Result
ProcGetValidationCacheDataEXT                              :: #type proc "system" (device: Device, validationCache: ValidationCacheEXT, pDataSize: ^int, pData: rawptr) -> Result
ProcGetVideoSessionMemoryRequirementsKHR                   :: #type proc "system" (device: Device, videoSession: VideoSessionKHR, pMemoryRequirementsCount: ^u32, pMemoryRequirements: [^]VideoSessionMemoryRequirementsKHR) -> Result
ProcImportFenceFdKHR                                       :: #type proc "system" (device: Device, pImportFenceFdInfo: ^ImportFenceFdInfoKHR) -> Result
ProcImportFenceWin32HandleKHR                              :: #type proc "system" (device: Device, pImportFenceWin32HandleInfo: ^ImportFenceWin32HandleInfoKHR) -> Result
ProcImportSemaphoreFdKHR                                   :: #type proc "system" (device: Device, pImportSemaphoreFdInfo: ^ImportSemaphoreFdInfoKHR) -> Result
ProcImportSemaphoreWin32HandleKHR                          :: #type proc "system" (device: Device, pImportSemaphoreWin32HandleInfo: ^ImportSemaphoreWin32HandleInfoKHR) -> Result
ProcInitializePerformanceApiINTEL                          :: #type proc "system" (device: Device, pInitializeInfo: ^InitializePerformanceApiInfoINTEL) -> Result
ProcInvalidateMappedMemoryRanges                           :: #type proc "system" (device: Device, memoryRangeCount: u32, pMemoryRanges: [^]MappedMemoryRange) -> Result
ProcLatencySleepNV                                         :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pSleepInfo: ^LatencySleepInfoNV) -> Result
ProcMapMemory                                              :: #type proc "system" (device: Device, memory: DeviceMemory, offset: DeviceSize, size: DeviceSize, flags: MemoryMapFlags, ppData: ^rawptr) -> Result
ProcMapMemory2KHR                                          :: #type proc "system" (device: Device, pMemoryMapInfo: ^MemoryMapInfoKHR, ppData: ^rawptr) -> Result
ProcMergePipelineCaches                                    :: #type proc "system" (device: Device, dstCache: PipelineCache, srcCacheCount: u32, pSrcCaches: [^]PipelineCache) -> Result
ProcMergeValidationCachesEXT                               :: #type proc "system" (device: Device, dstCache: ValidationCacheEXT, srcCacheCount: u32, pSrcCaches: [^]ValidationCacheEXT) -> Result
ProcQueueBeginDebugUtilsLabelEXT                           :: #type proc "system" (queue: Queue, pLabelInfo: ^DebugUtilsLabelEXT)
ProcQueueBindSparse                                        :: #type proc "system" (queue: Queue, bindInfoCount: u32, pBindInfo: ^BindSparseInfo, fence: Fence) -> Result
ProcQueueEndDebugUtilsLabelEXT                             :: #type proc "system" (queue: Queue)
ProcQueueInsertDebugUtilsLabelEXT                          :: #type proc "system" (queue: Queue, pLabelInfo: ^DebugUtilsLabelEXT)
ProcQueueNotifyOutOfBandNV                                 :: #type proc "system" (queue: Queue, pQueueTypeInfo: ^OutOfBandQueueTypeInfoNV)
ProcQueuePresentKHR                                        :: #type proc "system" (queue: Queue, pPresentInfo: ^PresentInfoKHR) -> Result
ProcQueueSetPerformanceConfigurationINTEL                  :: #type proc "system" (queue: Queue, configuration: PerformanceConfigurationINTEL) -> Result
ProcQueueSubmit                                            :: #type proc "system" (queue: Queue, submitCount: u32, pSubmits: [^]SubmitInfo, fence: Fence) -> Result
ProcQueueSubmit2                                           :: #type proc "system" (queue: Queue, submitCount: u32, pSubmits: [^]SubmitInfo2, fence: Fence) -> Result
ProcQueueSubmit2KHR                                        :: #type proc "system" (queue: Queue, submitCount: u32, pSubmits: [^]SubmitInfo2, fence: Fence) -> Result
ProcQueueWaitIdle                                          :: #type proc "system" (queue: Queue) -> Result
ProcRegisterDeviceEventEXT                                 :: #type proc "system" (device: Device, pDeviceEventInfo: ^DeviceEventInfoEXT, pAllocator: ^AllocationCallbacks, pFence: ^Fence) -> Result
ProcRegisterDisplayEventEXT                                :: #type proc "system" (device: Device, display: DisplayKHR, pDisplayEventInfo: ^DisplayEventInfoEXT, pAllocator: ^AllocationCallbacks, pFence: ^Fence) -> Result
ProcReleaseCapturedPipelineDataKHR                         :: #type proc "system" (device: Device, pInfo: ^ReleaseCapturedPipelineDataInfoKHR, pAllocator: ^AllocationCallbacks) -> Result
ProcReleaseFullScreenExclusiveModeEXT                      :: #type proc "system" (device: Device, swapchain: SwapchainKHR) -> Result
ProcReleasePerformanceConfigurationINTEL                   :: #type proc "system" (device: Device, configuration: PerformanceConfigurationINTEL) -> Result
ProcReleaseProfilingLockKHR                                :: #type proc "system" (device: Device)
ProcReleaseSwapchainImagesEXT                              :: #type proc "system" (device: Device, pReleaseInfo: ^ReleaseSwapchainImagesInfoEXT) -> Result
ProcResetCommandBuffer                                     :: #type proc "system" (commandBuffer: CommandBuffer, flags: CommandBufferResetFlags) -> Result
ProcResetCommandPool                                       :: #type proc "system" (device: Device, commandPool: CommandPool, flags: CommandPoolResetFlags) -> Result
ProcResetDescriptorPool                                    :: #type proc "system" (device: Device, descriptorPool: DescriptorPool, flags: DescriptorPoolResetFlags) -> Result
ProcResetEvent                                             :: #type proc "system" (device: Device, event: Event) -> Result
ProcResetFences                                            :: #type proc "system" (device: Device, fenceCount: u32, pFences: [^]Fence) -> Result
ProcResetQueryPool                                         :: #type proc "system" (device: Device, queryPool: QueryPool, firstQuery: u32, queryCount: u32)
ProcResetQueryPoolEXT                                      :: #type proc "system" (device: Device, queryPool: QueryPool, firstQuery: u32, queryCount: u32)
ProcSetDebugUtilsObjectNameEXT                             :: #type proc "system" (device: Device, pNameInfo: ^DebugUtilsObjectNameInfoEXT) -> Result
ProcSetDebugUtilsObjectTagEXT                              :: #type proc "system" (device: Device, pTagInfo: ^DebugUtilsObjectTagInfoEXT) -> Result
ProcSetDeviceMemoryPriorityEXT                             :: #type proc "system" (device: Device, memory: DeviceMemory, priority: f32)
ProcSetEvent                                               :: #type proc "system" (device: Device, event: Event) -> Result
ProcSetHdrMetadataEXT                                      :: #type proc "system" (device: Device, swapchainCount: u32, pSwapchains: [^]SwapchainKHR, pMetadata: ^HdrMetadataEXT)
ProcSetLatencyMarkerNV                                     :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pLatencyMarkerInfo: ^SetLatencyMarkerInfoNV)
ProcSetLatencySleepModeNV                                  :: #type proc "system" (device: Device, swapchain: SwapchainKHR, pSleepModeInfo: ^LatencySleepModeInfoNV) -> Result
ProcSetLocalDimmingAMD                                     :: #type proc "system" (device: Device, swapChain: SwapchainKHR, localDimmingEnable: b32)
ProcSetPrivateData                                         :: #type proc "system" (device: Device, objectType: ObjectType, objectHandle: u64, privateDataSlot: PrivateDataSlot, data: u64) -> Result
ProcSetPrivateDataEXT                                      :: #type proc "system" (device: Device, objectType: ObjectType, objectHandle: u64, privateDataSlot: PrivateDataSlot, data: u64) -> Result
ProcSignalSemaphore                                        :: #type proc "system" (device: Device, pSignalInfo: ^SemaphoreSignalInfo) -> Result
ProcSignalSemaphoreKHR                                     :: #type proc "system" (device: Device, pSignalInfo: ^SemaphoreSignalInfo) -> Result
ProcTransitionImageLayoutEXT                               :: #type proc "system" (device: Device, transitionCount: u32, pTransitions: [^]HostImageLayoutTransitionInfoEXT) -> Result
ProcTrimCommandPool                                        :: #type proc "system" (device: Device, commandPool: CommandPool, flags: CommandPoolTrimFlags)
ProcTrimCommandPoolKHR                                     :: #type proc "system" (device: Device, commandPool: CommandPool, flags: CommandPoolTrimFlags)
ProcUninitializePerformanceApiINTEL                        :: #type proc "system" (device: Device)
ProcUnmapMemory                                            :: #type proc "system" (device: Device, memory: DeviceMemory)
ProcUnmapMemory2KHR                                        :: #type proc "system" (device: Device, pMemoryUnmapInfo: ^MemoryUnmapInfoKHR) -> Result
ProcUpdateDescriptorSetWithTemplate                        :: #type proc "system" (device: Device, descriptorSet: DescriptorSet, descriptorUpdateTemplate: DescriptorUpdateTemplate, pData: rawptr)
ProcUpdateDescriptorSetWithTemplateKHR                     :: #type proc "system" (device: Device, descriptorSet: DescriptorSet, descriptorUpdateTemplate: DescriptorUpdateTemplate, pData: rawptr)
ProcUpdateDescriptorSets                                   :: #type proc "system" (device: Device, descriptorWriteCount: u32, pDescriptorWrites: [^]WriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: [^]CopyDescriptorSet)
ProcUpdateIndirectExecutionSetPipelineEXT                  :: #type proc "system" (device: Device, indirectExecutionSet: IndirectExecutionSetEXT, executionSetWriteCount: u32, pExecutionSetWrites: [^]WriteIndirectExecutionSetPipelineEXT)
ProcUpdateIndirectExecutionSetShaderEXT                    :: #type proc "system" (device: Device, indirectExecutionSet: IndirectExecutionSetEXT, executionSetWriteCount: u32, pExecutionSetWrites: [^]WriteIndirectExecutionSetShaderEXT)
ProcUpdateVideoSessionParametersKHR                        :: #type proc "system" (device: Device, videoSessionParameters: VideoSessionParametersKHR, pUpdateInfo: ^VideoSessionParametersUpdateInfoKHR) -> Result
ProcWaitForFences                                          :: #type proc "system" (device: Device, fenceCount: u32, pFences: [^]Fence, waitAll: b32, timeout: u64) -> Result
ProcWaitForPresentKHR                                      :: #type proc "system" (device: Device, swapchain: SwapchainKHR, presentId: u64, timeout: u64) -> Result
ProcWaitSemaphores                                         :: #type proc "system" (device: Device, pWaitInfo: ^SemaphoreWaitInfo, timeout: u64) -> Result
ProcWaitSemaphoresKHR                                      :: #type proc "system" (device: Device, pWaitInfo: ^SemaphoreWaitInfo, timeout: u64) -> Result
ProcWriteAccelerationStructuresPropertiesKHR               :: #type proc "system" (device: Device, accelerationStructureCount: u32, pAccelerationStructures: [^]AccelerationStructureKHR, queryType: QueryType, dataSize: int, pData: rawptr, stride: int) -> Result
ProcWriteMicromapsPropertiesEXT                            :: #type proc "system" (device: Device, micromapCount: u32, pMicromaps: [^]MicromapEXT, queryType: QueryType, dataSize: int, pData: rawptr, stride: int) -> Result




VTable :: struct {
        // Loader procs
        CreateInstance                       : ProcCreateInstance,
        DebugUtilsMessengerCallbackEXT       : ProcDebugUtilsMessengerCallbackEXT,
        DeviceMemoryReportCallbackEXT        : ProcDeviceMemoryReportCallbackEXT,
        EnumerateInstanceExtensionProperties : ProcEnumerateInstanceExtensionProperties,
        EnumerateInstanceLayerProperties     : ProcEnumerateInstanceLayerProperties,
        EnumerateInstanceVersion             : ProcEnumerateInstanceVersion,
        GetInstanceProcAddr                  : ProcGetInstanceProcAddr,

        // Instance procs
        AcquireDrmDisplayEXT                                            : ProcAcquireDrmDisplayEXT,
        AcquireWinrtDisplayNV                                           : ProcAcquireWinrtDisplayNV,
        CreateDebugReportCallbackEXT                                    : ProcCreateDebugReportCallbackEXT,
        CreateDebugUtilsMessengerEXT                                    : ProcCreateDebugUtilsMessengerEXT,
        CreateDevice                                                    : ProcCreateDevice,
        CreateDisplayModeKHR                                            : ProcCreateDisplayModeKHR,
        CreateDisplayPlaneSurfaceKHR                                    : ProcCreateDisplayPlaneSurfaceKHR,
        CreateHeadlessSurfaceEXT                                        : ProcCreateHeadlessSurfaceEXT,
        CreateIOSSurfaceMVK                                             : ProcCreateIOSSurfaceMVK,
        CreateMacOSSurfaceMVK                                           : ProcCreateMacOSSurfaceMVK,
        CreateMetalSurfaceEXT                                           : ProcCreateMetalSurfaceEXT,
        CreateWaylandSurfaceKHR                                         : ProcCreateWaylandSurfaceKHR,
        CreateWin32SurfaceKHR                                           : ProcCreateWin32SurfaceKHR,
        DebugReportMessageEXT                                           : ProcDebugReportMessageEXT,
        DestroyDebugReportCallbackEXT                                   : ProcDestroyDebugReportCallbackEXT,
        DestroyDebugUtilsMessengerEXT                                   : ProcDestroyDebugUtilsMessengerEXT,
        DestroyInstance                                                 : ProcDestroyInstance,
        DestroySurfaceKHR                                               : ProcDestroySurfaceKHR,
        EnumerateDeviceExtensionProperties                              : ProcEnumerateDeviceExtensionProperties,
        EnumerateDeviceLayerProperties                                  : ProcEnumerateDeviceLayerProperties,
        EnumeratePhysicalDeviceGroups                                   : ProcEnumeratePhysicalDeviceGroups,
        EnumeratePhysicalDeviceGroupsKHR                                : ProcEnumeratePhysicalDeviceGroupsKHR,
        EnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR   : ProcEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR,
        EnumeratePhysicalDevices                                        : ProcEnumeratePhysicalDevices,
        GetDisplayModeProperties2KHR                                    : ProcGetDisplayModeProperties2KHR,
        GetDisplayModePropertiesKHR                                     : ProcGetDisplayModePropertiesKHR,
        GetDisplayPlaneCapabilities2KHR                                 : ProcGetDisplayPlaneCapabilities2KHR,
        GetDisplayPlaneCapabilitiesKHR                                  : ProcGetDisplayPlaneCapabilitiesKHR,
        GetDisplayPlaneSupportedDisplaysKHR                             : ProcGetDisplayPlaneSupportedDisplaysKHR,
        GetDrmDisplayEXT                                                : ProcGetDrmDisplayEXT,
        GetInstanceProcAddrLUNARG                                       : ProcGetInstanceProcAddrLUNARG,
        GetPhysicalDeviceCalibrateableTimeDomainsEXT                    : ProcGetPhysicalDeviceCalibrateableTimeDomainsEXT,
        GetPhysicalDeviceCalibrateableTimeDomainsKHR                    : ProcGetPhysicalDeviceCalibrateableTimeDomainsKHR,
        GetPhysicalDeviceCooperativeMatrixPropertiesKHR                 : ProcGetPhysicalDeviceCooperativeMatrixPropertiesKHR,
        GetPhysicalDeviceCooperativeMatrixPropertiesNV                  : ProcGetPhysicalDeviceCooperativeMatrixPropertiesNV,
        GetPhysicalDeviceDisplayPlaneProperties2KHR                     : ProcGetPhysicalDeviceDisplayPlaneProperties2KHR,
        GetPhysicalDeviceDisplayPlanePropertiesKHR                      : ProcGetPhysicalDeviceDisplayPlanePropertiesKHR,
        GetPhysicalDeviceDisplayProperties2KHR                          : ProcGetPhysicalDeviceDisplayProperties2KHR,
        GetPhysicalDeviceDisplayPropertiesKHR                           : ProcGetPhysicalDeviceDisplayPropertiesKHR,
        GetPhysicalDeviceExternalBufferProperties                       : ProcGetPhysicalDeviceExternalBufferProperties,
        GetPhysicalDeviceExternalBufferPropertiesKHR                    : ProcGetPhysicalDeviceExternalBufferPropertiesKHR,
        GetPhysicalDeviceExternalFenceProperties                        : ProcGetPhysicalDeviceExternalFenceProperties,
        GetPhysicalDeviceExternalFencePropertiesKHR                     : ProcGetPhysicalDeviceExternalFencePropertiesKHR,
        GetPhysicalDeviceExternalImageFormatPropertiesNV                : ProcGetPhysicalDeviceExternalImageFormatPropertiesNV,
        GetPhysicalDeviceExternalSemaphoreProperties                    : ProcGetPhysicalDeviceExternalSemaphoreProperties,
        GetPhysicalDeviceExternalSemaphorePropertiesKHR                 : ProcGetPhysicalDeviceExternalSemaphorePropertiesKHR,
        GetPhysicalDeviceFeatures                                       : ProcGetPhysicalDeviceFeatures,
        GetPhysicalDeviceFeatures2                                      : ProcGetPhysicalDeviceFeatures2,
        GetPhysicalDeviceFeatures2KHR                                   : ProcGetPhysicalDeviceFeatures2KHR,
        GetPhysicalDeviceFormatProperties                               : ProcGetPhysicalDeviceFormatProperties,
        GetPhysicalDeviceFormatProperties2                              : ProcGetPhysicalDeviceFormatProperties2,
        GetPhysicalDeviceFormatProperties2KHR                           : ProcGetPhysicalDeviceFormatProperties2KHR,
        GetPhysicalDeviceFragmentShadingRatesKHR                        : ProcGetPhysicalDeviceFragmentShadingRatesKHR,
        GetPhysicalDeviceImageFormatProperties                          : ProcGetPhysicalDeviceImageFormatProperties,
        GetPhysicalDeviceImageFormatProperties2                         : ProcGetPhysicalDeviceImageFormatProperties2,
        GetPhysicalDeviceImageFormatProperties2KHR                      : ProcGetPhysicalDeviceImageFormatProperties2KHR,
        GetPhysicalDeviceMemoryProperties                               : ProcGetPhysicalDeviceMemoryProperties,
        GetPhysicalDeviceMemoryProperties2                              : ProcGetPhysicalDeviceMemoryProperties2,
        GetPhysicalDeviceMemoryProperties2KHR                           : ProcGetPhysicalDeviceMemoryProperties2KHR,
        GetPhysicalDeviceMultisamplePropertiesEXT                       : ProcGetPhysicalDeviceMultisamplePropertiesEXT,
        GetPhysicalDeviceOpticalFlowImageFormatsNV                      : ProcGetPhysicalDeviceOpticalFlowImageFormatsNV,
        GetPhysicalDevicePresentRectanglesKHR                           : ProcGetPhysicalDevicePresentRectanglesKHR,
        GetPhysicalDeviceProperties                                     : ProcGetPhysicalDeviceProperties,
        GetPhysicalDeviceProperties2                                    : ProcGetPhysicalDeviceProperties2,
        GetPhysicalDeviceProperties2KHR                                 : ProcGetPhysicalDeviceProperties2KHR,
        GetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR           : ProcGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR,
        GetPhysicalDeviceQueueFamilyProperties                          : ProcGetPhysicalDeviceQueueFamilyProperties,
        GetPhysicalDeviceQueueFamilyProperties2                         : ProcGetPhysicalDeviceQueueFamilyProperties2,
        GetPhysicalDeviceQueueFamilyProperties2KHR                      : ProcGetPhysicalDeviceQueueFamilyProperties2KHR,
        GetPhysicalDeviceSparseImageFormatProperties                    : ProcGetPhysicalDeviceSparseImageFormatProperties,
        GetPhysicalDeviceSparseImageFormatProperties2                   : ProcGetPhysicalDeviceSparseImageFormatProperties2,
        GetPhysicalDeviceSparseImageFormatProperties2KHR                : ProcGetPhysicalDeviceSparseImageFormatProperties2KHR,
        GetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV : ProcGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV,
        GetPhysicalDeviceSurfaceCapabilities2EXT                        : ProcGetPhysicalDeviceSurfaceCapabilities2EXT,
        GetPhysicalDeviceSurfaceCapabilities2KHR                        : ProcGetPhysicalDeviceSurfaceCapabilities2KHR,
        GetPhysicalDeviceSurfaceCapabilitiesKHR                         : ProcGetPhysicalDeviceSurfaceCapabilitiesKHR,
        GetPhysicalDeviceSurfaceFormats2KHR                             : ProcGetPhysicalDeviceSurfaceFormats2KHR,
        GetPhysicalDeviceSurfaceFormatsKHR                              : ProcGetPhysicalDeviceSurfaceFormatsKHR,
        GetPhysicalDeviceSurfacePresentModes2EXT                        : ProcGetPhysicalDeviceSurfacePresentModes2EXT,
        GetPhysicalDeviceSurfacePresentModesKHR                         : ProcGetPhysicalDeviceSurfacePresentModesKHR,
        GetPhysicalDeviceSurfaceSupportKHR                              : ProcGetPhysicalDeviceSurfaceSupportKHR,
        GetPhysicalDeviceToolProperties                                 : ProcGetPhysicalDeviceToolProperties,
        GetPhysicalDeviceToolPropertiesEXT                              : ProcGetPhysicalDeviceToolPropertiesEXT,
        GetPhysicalDeviceVideoCapabilitiesKHR                           : ProcGetPhysicalDeviceVideoCapabilitiesKHR,
        GetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR           : ProcGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR,
        GetPhysicalDeviceVideoFormatPropertiesKHR                       : ProcGetPhysicalDeviceVideoFormatPropertiesKHR,
        GetPhysicalDeviceWaylandPresentationSupportKHR                  : ProcGetPhysicalDeviceWaylandPresentationSupportKHR,
        GetPhysicalDeviceWin32PresentationSupportKHR                    : ProcGetPhysicalDeviceWin32PresentationSupportKHR,
        GetWinrtDisplayNV                                               : ProcGetWinrtDisplayNV,
        ReleaseDisplayEXT                                               : ProcReleaseDisplayEXT,
        SubmitDebugUtilsMessageEXT                                      : ProcSubmitDebugUtilsMessageEXT,

        // Device procs
	AcquireFullScreenExclusiveModeEXT                      : ProcAcquireFullScreenExclusiveModeEXT,
	AcquireNextImage2KHR                                   : ProcAcquireNextImage2KHR,
	AcquireNextImageKHR                                    : ProcAcquireNextImageKHR,
	AcquirePerformanceConfigurationINTEL                   : ProcAcquirePerformanceConfigurationINTEL,
	AcquireProfilingLockKHR                                : ProcAcquireProfilingLockKHR,
	AllocateCommandBuffers                                 : ProcAllocateCommandBuffers,
	AllocateDescriptorSets                                 : ProcAllocateDescriptorSets,
	AllocateMemory                                         : ProcAllocateMemory,
	AntiLagUpdateAMD                                       : ProcAntiLagUpdateAMD,
	BeginCommandBuffer                                     : ProcBeginCommandBuffer,
	BindAccelerationStructureMemoryNV                      : ProcBindAccelerationStructureMemoryNV,
	BindBufferMemory                                       : ProcBindBufferMemory,
	BindBufferMemory2                                      : ProcBindBufferMemory2,
	BindBufferMemory2KHR                                   : ProcBindBufferMemory2KHR,
	BindImageMemory                                        : ProcBindImageMemory,
	BindImageMemory2                                       : ProcBindImageMemory2,
	BindImageMemory2KHR                                    : ProcBindImageMemory2KHR,
	BindOpticalFlowSessionImageNV                          : ProcBindOpticalFlowSessionImageNV,
	BindVideoSessionMemoryKHR                              : ProcBindVideoSessionMemoryKHR,
	BuildAccelerationStructuresKHR                         : ProcBuildAccelerationStructuresKHR,
	BuildMicromapsEXT                                      : ProcBuildMicromapsEXT,
	CmdBeginConditionalRenderingEXT                        : ProcCmdBeginConditionalRenderingEXT,
	CmdBeginDebugUtilsLabelEXT                             : ProcCmdBeginDebugUtilsLabelEXT,
	CmdBeginQuery                                          : ProcCmdBeginQuery,
	CmdBeginQueryIndexedEXT                                : ProcCmdBeginQueryIndexedEXT,
	CmdBeginRenderPass                                     : ProcCmdBeginRenderPass,
	CmdBeginRenderPass2                                    : ProcCmdBeginRenderPass2,
	CmdBeginRenderPass2KHR                                 : ProcCmdBeginRenderPass2KHR,
	CmdBeginRendering                                      : ProcCmdBeginRendering,
	CmdBeginRenderingKHR                                   : ProcCmdBeginRenderingKHR,
	CmdBeginTransformFeedbackEXT                           : ProcCmdBeginTransformFeedbackEXT,
	CmdBeginVideoCodingKHR                                 : ProcCmdBeginVideoCodingKHR,
	CmdBindDescriptorBufferEmbeddedSamplers2EXT            : ProcCmdBindDescriptorBufferEmbeddedSamplers2EXT,
	CmdBindDescriptorBufferEmbeddedSamplersEXT             : ProcCmdBindDescriptorBufferEmbeddedSamplersEXT,
	CmdBindDescriptorBuffersEXT                            : ProcCmdBindDescriptorBuffersEXT,
	CmdBindDescriptorSets                                  : ProcCmdBindDescriptorSets,
	CmdBindDescriptorSets2KHR                              : ProcCmdBindDescriptorSets2KHR,
	CmdBindIndexBuffer                                     : ProcCmdBindIndexBuffer,
	CmdBindIndexBuffer2KHR                                 : ProcCmdBindIndexBuffer2KHR,
	CmdBindInvocationMaskHUAWEI                            : ProcCmdBindInvocationMaskHUAWEI,
	CmdBindPipeline                                        : ProcCmdBindPipeline,
	CmdBindPipelineShaderGroupNV                           : ProcCmdBindPipelineShaderGroupNV,
	CmdBindShadersEXT                                      : ProcCmdBindShadersEXT,
	CmdBindShadingRateImageNV                              : ProcCmdBindShadingRateImageNV,
	CmdBindTransformFeedbackBuffersEXT                     : ProcCmdBindTransformFeedbackBuffersEXT,
	CmdBindVertexBuffers                                   : ProcCmdBindVertexBuffers,
	CmdBindVertexBuffers2                                  : ProcCmdBindVertexBuffers2,
	CmdBindVertexBuffers2EXT                               : ProcCmdBindVertexBuffers2EXT,
	CmdBlitImage                                           : ProcCmdBlitImage,
	CmdBlitImage2                                          : ProcCmdBlitImage2,
	CmdBlitImage2KHR                                       : ProcCmdBlitImage2KHR,
	CmdBuildAccelerationStructureNV                        : ProcCmdBuildAccelerationStructureNV,
	CmdBuildAccelerationStructuresIndirectKHR              : ProcCmdBuildAccelerationStructuresIndirectKHR,
	CmdBuildAccelerationStructuresKHR                      : ProcCmdBuildAccelerationStructuresKHR,
	CmdBuildMicromapsEXT                                   : ProcCmdBuildMicromapsEXT,
	CmdClearAttachments                                    : ProcCmdClearAttachments,
	CmdClearColorImage                                     : ProcCmdClearColorImage,
	CmdClearDepthStencilImage                              : ProcCmdClearDepthStencilImage,
	CmdControlVideoCodingKHR                               : ProcCmdControlVideoCodingKHR,
	CmdCopyAccelerationStructureKHR                        : ProcCmdCopyAccelerationStructureKHR,
	CmdCopyAccelerationStructureNV                         : ProcCmdCopyAccelerationStructureNV,
	CmdCopyAccelerationStructureToMemoryKHR                : ProcCmdCopyAccelerationStructureToMemoryKHR,
	CmdCopyBuffer                                          : ProcCmdCopyBuffer,
	CmdCopyBuffer2                                         : ProcCmdCopyBuffer2,
	CmdCopyBuffer2KHR                                      : ProcCmdCopyBuffer2KHR,
	CmdCopyBufferToImage                                   : ProcCmdCopyBufferToImage,
	CmdCopyBufferToImage2                                  : ProcCmdCopyBufferToImage2,
	CmdCopyBufferToImage2KHR                               : ProcCmdCopyBufferToImage2KHR,
	CmdCopyImage                                           : ProcCmdCopyImage,
	CmdCopyImage2                                          : ProcCmdCopyImage2,
	CmdCopyImage2KHR                                       : ProcCmdCopyImage2KHR,
	CmdCopyImageToBuffer                                   : ProcCmdCopyImageToBuffer,
	CmdCopyImageToBuffer2                                  : ProcCmdCopyImageToBuffer2,
	CmdCopyImageToBuffer2KHR                               : ProcCmdCopyImageToBuffer2KHR,
	CmdCopyMemoryIndirectNV                                : ProcCmdCopyMemoryIndirectNV,
	CmdCopyMemoryToAccelerationStructureKHR                : ProcCmdCopyMemoryToAccelerationStructureKHR,
	CmdCopyMemoryToImageIndirectNV                         : ProcCmdCopyMemoryToImageIndirectNV,
	CmdCopyMemoryToMicromapEXT                             : ProcCmdCopyMemoryToMicromapEXT,
	CmdCopyMicromapEXT                                     : ProcCmdCopyMicromapEXT,
	CmdCopyMicromapToMemoryEXT                             : ProcCmdCopyMicromapToMemoryEXT,
	CmdCopyQueryPoolResults                                : ProcCmdCopyQueryPoolResults,
	CmdCuLaunchKernelNVX                                   : ProcCmdCuLaunchKernelNVX,
	CmdCudaLaunchKernelNV                                  : ProcCmdCudaLaunchKernelNV,
	CmdDebugMarkerBeginEXT                                 : ProcCmdDebugMarkerBeginEXT,
	CmdDebugMarkerEndEXT                                   : ProcCmdDebugMarkerEndEXT,
	CmdDebugMarkerInsertEXT                                : ProcCmdDebugMarkerInsertEXT,
	CmdDecodeVideoKHR                                      : ProcCmdDecodeVideoKHR,
	CmdDecompressMemoryIndirectCountNV                     : ProcCmdDecompressMemoryIndirectCountNV,
	CmdDecompressMemoryNV                                  : ProcCmdDecompressMemoryNV,
	CmdDispatch                                            : ProcCmdDispatch,
	CmdDispatchBase                                        : ProcCmdDispatchBase,
	CmdDispatchBaseKHR                                     : ProcCmdDispatchBaseKHR,
	CmdDispatchIndirect                                    : ProcCmdDispatchIndirect,
	CmdDraw                                                : ProcCmdDraw,
	CmdDrawClusterHUAWEI                                   : ProcCmdDrawClusterHUAWEI,
	CmdDrawClusterIndirectHUAWEI                           : ProcCmdDrawClusterIndirectHUAWEI,
	CmdDrawIndexed                                         : ProcCmdDrawIndexed,
	CmdDrawIndexedIndirect                                 : ProcCmdDrawIndexedIndirect,
	CmdDrawIndexedIndirectCount                            : ProcCmdDrawIndexedIndirectCount,
	CmdDrawIndexedIndirectCountAMD                         : ProcCmdDrawIndexedIndirectCountAMD,
	CmdDrawIndexedIndirectCountKHR                         : ProcCmdDrawIndexedIndirectCountKHR,
	CmdDrawIndirect                                        : ProcCmdDrawIndirect,
	CmdDrawIndirectByteCountEXT                            : ProcCmdDrawIndirectByteCountEXT,
	CmdDrawIndirectCount                                   : ProcCmdDrawIndirectCount,
	CmdDrawIndirectCountAMD                                : ProcCmdDrawIndirectCountAMD,
	CmdDrawIndirectCountKHR                                : ProcCmdDrawIndirectCountKHR,
	CmdDrawMeshTasksEXT                                    : ProcCmdDrawMeshTasksEXT,
	CmdDrawMeshTasksIndirectCountEXT                       : ProcCmdDrawMeshTasksIndirectCountEXT,
	CmdDrawMeshTasksIndirectCountNV                        : ProcCmdDrawMeshTasksIndirectCountNV,
	CmdDrawMeshTasksIndirectEXT                            : ProcCmdDrawMeshTasksIndirectEXT,
	CmdDrawMeshTasksIndirectNV                             : ProcCmdDrawMeshTasksIndirectNV,
	CmdDrawMeshTasksNV                                     : ProcCmdDrawMeshTasksNV,
	CmdDrawMultiEXT                                        : ProcCmdDrawMultiEXT,
	CmdDrawMultiIndexedEXT                                 : ProcCmdDrawMultiIndexedEXT,
	CmdEncodeVideoKHR                                      : ProcCmdEncodeVideoKHR,
	CmdEndConditionalRenderingEXT                          : ProcCmdEndConditionalRenderingEXT,
	CmdEndDebugUtilsLabelEXT                               : ProcCmdEndDebugUtilsLabelEXT,
	CmdEndQuery                                            : ProcCmdEndQuery,
	CmdEndQueryIndexedEXT                                  : ProcCmdEndQueryIndexedEXT,
	CmdEndRenderPass                                       : ProcCmdEndRenderPass,
	CmdEndRenderPass2                                      : ProcCmdEndRenderPass2,
	CmdEndRenderPass2KHR                                   : ProcCmdEndRenderPass2KHR,
	CmdEndRendering                                        : ProcCmdEndRendering,
	CmdEndRenderingKHR                                     : ProcCmdEndRenderingKHR,
	CmdEndTransformFeedbackEXT                             : ProcCmdEndTransformFeedbackEXT,
	CmdEndVideoCodingKHR                                   : ProcCmdEndVideoCodingKHR,
	CmdExecuteCommands                                     : ProcCmdExecuteCommands,
	CmdExecuteGeneratedCommandsEXT                         : ProcCmdExecuteGeneratedCommandsEXT,
	CmdExecuteGeneratedCommandsNV                          : ProcCmdExecuteGeneratedCommandsNV,
	CmdFillBuffer                                          : ProcCmdFillBuffer,
	CmdInsertDebugUtilsLabelEXT                            : ProcCmdInsertDebugUtilsLabelEXT,
	CmdNextSubpass                                         : ProcCmdNextSubpass,
	CmdNextSubpass2                                        : ProcCmdNextSubpass2,
	CmdNextSubpass2KHR                                     : ProcCmdNextSubpass2KHR,
	CmdOpticalFlowExecuteNV                                : ProcCmdOpticalFlowExecuteNV,
	CmdPipelineBarrier                                     : ProcCmdPipelineBarrier,
	CmdPipelineBarrier2                                    : ProcCmdPipelineBarrier2,
	CmdPipelineBarrier2KHR                                 : ProcCmdPipelineBarrier2KHR,
	CmdPreprocessGeneratedCommandsEXT                      : ProcCmdPreprocessGeneratedCommandsEXT,
	CmdPreprocessGeneratedCommandsNV                       : ProcCmdPreprocessGeneratedCommandsNV,
	CmdPushConstants                                       : ProcCmdPushConstants,
	CmdPushConstants2KHR                                   : ProcCmdPushConstants2KHR,
	CmdPushDescriptorSet2KHR                               : ProcCmdPushDescriptorSet2KHR,
	CmdPushDescriptorSetKHR                                : ProcCmdPushDescriptorSetKHR,
	CmdPushDescriptorSetWithTemplate2KHR                   : ProcCmdPushDescriptorSetWithTemplate2KHR,
	CmdPushDescriptorSetWithTemplateKHR                    : ProcCmdPushDescriptorSetWithTemplateKHR,
	CmdResetEvent                                          : ProcCmdResetEvent,
	CmdResetEvent2                                         : ProcCmdResetEvent2,
	CmdResetEvent2KHR                                      : ProcCmdResetEvent2KHR,
	CmdResetQueryPool                                      : ProcCmdResetQueryPool,
	CmdResolveImage                                        : ProcCmdResolveImage,
	CmdResolveImage2                                       : ProcCmdResolveImage2,
	CmdResolveImage2KHR                                    : ProcCmdResolveImage2KHR,
	CmdSetAlphaToCoverageEnableEXT                         : ProcCmdSetAlphaToCoverageEnableEXT,
	CmdSetAlphaToOneEnableEXT                              : ProcCmdSetAlphaToOneEnableEXT,
	CmdSetAttachmentFeedbackLoopEnableEXT                  : ProcCmdSetAttachmentFeedbackLoopEnableEXT,
	CmdSetBlendConstants                                   : ProcCmdSetBlendConstants,
	CmdSetCheckpointNV                                     : ProcCmdSetCheckpointNV,
	CmdSetCoarseSampleOrderNV                              : ProcCmdSetCoarseSampleOrderNV,
	CmdSetColorBlendAdvancedEXT                            : ProcCmdSetColorBlendAdvancedEXT,
	CmdSetColorBlendEnableEXT                              : ProcCmdSetColorBlendEnableEXT,
	CmdSetColorBlendEquationEXT                            : ProcCmdSetColorBlendEquationEXT,
	CmdSetColorWriteMaskEXT                                : ProcCmdSetColorWriteMaskEXT,
	CmdSetConservativeRasterizationModeEXT                 : ProcCmdSetConservativeRasterizationModeEXT,
	CmdSetCoverageModulationModeNV                         : ProcCmdSetCoverageModulationModeNV,
	CmdSetCoverageModulationTableEnableNV                  : ProcCmdSetCoverageModulationTableEnableNV,
	CmdSetCoverageModulationTableNV                        : ProcCmdSetCoverageModulationTableNV,
	CmdSetCoverageReductionModeNV                          : ProcCmdSetCoverageReductionModeNV,
	CmdSetCoverageToColorEnableNV                          : ProcCmdSetCoverageToColorEnableNV,
	CmdSetCoverageToColorLocationNV                        : ProcCmdSetCoverageToColorLocationNV,
	CmdSetCullMode                                         : ProcCmdSetCullMode,
	CmdSetCullModeEXT                                      : ProcCmdSetCullModeEXT,
	CmdSetDepthBias                                        : ProcCmdSetDepthBias,
	CmdSetDepthBias2EXT                                    : ProcCmdSetDepthBias2EXT,
	CmdSetDepthBiasEnable                                  : ProcCmdSetDepthBiasEnable,
	CmdSetDepthBiasEnableEXT                               : ProcCmdSetDepthBiasEnableEXT,
	CmdSetDepthBounds                                      : ProcCmdSetDepthBounds,
	CmdSetDepthBoundsTestEnable                            : ProcCmdSetDepthBoundsTestEnable,
	CmdSetDepthBoundsTestEnableEXT                         : ProcCmdSetDepthBoundsTestEnableEXT,
	CmdSetDepthClampEnableEXT                              : ProcCmdSetDepthClampEnableEXT,
	CmdSetDepthClampRangeEXT                               : ProcCmdSetDepthClampRangeEXT,
	CmdSetDepthClipEnableEXT                               : ProcCmdSetDepthClipEnableEXT,
	CmdSetDepthClipNegativeOneToOneEXT                     : ProcCmdSetDepthClipNegativeOneToOneEXT,
	CmdSetDepthCompareOp                                   : ProcCmdSetDepthCompareOp,
	CmdSetDepthCompareOpEXT                                : ProcCmdSetDepthCompareOpEXT,
	CmdSetDepthTestEnable                                  : ProcCmdSetDepthTestEnable,
	CmdSetDepthTestEnableEXT                               : ProcCmdSetDepthTestEnableEXT,
	CmdSetDepthWriteEnable                                 : ProcCmdSetDepthWriteEnable,
	CmdSetDepthWriteEnableEXT                              : ProcCmdSetDepthWriteEnableEXT,
	CmdSetDescriptorBufferOffsets2EXT                      : ProcCmdSetDescriptorBufferOffsets2EXT,
	CmdSetDescriptorBufferOffsetsEXT                       : ProcCmdSetDescriptorBufferOffsetsEXT,
	CmdSetDeviceMask                                       : ProcCmdSetDeviceMask,
	CmdSetDeviceMaskKHR                                    : ProcCmdSetDeviceMaskKHR,
	CmdSetDiscardRectangleEXT                              : ProcCmdSetDiscardRectangleEXT,
	CmdSetDiscardRectangleEnableEXT                        : ProcCmdSetDiscardRectangleEnableEXT,
	CmdSetDiscardRectangleModeEXT                          : ProcCmdSetDiscardRectangleModeEXT,
	CmdSetEvent                                            : ProcCmdSetEvent,
	CmdSetEvent2                                           : ProcCmdSetEvent2,
	CmdSetEvent2KHR                                        : ProcCmdSetEvent2KHR,
	CmdSetExclusiveScissorEnableNV                         : ProcCmdSetExclusiveScissorEnableNV,
	CmdSetExclusiveScissorNV                               : ProcCmdSetExclusiveScissorNV,
	CmdSetExtraPrimitiveOverestimationSizeEXT              : ProcCmdSetExtraPrimitiveOverestimationSizeEXT,
	CmdSetFragmentShadingRateEnumNV                        : ProcCmdSetFragmentShadingRateEnumNV,
	CmdSetFragmentShadingRateKHR                           : ProcCmdSetFragmentShadingRateKHR,
	CmdSetFrontFace                                        : ProcCmdSetFrontFace,
	CmdSetFrontFaceEXT                                     : ProcCmdSetFrontFaceEXT,
	CmdSetLineRasterizationModeEXT                         : ProcCmdSetLineRasterizationModeEXT,
	CmdSetLineStippleEXT                                   : ProcCmdSetLineStippleEXT,
	CmdSetLineStippleEnableEXT                             : ProcCmdSetLineStippleEnableEXT,
	CmdSetLineStippleKHR                                   : ProcCmdSetLineStippleKHR,
	CmdSetLineWidth                                        : ProcCmdSetLineWidth,
	CmdSetLogicOpEXT                                       : ProcCmdSetLogicOpEXT,
	CmdSetLogicOpEnableEXT                                 : ProcCmdSetLogicOpEnableEXT,
	CmdSetPatchControlPointsEXT                            : ProcCmdSetPatchControlPointsEXT,
	CmdSetPerformanceMarkerINTEL                           : ProcCmdSetPerformanceMarkerINTEL,
	CmdSetPerformanceOverrideINTEL                         : ProcCmdSetPerformanceOverrideINTEL,
	CmdSetPerformanceStreamMarkerINTEL                     : ProcCmdSetPerformanceStreamMarkerINTEL,
	CmdSetPolygonModeEXT                                   : ProcCmdSetPolygonModeEXT,
	CmdSetPrimitiveRestartEnable                           : ProcCmdSetPrimitiveRestartEnable,
	CmdSetPrimitiveRestartEnableEXT                        : ProcCmdSetPrimitiveRestartEnableEXT,
	CmdSetPrimitiveTopology                                : ProcCmdSetPrimitiveTopology,
	CmdSetPrimitiveTopologyEXT                             : ProcCmdSetPrimitiveTopologyEXT,
	CmdSetProvokingVertexModeEXT                           : ProcCmdSetProvokingVertexModeEXT,
	CmdSetRasterizationSamplesEXT                          : ProcCmdSetRasterizationSamplesEXT,
	CmdSetRasterizationStreamEXT                           : ProcCmdSetRasterizationStreamEXT,
	CmdSetRasterizerDiscardEnable                          : ProcCmdSetRasterizerDiscardEnable,
	CmdSetRasterizerDiscardEnableEXT                       : ProcCmdSetRasterizerDiscardEnableEXT,
	CmdSetRayTracingPipelineStackSizeKHR                   : ProcCmdSetRayTracingPipelineStackSizeKHR,
	CmdSetRenderingAttachmentLocationsKHR                  : ProcCmdSetRenderingAttachmentLocationsKHR,
	CmdSetRenderingInputAttachmentIndicesKHR               : ProcCmdSetRenderingInputAttachmentIndicesKHR,
	CmdSetRepresentativeFragmentTestEnableNV               : ProcCmdSetRepresentativeFragmentTestEnableNV,
	CmdSetSampleLocationsEXT                               : ProcCmdSetSampleLocationsEXT,
	CmdSetSampleLocationsEnableEXT                         : ProcCmdSetSampleLocationsEnableEXT,
	CmdSetSampleMaskEXT                                    : ProcCmdSetSampleMaskEXT,
	CmdSetScissor                                          : ProcCmdSetScissor,
	CmdSetScissorWithCount                                 : ProcCmdSetScissorWithCount,
	CmdSetScissorWithCountEXT                              : ProcCmdSetScissorWithCountEXT,
	CmdSetShadingRateImageEnableNV                         : ProcCmdSetShadingRateImageEnableNV,
	CmdSetStencilCompareMask                               : ProcCmdSetStencilCompareMask,
	CmdSetStencilOp                                        : ProcCmdSetStencilOp,
	CmdSetStencilOpEXT                                     : ProcCmdSetStencilOpEXT,
	CmdSetStencilReference                                 : ProcCmdSetStencilReference,
	CmdSetStencilTestEnable                                : ProcCmdSetStencilTestEnable,
	CmdSetStencilTestEnableEXT                             : ProcCmdSetStencilTestEnableEXT,
	CmdSetStencilWriteMask                                 : ProcCmdSetStencilWriteMask,
	CmdSetTessellationDomainOriginEXT                      : ProcCmdSetTessellationDomainOriginEXT,
	CmdSetVertexInputEXT                                   : ProcCmdSetVertexInputEXT,
	CmdSetViewport                                         : ProcCmdSetViewport,
	CmdSetViewportShadingRatePaletteNV                     : ProcCmdSetViewportShadingRatePaletteNV,
	CmdSetViewportSwizzleNV                                : ProcCmdSetViewportSwizzleNV,
	CmdSetViewportWScalingEnableNV                         : ProcCmdSetViewportWScalingEnableNV,
	CmdSetViewportWScalingNV                               : ProcCmdSetViewportWScalingNV,
	CmdSetViewportWithCount                                : ProcCmdSetViewportWithCount,
	CmdSetViewportWithCountEXT                             : ProcCmdSetViewportWithCountEXT,
	CmdSubpassShadingHUAWEI                                : ProcCmdSubpassShadingHUAWEI,
	CmdTraceRaysIndirect2KHR                               : ProcCmdTraceRaysIndirect2KHR,
	CmdTraceRaysIndirectKHR                                : ProcCmdTraceRaysIndirectKHR,
	CmdTraceRaysKHR                                        : ProcCmdTraceRaysKHR,
	CmdTraceRaysNV                                         : ProcCmdTraceRaysNV,
	CmdUpdateBuffer                                        : ProcCmdUpdateBuffer,
	CmdUpdatePipelineIndirectBufferNV                      : ProcCmdUpdatePipelineIndirectBufferNV,
	CmdWaitEvents                                          : ProcCmdWaitEvents,
	CmdWaitEvents2                                         : ProcCmdWaitEvents2,
	CmdWaitEvents2KHR                                      : ProcCmdWaitEvents2KHR,
	CmdWriteAccelerationStructuresPropertiesKHR            : ProcCmdWriteAccelerationStructuresPropertiesKHR,
	CmdWriteAccelerationStructuresPropertiesNV             : ProcCmdWriteAccelerationStructuresPropertiesNV,
	CmdWriteBufferMarker2AMD                               : ProcCmdWriteBufferMarker2AMD,
	CmdWriteBufferMarkerAMD                                : ProcCmdWriteBufferMarkerAMD,
	CmdWriteMicromapsPropertiesEXT                         : ProcCmdWriteMicromapsPropertiesEXT,
	CmdWriteTimestamp                                      : ProcCmdWriteTimestamp,
	CmdWriteTimestamp2                                     : ProcCmdWriteTimestamp2,
	CmdWriteTimestamp2KHR                                  : ProcCmdWriteTimestamp2KHR,
	CompileDeferredNV                                      : ProcCompileDeferredNV,
	CopyAccelerationStructureKHR                           : ProcCopyAccelerationStructureKHR,
	CopyAccelerationStructureToMemoryKHR                   : ProcCopyAccelerationStructureToMemoryKHR,
	CopyImageToImageEXT                                    : ProcCopyImageToImageEXT,
	CopyImageToMemoryEXT                                   : ProcCopyImageToMemoryEXT,
	CopyMemoryToAccelerationStructureKHR                   : ProcCopyMemoryToAccelerationStructureKHR,
	CopyMemoryToImageEXT                                   : ProcCopyMemoryToImageEXT,
	CopyMemoryToMicromapEXT                                : ProcCopyMemoryToMicromapEXT,
	CopyMicromapEXT                                        : ProcCopyMicromapEXT,
	CopyMicromapToMemoryEXT                                : ProcCopyMicromapToMemoryEXT,
	CreateAccelerationStructureKHR                         : ProcCreateAccelerationStructureKHR,
	CreateAccelerationStructureNV                          : ProcCreateAccelerationStructureNV,
	CreateBuffer                                           : ProcCreateBuffer,
	CreateBufferView                                       : ProcCreateBufferView,
	CreateCommandPool                                      : ProcCreateCommandPool,
	CreateComputePipelines                                 : ProcCreateComputePipelines,
	CreateCuFunctionNVX                                    : ProcCreateCuFunctionNVX,
	CreateCuModuleNVX                                      : ProcCreateCuModuleNVX,
	CreateCudaFunctionNV                                   : ProcCreateCudaFunctionNV,
	CreateCudaModuleNV                                     : ProcCreateCudaModuleNV,
	CreateDeferredOperationKHR                             : ProcCreateDeferredOperationKHR,
	CreateDescriptorPool                                   : ProcCreateDescriptorPool,
	CreateDescriptorSetLayout                              : ProcCreateDescriptorSetLayout,
	CreateDescriptorUpdateTemplate                         : ProcCreateDescriptorUpdateTemplate,
	CreateDescriptorUpdateTemplateKHR                      : ProcCreateDescriptorUpdateTemplateKHR,
	CreateEvent                                            : ProcCreateEvent,
	CreateFence                                            : ProcCreateFence,
	CreateFramebuffer                                      : ProcCreateFramebuffer,
	CreateGraphicsPipelines                                : ProcCreateGraphicsPipelines,
	CreateImage                                            : ProcCreateImage,
	CreateImageView                                        : ProcCreateImageView,
	CreateIndirectCommandsLayoutEXT                        : ProcCreateIndirectCommandsLayoutEXT,
	CreateIndirectCommandsLayoutNV                         : ProcCreateIndirectCommandsLayoutNV,
	CreateIndirectExecutionSetEXT                          : ProcCreateIndirectExecutionSetEXT,
	CreateMicromapEXT                                      : ProcCreateMicromapEXT,
	CreateOpticalFlowSessionNV                             : ProcCreateOpticalFlowSessionNV,
	CreatePipelineBinariesKHR                              : ProcCreatePipelineBinariesKHR,
	CreatePipelineCache                                    : ProcCreatePipelineCache,
	CreatePipelineLayout                                   : ProcCreatePipelineLayout,
	CreatePrivateDataSlot                                  : ProcCreatePrivateDataSlot,
	CreatePrivateDataSlotEXT                               : ProcCreatePrivateDataSlotEXT,
	CreateQueryPool                                        : ProcCreateQueryPool,
	CreateRayTracingPipelinesKHR                           : ProcCreateRayTracingPipelinesKHR,
	CreateRayTracingPipelinesNV                            : ProcCreateRayTracingPipelinesNV,
	CreateRenderPass                                       : ProcCreateRenderPass,
	CreateRenderPass2                                      : ProcCreateRenderPass2,
	CreateRenderPass2KHR                                   : ProcCreateRenderPass2KHR,
	CreateSampler                                          : ProcCreateSampler,
	CreateSamplerYcbcrConversion                           : ProcCreateSamplerYcbcrConversion,
	CreateSamplerYcbcrConversionKHR                        : ProcCreateSamplerYcbcrConversionKHR,
	CreateSemaphore                                        : ProcCreateSemaphore,
	CreateShaderModule                                     : ProcCreateShaderModule,
	CreateShadersEXT                                       : ProcCreateShadersEXT,
	CreateSharedSwapchainsKHR                              : ProcCreateSharedSwapchainsKHR,
	CreateSwapchainKHR                                     : ProcCreateSwapchainKHR,
	CreateValidationCacheEXT                               : ProcCreateValidationCacheEXT,
	CreateVideoSessionKHR                                  : ProcCreateVideoSessionKHR,
	CreateVideoSessionParametersKHR                        : ProcCreateVideoSessionParametersKHR,
	DebugMarkerSetObjectNameEXT                            : ProcDebugMarkerSetObjectNameEXT,
	DebugMarkerSetObjectTagEXT                             : ProcDebugMarkerSetObjectTagEXT,
	DeferredOperationJoinKHR                               : ProcDeferredOperationJoinKHR,
	DestroyAccelerationStructureKHR                        : ProcDestroyAccelerationStructureKHR,
	DestroyAccelerationStructureNV                         : ProcDestroyAccelerationStructureNV,
	DestroyBuffer                                          : ProcDestroyBuffer,
	DestroyBufferView                                      : ProcDestroyBufferView,
	DestroyCommandPool                                     : ProcDestroyCommandPool,
	DestroyCuFunctionNVX                                   : ProcDestroyCuFunctionNVX,
	DestroyCuModuleNVX                                     : ProcDestroyCuModuleNVX,
	DestroyCudaFunctionNV                                  : ProcDestroyCudaFunctionNV,
	DestroyCudaModuleNV                                    : ProcDestroyCudaModuleNV,
	DestroyDeferredOperationKHR                            : ProcDestroyDeferredOperationKHR,
	DestroyDescriptorPool                                  : ProcDestroyDescriptorPool,
	DestroyDescriptorSetLayout                             : ProcDestroyDescriptorSetLayout,
	DestroyDescriptorUpdateTemplate                        : ProcDestroyDescriptorUpdateTemplate,
	DestroyDescriptorUpdateTemplateKHR                     : ProcDestroyDescriptorUpdateTemplateKHR,
	DestroyDevice                                          : ProcDestroyDevice,
	DestroyEvent                                           : ProcDestroyEvent,
	DestroyFence                                           : ProcDestroyFence,
	DestroyFramebuffer                                     : ProcDestroyFramebuffer,
	DestroyImage                                           : ProcDestroyImage,
	DestroyImageView                                       : ProcDestroyImageView,
	DestroyIndirectCommandsLayoutEXT                       : ProcDestroyIndirectCommandsLayoutEXT,
	DestroyIndirectCommandsLayoutNV                        : ProcDestroyIndirectCommandsLayoutNV,
	DestroyIndirectExecutionSetEXT                         : ProcDestroyIndirectExecutionSetEXT,
	DestroyMicromapEXT                                     : ProcDestroyMicromapEXT,
	DestroyOpticalFlowSessionNV                            : ProcDestroyOpticalFlowSessionNV,
	DestroyPipeline                                        : ProcDestroyPipeline,
	DestroyPipelineBinaryKHR                               : ProcDestroyPipelineBinaryKHR,
	DestroyPipelineCache                                   : ProcDestroyPipelineCache,
	DestroyPipelineLayout                                  : ProcDestroyPipelineLayout,
	DestroyPrivateDataSlot                                 : ProcDestroyPrivateDataSlot,
	DestroyPrivateDataSlotEXT                              : ProcDestroyPrivateDataSlotEXT,
	DestroyQueryPool                                       : ProcDestroyQueryPool,
	DestroyRenderPass                                      : ProcDestroyRenderPass,
	DestroySampler                                         : ProcDestroySampler,
	DestroySamplerYcbcrConversion                          : ProcDestroySamplerYcbcrConversion,
	DestroySamplerYcbcrConversionKHR                       : ProcDestroySamplerYcbcrConversionKHR,
	DestroySemaphore                                       : ProcDestroySemaphore,
	DestroyShaderEXT                                       : ProcDestroyShaderEXT,
	DestroyShaderModule                                    : ProcDestroyShaderModule,
	DestroySwapchainKHR                                    : ProcDestroySwapchainKHR,
	DestroyValidationCacheEXT                              : ProcDestroyValidationCacheEXT,
	DestroyVideoSessionKHR                                 : ProcDestroyVideoSessionKHR,
	DestroyVideoSessionParametersKHR                       : ProcDestroyVideoSessionParametersKHR,
	DeviceWaitIdle                                         : ProcDeviceWaitIdle,
	DisplayPowerControlEXT                                 : ProcDisplayPowerControlEXT,
	EndCommandBuffer                                       : ProcEndCommandBuffer,
	ExportMetalObjectsEXT                                  : ProcExportMetalObjectsEXT,
	FlushMappedMemoryRanges                                : ProcFlushMappedMemoryRanges,
	FreeCommandBuffers                                     : ProcFreeCommandBuffers,
	FreeDescriptorSets                                     : ProcFreeDescriptorSets,
	FreeMemory                                             : ProcFreeMemory,
	GetAccelerationStructureBuildSizesKHR                  : ProcGetAccelerationStructureBuildSizesKHR,
	GetAccelerationStructureDeviceAddressKHR               : ProcGetAccelerationStructureDeviceAddressKHR,
	GetAccelerationStructureHandleNV                       : ProcGetAccelerationStructureHandleNV,
	GetAccelerationStructureMemoryRequirementsNV           : ProcGetAccelerationStructureMemoryRequirementsNV,
	GetAccelerationStructureOpaqueCaptureDescriptorDataEXT : ProcGetAccelerationStructureOpaqueCaptureDescriptorDataEXT,
	GetBufferDeviceAddress                                 : ProcGetBufferDeviceAddress,
	GetBufferDeviceAddressEXT                              : ProcGetBufferDeviceAddressEXT,
	GetBufferDeviceAddressKHR                              : ProcGetBufferDeviceAddressKHR,
	GetBufferMemoryRequirements                            : ProcGetBufferMemoryRequirements,
	GetBufferMemoryRequirements2                           : ProcGetBufferMemoryRequirements2,
	GetBufferMemoryRequirements2KHR                        : ProcGetBufferMemoryRequirements2KHR,
	GetBufferOpaqueCaptureAddress                          : ProcGetBufferOpaqueCaptureAddress,
	GetBufferOpaqueCaptureAddressKHR                       : ProcGetBufferOpaqueCaptureAddressKHR,
	GetBufferOpaqueCaptureDescriptorDataEXT                : ProcGetBufferOpaqueCaptureDescriptorDataEXT,
	GetCalibratedTimestampsEXT                             : ProcGetCalibratedTimestampsEXT,
	GetCalibratedTimestampsKHR                             : ProcGetCalibratedTimestampsKHR,
	GetCudaModuleCacheNV                                   : ProcGetCudaModuleCacheNV,
	GetDeferredOperationMaxConcurrencyKHR                  : ProcGetDeferredOperationMaxConcurrencyKHR,
	GetDeferredOperationResultKHR                          : ProcGetDeferredOperationResultKHR,
	GetDescriptorEXT                                       : ProcGetDescriptorEXT,
	GetDescriptorSetHostMappingVALVE                       : ProcGetDescriptorSetHostMappingVALVE,
	GetDescriptorSetLayoutBindingOffsetEXT                 : ProcGetDescriptorSetLayoutBindingOffsetEXT,
	GetDescriptorSetLayoutHostMappingInfoVALVE             : ProcGetDescriptorSetLayoutHostMappingInfoVALVE,
	GetDescriptorSetLayoutSizeEXT                          : ProcGetDescriptorSetLayoutSizeEXT,
	GetDescriptorSetLayoutSupport                          : ProcGetDescriptorSetLayoutSupport,
	GetDescriptorSetLayoutSupportKHR                       : ProcGetDescriptorSetLayoutSupportKHR,
	GetDeviceAccelerationStructureCompatibilityKHR         : ProcGetDeviceAccelerationStructureCompatibilityKHR,
	GetDeviceBufferMemoryRequirements                      : ProcGetDeviceBufferMemoryRequirements,
	GetDeviceBufferMemoryRequirementsKHR                   : ProcGetDeviceBufferMemoryRequirementsKHR,
	GetDeviceFaultInfoEXT                                  : ProcGetDeviceFaultInfoEXT,
	GetDeviceGroupPeerMemoryFeatures                       : ProcGetDeviceGroupPeerMemoryFeatures,
	GetDeviceGroupPeerMemoryFeaturesKHR                    : ProcGetDeviceGroupPeerMemoryFeaturesKHR,
	GetDeviceGroupPresentCapabilitiesKHR                   : ProcGetDeviceGroupPresentCapabilitiesKHR,
	GetDeviceGroupSurfacePresentModes2EXT                  : ProcGetDeviceGroupSurfacePresentModes2EXT,
	GetDeviceGroupSurfacePresentModesKHR                   : ProcGetDeviceGroupSurfacePresentModesKHR,
	GetDeviceImageMemoryRequirements                       : ProcGetDeviceImageMemoryRequirements,
	GetDeviceImageMemoryRequirementsKHR                    : ProcGetDeviceImageMemoryRequirementsKHR,
	GetDeviceImageSparseMemoryRequirements                 : ProcGetDeviceImageSparseMemoryRequirements,
	GetDeviceImageSparseMemoryRequirementsKHR              : ProcGetDeviceImageSparseMemoryRequirementsKHR,
	GetDeviceImageSubresourceLayoutKHR                     : ProcGetDeviceImageSubresourceLayoutKHR,
	GetDeviceMemoryCommitment                              : ProcGetDeviceMemoryCommitment,
	GetDeviceMemoryOpaqueCaptureAddress                    : ProcGetDeviceMemoryOpaqueCaptureAddress,
	GetDeviceMemoryOpaqueCaptureAddressKHR                 : ProcGetDeviceMemoryOpaqueCaptureAddressKHR,
	GetDeviceMicromapCompatibilityEXT                      : ProcGetDeviceMicromapCompatibilityEXT,
	GetDeviceProcAddr                                      : ProcGetDeviceProcAddr,
	GetDeviceQueue                                         : ProcGetDeviceQueue,
	GetDeviceQueue2                                        : ProcGetDeviceQueue2,
	GetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI          : ProcGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI,
	GetDynamicRenderingTilePropertiesQCOM                  : ProcGetDynamicRenderingTilePropertiesQCOM,
	GetEncodedVideoSessionParametersKHR                    : ProcGetEncodedVideoSessionParametersKHR,
	GetEventStatus                                         : ProcGetEventStatus,
	GetFenceFdKHR                                          : ProcGetFenceFdKHR,
	GetFenceStatus                                         : ProcGetFenceStatus,
	GetFenceWin32HandleKHR                                 : ProcGetFenceWin32HandleKHR,
	GetFramebufferTilePropertiesQCOM                       : ProcGetFramebufferTilePropertiesQCOM,
	GetGeneratedCommandsMemoryRequirementsEXT              : ProcGetGeneratedCommandsMemoryRequirementsEXT,
	GetGeneratedCommandsMemoryRequirementsNV               : ProcGetGeneratedCommandsMemoryRequirementsNV,
	GetImageDrmFormatModifierPropertiesEXT                 : ProcGetImageDrmFormatModifierPropertiesEXT,
	GetImageMemoryRequirements                             : ProcGetImageMemoryRequirements,
	GetImageMemoryRequirements2                            : ProcGetImageMemoryRequirements2,
	GetImageMemoryRequirements2KHR                         : ProcGetImageMemoryRequirements2KHR,
	GetImageOpaqueCaptureDescriptorDataEXT                 : ProcGetImageOpaqueCaptureDescriptorDataEXT,
	GetImageSparseMemoryRequirements                       : ProcGetImageSparseMemoryRequirements,
	GetImageSparseMemoryRequirements2                      : ProcGetImageSparseMemoryRequirements2,
	GetImageSparseMemoryRequirements2KHR                   : ProcGetImageSparseMemoryRequirements2KHR,
	GetImageSubresourceLayout                              : ProcGetImageSubresourceLayout,
	GetImageSubresourceLayout2EXT                          : ProcGetImageSubresourceLayout2EXT,
	GetImageSubresourceLayout2KHR                          : ProcGetImageSubresourceLayout2KHR,
	GetImageViewAddressNVX                                 : ProcGetImageViewAddressNVX,
	GetImageViewHandleNVX                                  : ProcGetImageViewHandleNVX,
	GetImageViewOpaqueCaptureDescriptorDataEXT             : ProcGetImageViewOpaqueCaptureDescriptorDataEXT,
	GetLatencyTimingsNV                                    : ProcGetLatencyTimingsNV,
	GetMemoryFdKHR                                         : ProcGetMemoryFdKHR,
	GetMemoryFdPropertiesKHR                               : ProcGetMemoryFdPropertiesKHR,
	GetMemoryHostPointerPropertiesEXT                      : ProcGetMemoryHostPointerPropertiesEXT,
	GetMemoryRemoteAddressNV                               : ProcGetMemoryRemoteAddressNV,
	GetMemoryWin32HandleKHR                                : ProcGetMemoryWin32HandleKHR,
	GetMemoryWin32HandleNV                                 : ProcGetMemoryWin32HandleNV,
	GetMemoryWin32HandlePropertiesKHR                      : ProcGetMemoryWin32HandlePropertiesKHR,
	GetMicromapBuildSizesEXT                               : ProcGetMicromapBuildSizesEXT,
	GetPastPresentationTimingGOOGLE                        : ProcGetPastPresentationTimingGOOGLE,
	GetPerformanceParameterINTEL                           : ProcGetPerformanceParameterINTEL,
	GetPipelineBinaryDataKHR                               : ProcGetPipelineBinaryDataKHR,
	GetPipelineCacheData                                   : ProcGetPipelineCacheData,
	GetPipelineExecutableInternalRepresentationsKHR        : ProcGetPipelineExecutableInternalRepresentationsKHR,
	GetPipelineExecutablePropertiesKHR                     : ProcGetPipelineExecutablePropertiesKHR,
	GetPipelineExecutableStatisticsKHR                     : ProcGetPipelineExecutableStatisticsKHR,
	GetPipelineIndirectDeviceAddressNV                     : ProcGetPipelineIndirectDeviceAddressNV,
	GetPipelineIndirectMemoryRequirementsNV                : ProcGetPipelineIndirectMemoryRequirementsNV,
	GetPipelineKeyKHR                                      : ProcGetPipelineKeyKHR,
	GetPipelinePropertiesEXT                               : ProcGetPipelinePropertiesEXT,
	GetPrivateData                                         : ProcGetPrivateData,
	GetPrivateDataEXT                                      : ProcGetPrivateDataEXT,
	GetQueryPoolResults                                    : ProcGetQueryPoolResults,
	GetQueueCheckpointData2NV                              : ProcGetQueueCheckpointData2NV,
	GetQueueCheckpointDataNV                               : ProcGetQueueCheckpointDataNV,
	GetRayTracingCaptureReplayShaderGroupHandlesKHR        : ProcGetRayTracingCaptureReplayShaderGroupHandlesKHR,
	GetRayTracingShaderGroupHandlesKHR                     : ProcGetRayTracingShaderGroupHandlesKHR,
	GetRayTracingShaderGroupHandlesNV                      : ProcGetRayTracingShaderGroupHandlesNV,
	GetRayTracingShaderGroupStackSizeKHR                   : ProcGetRayTracingShaderGroupStackSizeKHR,
	GetRefreshCycleDurationGOOGLE                          : ProcGetRefreshCycleDurationGOOGLE,
	GetRenderAreaGranularity                               : ProcGetRenderAreaGranularity,
	GetRenderingAreaGranularityKHR                         : ProcGetRenderingAreaGranularityKHR,
	GetSamplerOpaqueCaptureDescriptorDataEXT               : ProcGetSamplerOpaqueCaptureDescriptorDataEXT,
	GetSemaphoreCounterValue                               : ProcGetSemaphoreCounterValue,
	GetSemaphoreCounterValueKHR                            : ProcGetSemaphoreCounterValueKHR,
	GetSemaphoreFdKHR                                      : ProcGetSemaphoreFdKHR,
	GetSemaphoreWin32HandleKHR                             : ProcGetSemaphoreWin32HandleKHR,
	GetShaderBinaryDataEXT                                 : ProcGetShaderBinaryDataEXT,
	GetShaderInfoAMD                                       : ProcGetShaderInfoAMD,
	GetShaderModuleCreateInfoIdentifierEXT                 : ProcGetShaderModuleCreateInfoIdentifierEXT,
	GetShaderModuleIdentifierEXT                           : ProcGetShaderModuleIdentifierEXT,
	GetSwapchainCounterEXT                                 : ProcGetSwapchainCounterEXT,
	GetSwapchainImagesKHR                                  : ProcGetSwapchainImagesKHR,
	GetSwapchainStatusKHR                                  : ProcGetSwapchainStatusKHR,
	GetValidationCacheDataEXT                              : ProcGetValidationCacheDataEXT,
	GetVideoSessionMemoryRequirementsKHR                   : ProcGetVideoSessionMemoryRequirementsKHR,
	ImportFenceFdKHR                                       : ProcImportFenceFdKHR,
	ImportFenceWin32HandleKHR                              : ProcImportFenceWin32HandleKHR,
	ImportSemaphoreFdKHR                                   : ProcImportSemaphoreFdKHR,
	ImportSemaphoreWin32HandleKHR                          : ProcImportSemaphoreWin32HandleKHR,
	InitializePerformanceApiINTEL                          : ProcInitializePerformanceApiINTEL,
	InvalidateMappedMemoryRanges                           : ProcInvalidateMappedMemoryRanges,
	LatencySleepNV                                         : ProcLatencySleepNV,
	MapMemory                                              : ProcMapMemory,
	MapMemory2KHR                                          : ProcMapMemory2KHR,
	MergePipelineCaches                                    : ProcMergePipelineCaches,
	MergeValidationCachesEXT                               : ProcMergeValidationCachesEXT,
	QueueBeginDebugUtilsLabelEXT                           : ProcQueueBeginDebugUtilsLabelEXT,
	QueueBindSparse                                        : ProcQueueBindSparse,
	QueueEndDebugUtilsLabelEXT                             : ProcQueueEndDebugUtilsLabelEXT,
	QueueInsertDebugUtilsLabelEXT                          : ProcQueueInsertDebugUtilsLabelEXT,
	QueueNotifyOutOfBandNV                                 : ProcQueueNotifyOutOfBandNV,
	QueuePresentKHR                                        : ProcQueuePresentKHR,
	QueueSetPerformanceConfigurationINTEL                  : ProcQueueSetPerformanceConfigurationINTEL,
	QueueSubmit                                            : ProcQueueSubmit,
	QueueSubmit2                                           : ProcQueueSubmit2,
	QueueSubmit2KHR                                        : ProcQueueSubmit2KHR,
	QueueWaitIdle                                          : ProcQueueWaitIdle,
	RegisterDeviceEventEXT                                 : ProcRegisterDeviceEventEXT,
	RegisterDisplayEventEXT                                : ProcRegisterDisplayEventEXT,
	ReleaseCapturedPipelineDataKHR                         : ProcReleaseCapturedPipelineDataKHR,
	ReleaseFullScreenExclusiveModeEXT                      : ProcReleaseFullScreenExclusiveModeEXT,
	ReleasePerformanceConfigurationINTEL                   : ProcReleasePerformanceConfigurationINTEL,
	ReleaseProfilingLockKHR                                : ProcReleaseProfilingLockKHR,
	ReleaseSwapchainImagesEXT                              : ProcReleaseSwapchainImagesEXT,
	ResetCommandBuffer                                     : ProcResetCommandBuffer,
	ResetCommandPool                                       : ProcResetCommandPool,
	ResetDescriptorPool                                    : ProcResetDescriptorPool,
	ResetEvent                                             : ProcResetEvent,
	ResetFences                                            : ProcResetFences,
	ResetQueryPool                                         : ProcResetQueryPool,
	ResetQueryPoolEXT                                      : ProcResetQueryPoolEXT,
	SetDebugUtilsObjectNameEXT                             : ProcSetDebugUtilsObjectNameEXT,
	SetDebugUtilsObjectTagEXT                              : ProcSetDebugUtilsObjectTagEXT,
	SetDeviceMemoryPriorityEXT                             : ProcSetDeviceMemoryPriorityEXT,
	SetEvent                                               : ProcSetEvent,
	SetHdrMetadataEXT                                      : ProcSetHdrMetadataEXT,
	SetLatencyMarkerNV                                     : ProcSetLatencyMarkerNV,
	SetLatencySleepModeNV                                  : ProcSetLatencySleepModeNV,
	SetLocalDimmingAMD                                     : ProcSetLocalDimmingAMD,
	SetPrivateData                                         : ProcSetPrivateData,
	SetPrivateDataEXT                                      : ProcSetPrivateDataEXT,
	SignalSemaphore                                        : ProcSignalSemaphore,
	SignalSemaphoreKHR                                     : ProcSignalSemaphoreKHR,
	TransitionImageLayoutEXT                               : ProcTransitionImageLayoutEXT,
	TrimCommandPool                                        : ProcTrimCommandPool,
	TrimCommandPoolKHR                                     : ProcTrimCommandPoolKHR,
	UninitializePerformanceApiINTEL                        : ProcUninitializePerformanceApiINTEL,
	UnmapMemory                                            : ProcUnmapMemory,
	UnmapMemory2KHR                                        : ProcUnmapMemory2KHR,
	UpdateDescriptorSetWithTemplate                        : ProcUpdateDescriptorSetWithTemplate,
	UpdateDescriptorSetWithTemplateKHR                     : ProcUpdateDescriptorSetWithTemplateKHR,
	UpdateDescriptorSets                                   : ProcUpdateDescriptorSets,
	UpdateIndirectExecutionSetPipelineEXT                  : ProcUpdateIndirectExecutionSetPipelineEXT,
	UpdateIndirectExecutionSetShaderEXT                    : ProcUpdateIndirectExecutionSetShaderEXT,
	UpdateVideoSessionParametersKHR                        : ProcUpdateVideoSessionParametersKHR,
	WaitForFences                                          : ProcWaitForFences,
	WaitForPresentKHR                                      : ProcWaitForPresentKHR,
	WaitSemaphores                                         : ProcWaitSemaphores,
	WaitSemaphoresKHR                                      : ProcWaitSemaphoresKHR,
	WriteAccelerationStructuresPropertiesKHR               : ProcWriteAccelerationStructuresPropertiesKHR,
	WriteMicromapsPropertiesEXT                            : ProcWriteMicromapsPropertiesEXT,
}

load_proc_addresses_loader_vtable :: proc(vk_get_instance_proc_addr: rawptr, vtable: ^VTable) {
	vtable.GetInstanceProcAddr                  = auto_cast vk_get_instance_proc_addr

	vtable.CreateInstance                       = auto_cast vtable.GetInstanceProcAddr(nil, "vkCreateInstance")
	vtable.DebugUtilsMessengerCallbackEXT       = auto_cast vtable.GetInstanceProcAddr(nil, "vkDebugUtilsMessengerCallbackEXT")
	vtable.DeviceMemoryReportCallbackEXT        = auto_cast vtable.GetInstanceProcAddr(nil, "vkDeviceMemoryReportCallbackEXT")
	vtable.EnumerateInstanceExtensionProperties = auto_cast vtable.GetInstanceProcAddr(nil, "vkEnumerateInstanceExtensionProperties")
	vtable.EnumerateInstanceLayerProperties     = auto_cast vtable.GetInstanceProcAddr(nil, "vkEnumerateInstanceLayerProperties")
	vtable.EnumerateInstanceVersion             = auto_cast vtable.GetInstanceProcAddr(nil, "vkEnumerateInstanceVersion")
	vtable.GetInstanceProcAddr                  = auto_cast vtable.GetInstanceProcAddr(nil, "vkGetInstanceProcAddr")
}

load_proc_addresses_instance_vtable :: proc(instance: Instance,  vtable: ^VTable) {
	vtable.AcquireDrmDisplayEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireDrmDisplayEXT")
	vtable.AcquireWinrtDisplayNV                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireWinrtDisplayNV")
	vtable.CreateDebugReportCallbackEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT")
	vtable.CreateDebugUtilsMessengerEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT")
	vtable.CreateDevice                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDevice")
	vtable.CreateDisplayModeKHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDisplayModeKHR")
	vtable.CreateDisplayPlaneSurfaceKHR                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDisplayPlaneSurfaceKHR")
	vtable.CreateHeadlessSurfaceEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateHeadlessSurfaceEXT")
	vtable.CreateIOSSurfaceMVK                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateIOSSurfaceMVK")
	vtable.CreateMacOSSurfaceMVK                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateMacOSSurfaceMVK")
	vtable.CreateMetalSurfaceEXT                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateMetalSurfaceEXT")
	vtable.CreateWaylandSurfaceKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateWaylandSurfaceKHR")
	vtable.CreateWin32SurfaceKHR                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateWin32SurfaceKHR")
	vtable.DebugReportMessageEXT                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkDebugReportMessageEXT")
	vtable.DestroyDebugReportCallbackEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDebugReportCallbackEXT")
	vtable.DestroyDebugUtilsMessengerEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT")
	vtable.DestroyInstance                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyInstance")
	vtable.DestroySurfaceKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySurfaceKHR")
	vtable.EnumerateDeviceExtensionProperties                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumerateDeviceExtensionProperties")
	vtable.EnumerateDeviceLayerProperties                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumerateDeviceLayerProperties")
	vtable.EnumeratePhysicalDeviceGroups                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceGroups")
	vtable.EnumeratePhysicalDeviceGroupsKHR                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceGroupsKHR")
	vtable.EnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR   = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR")
	vtable.EnumeratePhysicalDevices                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkEnumeratePhysicalDevices")
	vtable.GetDisplayModeProperties2KHR                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDisplayModeProperties2KHR")
	vtable.GetDisplayModePropertiesKHR                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDisplayModePropertiesKHR")
	vtable.GetDisplayPlaneCapabilities2KHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDisplayPlaneCapabilities2KHR")
	vtable.GetDisplayPlaneCapabilitiesKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDisplayPlaneCapabilitiesKHR")
	vtable.GetDisplayPlaneSupportedDisplaysKHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDisplayPlaneSupportedDisplaysKHR")
	vtable.GetDrmDisplayEXT                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDrmDisplayEXT")
	vtable.GetInstanceProcAddrLUNARG                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetInstanceProcAddrLUNARG")
	vtable.GetPhysicalDeviceCalibrateableTimeDomainsEXT                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCalibrateableTimeDomainsEXT")
	vtable.GetPhysicalDeviceCalibrateableTimeDomainsKHR                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCalibrateableTimeDomainsKHR")
	vtable.GetPhysicalDeviceCooperativeMatrixPropertiesKHR                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCooperativeMatrixPropertiesKHR")
	vtable.GetPhysicalDeviceCooperativeMatrixPropertiesNV                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceCooperativeMatrixPropertiesNV")
	vtable.GetPhysicalDeviceDisplayPlaneProperties2KHR                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPlaneProperties2KHR")
	vtable.GetPhysicalDeviceDisplayPlanePropertiesKHR                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPlanePropertiesKHR")
	vtable.GetPhysicalDeviceDisplayProperties2KHR                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayProperties2KHR")
	vtable.GetPhysicalDeviceDisplayPropertiesKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceDisplayPropertiesKHR")
	vtable.GetPhysicalDeviceExternalBufferProperties                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalBufferProperties")
	vtable.GetPhysicalDeviceExternalBufferPropertiesKHR                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalBufferPropertiesKHR")
	vtable.GetPhysicalDeviceExternalFenceProperties                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalFenceProperties")
	vtable.GetPhysicalDeviceExternalFencePropertiesKHR                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalFencePropertiesKHR")
	vtable.GetPhysicalDeviceExternalImageFormatPropertiesNV                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalImageFormatPropertiesNV")
	vtable.GetPhysicalDeviceExternalSemaphoreProperties                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalSemaphoreProperties")
	vtable.GetPhysicalDeviceExternalSemaphorePropertiesKHR                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceExternalSemaphorePropertiesKHR")
	vtable.GetPhysicalDeviceFeatures                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures")
	vtable.GetPhysicalDeviceFeatures2                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures2")
	vtable.GetPhysicalDeviceFeatures2KHR                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFeatures2KHR")
	vtable.GetPhysicalDeviceFormatProperties                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties")
	vtable.GetPhysicalDeviceFormatProperties2                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties2")
	vtable.GetPhysicalDeviceFormatProperties2KHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFormatProperties2KHR")
	vtable.GetPhysicalDeviceFragmentShadingRatesKHR                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceFragmentShadingRatesKHR")
	vtable.GetPhysicalDeviceImageFormatProperties                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties")
	vtable.GetPhysicalDeviceImageFormatProperties2                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties2")
	vtable.GetPhysicalDeviceImageFormatProperties2KHR                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceImageFormatProperties2KHR")
	vtable.GetPhysicalDeviceMemoryProperties                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties")
	vtable.GetPhysicalDeviceMemoryProperties2                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties2")
	vtable.GetPhysicalDeviceMemoryProperties2KHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMemoryProperties2KHR")
	vtable.GetPhysicalDeviceMultisamplePropertiesEXT                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceMultisamplePropertiesEXT")
	vtable.GetPhysicalDeviceOpticalFlowImageFormatsNV                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceOpticalFlowImageFormatsNV")
	vtable.GetPhysicalDevicePresentRectanglesKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDevicePresentRectanglesKHR")
	vtable.GetPhysicalDeviceProperties                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties")
	vtable.GetPhysicalDeviceProperties2                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties2")
	vtable.GetPhysicalDeviceProperties2KHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceProperties2KHR")
	vtable.GetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR")
	vtable.GetPhysicalDeviceQueueFamilyProperties                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties")
	vtable.GetPhysicalDeviceQueueFamilyProperties2                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties2")
	vtable.GetPhysicalDeviceQueueFamilyProperties2KHR                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceQueueFamilyProperties2KHR")
	vtable.GetPhysicalDeviceSparseImageFormatProperties                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties")
	vtable.GetPhysicalDeviceSparseImageFormatProperties2                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties2")
	vtable.GetPhysicalDeviceSparseImageFormatProperties2KHR                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSparseImageFormatProperties2KHR")
	vtable.GetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV")
	vtable.GetPhysicalDeviceSurfaceCapabilities2EXT                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilities2EXT")
	vtable.GetPhysicalDeviceSurfaceCapabilities2KHR                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilities2KHR")
	vtable.GetPhysicalDeviceSurfaceCapabilitiesKHR                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
	vtable.GetPhysicalDeviceSurfaceFormats2KHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceFormats2KHR")
	vtable.GetPhysicalDeviceSurfaceFormatsKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceFormatsKHR")
	vtable.GetPhysicalDeviceSurfacePresentModes2EXT                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfacePresentModes2EXT")
	vtable.GetPhysicalDeviceSurfacePresentModesKHR                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfacePresentModesKHR")
	vtable.GetPhysicalDeviceSurfaceSupportKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceSurfaceSupportKHR")
	vtable.GetPhysicalDeviceToolProperties                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceToolProperties")
	vtable.GetPhysicalDeviceToolPropertiesEXT                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceToolPropertiesEXT")
	vtable.GetPhysicalDeviceVideoCapabilitiesKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoCapabilitiesKHR")
	vtable.GetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoEncodeQualityLevelPropertiesKHR")
	vtable.GetPhysicalDeviceVideoFormatPropertiesKHR                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoFormatPropertiesKHR")
	vtable.GetPhysicalDeviceWaylandPresentationSupportKHR                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceWaylandPresentationSupportKHR")
	vtable.GetPhysicalDeviceWin32PresentationSupportKHR                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceWin32PresentationSupportKHR")
	vtable.GetWinrtDisplayNV                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetWinrtDisplayNV")
	vtable.ReleaseDisplayEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleaseDisplayEXT")
	vtable.SubmitDebugUtilsMessageEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkSubmitDebugUtilsMessageEXT")

        // Device procedures (may call into dispatch)
        vtable.AcquireFullScreenExclusiveModeEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireFullScreenExclusiveModeEXT")
	vtable.AcquireNextImage2KHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireNextImage2KHR")
	vtable.AcquireNextImageKHR                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireNextImageKHR")
	vtable.AcquirePerformanceConfigurationINTEL                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquirePerformanceConfigurationINTEL")
	vtable.AcquireProfilingLockKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkAcquireProfilingLockKHR")
	vtable.AllocateCommandBuffers                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkAllocateCommandBuffers")
	vtable.AllocateDescriptorSets                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkAllocateDescriptorSets")
	vtable.AllocateMemory                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkAllocateMemory")
	vtable.AntiLagUpdateAMD                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkAntiLagUpdateAMD")
	vtable.BeginCommandBuffer                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkBeginCommandBuffer")
	vtable.BindAccelerationStructureMemoryNV                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindAccelerationStructureMemoryNV")
	vtable.BindBufferMemory                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindBufferMemory")
	vtable.BindBufferMemory2                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindBufferMemory2")
	vtable.BindBufferMemory2KHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindBufferMemory2KHR")
	vtable.BindImageMemory                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindImageMemory")
	vtable.BindImageMemory2                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindImageMemory2")
	vtable.BindImageMemory2KHR                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindImageMemory2KHR")
	vtable.BindOpticalFlowSessionImageNV                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindOpticalFlowSessionImageNV")
	vtable.BindVideoSessionMemoryKHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkBindVideoSessionMemoryKHR")
	vtable.BuildAccelerationStructuresKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkBuildAccelerationStructuresKHR")
	vtable.BuildMicromapsEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkBuildMicromapsEXT")
	vtable.CmdBeginConditionalRenderingEXT                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginConditionalRenderingEXT")
	vtable.CmdBeginDebugUtilsLabelEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginDebugUtilsLabelEXT")
	vtable.CmdBeginQuery                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginQuery")
	vtable.CmdBeginQueryIndexedEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginQueryIndexedEXT")
	vtable.CmdBeginRenderPass                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginRenderPass")
	vtable.CmdBeginRenderPass2                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginRenderPass2")
	vtable.CmdBeginRenderPass2KHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginRenderPass2KHR")
	vtable.CmdBeginRendering                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginRendering")
	vtable.CmdBeginRenderingKHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginRenderingKHR")
	vtable.CmdBeginTransformFeedbackEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginTransformFeedbackEXT")
	vtable.CmdBeginVideoCodingKHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBeginVideoCodingKHR")
	vtable.CmdBindDescriptorBufferEmbeddedSamplers2EXT                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindDescriptorBufferEmbeddedSamplers2EXT")
	vtable.CmdBindDescriptorBufferEmbeddedSamplersEXT                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindDescriptorBufferEmbeddedSamplersEXT")
	vtable.CmdBindDescriptorBuffersEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindDescriptorBuffersEXT")
	vtable.CmdBindDescriptorSets                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindDescriptorSets")
	vtable.CmdBindDescriptorSets2KHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindDescriptorSets2KHR")
	vtable.CmdBindIndexBuffer                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindIndexBuffer")
	vtable.CmdBindIndexBuffer2KHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindIndexBuffer2KHR")
	vtable.CmdBindInvocationMaskHUAWEI                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindInvocationMaskHUAWEI")
	vtable.CmdBindPipeline                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindPipeline")
	vtable.CmdBindPipelineShaderGroupNV                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindPipelineShaderGroupNV")
	vtable.CmdBindShadersEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindShadersEXT")
	vtable.CmdBindShadingRateImageNV                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindShadingRateImageNV")
	vtable.CmdBindTransformFeedbackBuffersEXT                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindTransformFeedbackBuffersEXT")
	vtable.CmdBindVertexBuffers                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindVertexBuffers")
	vtable.CmdBindVertexBuffers2                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindVertexBuffers2")
	vtable.CmdBindVertexBuffers2EXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBindVertexBuffers2EXT")
	vtable.CmdBlitImage                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBlitImage")
	vtable.CmdBlitImage2                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBlitImage2")
	vtable.CmdBlitImage2KHR                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBlitImage2KHR")
	vtable.CmdBuildAccelerationStructureNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBuildAccelerationStructureNV")
	vtable.CmdBuildAccelerationStructuresIndirectKHR                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBuildAccelerationStructuresIndirectKHR")
	vtable.CmdBuildAccelerationStructuresKHR                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBuildAccelerationStructuresKHR")
	vtable.CmdBuildMicromapsEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdBuildMicromapsEXT")
	vtable.CmdClearAttachments                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdClearAttachments")
	vtable.CmdClearColorImage                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdClearColorImage")
	vtable.CmdClearDepthStencilImage                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdClearDepthStencilImage")
	vtable.CmdControlVideoCodingKHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdControlVideoCodingKHR")
	vtable.CmdCopyAccelerationStructureKHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyAccelerationStructureKHR")
	vtable.CmdCopyAccelerationStructureNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyAccelerationStructureNV")
	vtable.CmdCopyAccelerationStructureToMemoryKHR                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyAccelerationStructureToMemoryKHR")
	vtable.CmdCopyBuffer                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBuffer")
	vtable.CmdCopyBuffer2                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBuffer2")
	vtable.CmdCopyBuffer2KHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBuffer2KHR")
	vtable.CmdCopyBufferToImage                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBufferToImage")
	vtable.CmdCopyBufferToImage2                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBufferToImage2")
	vtable.CmdCopyBufferToImage2KHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyBufferToImage2KHR")
	vtable.CmdCopyImage                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImage")
	vtable.CmdCopyImage2                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImage2")
	vtable.CmdCopyImage2KHR                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImage2KHR")
	vtable.CmdCopyImageToBuffer                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImageToBuffer")
	vtable.CmdCopyImageToBuffer2                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImageToBuffer2")
	vtable.CmdCopyImageToBuffer2KHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyImageToBuffer2KHR")
	vtable.CmdCopyMemoryIndirectNV                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMemoryIndirectNV")
	vtable.CmdCopyMemoryToAccelerationStructureKHR                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMemoryToAccelerationStructureKHR")
	vtable.CmdCopyMemoryToImageIndirectNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMemoryToImageIndirectNV")
	vtable.CmdCopyMemoryToMicromapEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMemoryToMicromapEXT")
	vtable.CmdCopyMicromapEXT                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMicromapEXT")
	vtable.CmdCopyMicromapToMemoryEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyMicromapToMemoryEXT")
	vtable.CmdCopyQueryPoolResults                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCopyQueryPoolResults")
	vtable.CmdCuLaunchKernelNVX                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCuLaunchKernelNVX")
	vtable.CmdCudaLaunchKernelNV                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdCudaLaunchKernelNV")
	vtable.CmdDebugMarkerBeginEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDebugMarkerBeginEXT")
	vtable.CmdDebugMarkerEndEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDebugMarkerEndEXT")
	vtable.CmdDebugMarkerInsertEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDebugMarkerInsertEXT")
	vtable.CmdDecodeVideoKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDecodeVideoKHR")
	vtable.CmdDecompressMemoryIndirectCountNV                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDecompressMemoryIndirectCountNV")
	vtable.CmdDecompressMemoryNV                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDecompressMemoryNV")
	vtable.CmdDispatch                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDispatch")
	vtable.CmdDispatchBase                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDispatchBase")
	vtable.CmdDispatchBaseKHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDispatchBaseKHR")
	vtable.CmdDispatchIndirect                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDispatchIndirect")
	vtable.CmdDraw                                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDraw")
	vtable.CmdDrawClusterHUAWEI                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawClusterHUAWEI")
	vtable.CmdDrawClusterIndirectHUAWEI                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawClusterIndirectHUAWEI")
	vtable.CmdDrawIndexed                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndexed")
	vtable.CmdDrawIndexedIndirect                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndexedIndirect")
	vtable.CmdDrawIndexedIndirectCount                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndexedIndirectCount")
	vtable.CmdDrawIndexedIndirectCountAMD                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndexedIndirectCountAMD")
	vtable.CmdDrawIndexedIndirectCountKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndexedIndirectCountKHR")
	vtable.CmdDrawIndirect                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndirect")
	vtable.CmdDrawIndirectByteCountEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndirectByteCountEXT")
	vtable.CmdDrawIndirectCount                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndirectCount")
	vtable.CmdDrawIndirectCountAMD                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndirectCountAMD")
	vtable.CmdDrawIndirectCountKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawIndirectCountKHR")
	vtable.CmdDrawMeshTasksEXT                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksEXT")
	vtable.CmdDrawMeshTasksIndirectCountEXT                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksIndirectCountEXT")
	vtable.CmdDrawMeshTasksIndirectCountNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksIndirectCountNV")
	vtable.CmdDrawMeshTasksIndirectEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksIndirectEXT")
	vtable.CmdDrawMeshTasksIndirectNV                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksIndirectNV")
	vtable.CmdDrawMeshTasksNV                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMeshTasksNV")
	vtable.CmdDrawMultiEXT                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMultiEXT")
	vtable.CmdDrawMultiIndexedEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdDrawMultiIndexedEXT")
	vtable.CmdEncodeVideoKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEncodeVideoKHR")
	vtable.CmdEndConditionalRenderingEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndConditionalRenderingEXT")
	vtable.CmdEndDebugUtilsLabelEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndDebugUtilsLabelEXT")
	vtable.CmdEndQuery                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndQuery")
	vtable.CmdEndQueryIndexedEXT                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndQueryIndexedEXT")
	vtable.CmdEndRenderPass                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndRenderPass")
	vtable.CmdEndRenderPass2                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndRenderPass2")
	vtable.CmdEndRenderPass2KHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndRenderPass2KHR")
	vtable.CmdEndRendering                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndRendering")
	vtable.CmdEndRenderingKHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndRenderingKHR")
	vtable.CmdEndTransformFeedbackEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndTransformFeedbackEXT")
	vtable.CmdEndVideoCodingKHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdEndVideoCodingKHR")
	vtable.CmdExecuteCommands                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdExecuteCommands")
	vtable.CmdExecuteGeneratedCommandsEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdExecuteGeneratedCommandsEXT")
	vtable.CmdExecuteGeneratedCommandsNV                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdExecuteGeneratedCommandsNV")
	vtable.CmdFillBuffer                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdFillBuffer")
	vtable.CmdInsertDebugUtilsLabelEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdInsertDebugUtilsLabelEXT")
	vtable.CmdNextSubpass                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdNextSubpass")
	vtable.CmdNextSubpass2                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdNextSubpass2")
	vtable.CmdNextSubpass2KHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdNextSubpass2KHR")
	vtable.CmdOpticalFlowExecuteNV                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdOpticalFlowExecuteNV")
	vtable.CmdPipelineBarrier                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPipelineBarrier")
	vtable.CmdPipelineBarrier2                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPipelineBarrier2")
	vtable.CmdPipelineBarrier2KHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPipelineBarrier2KHR")
	vtable.CmdPreprocessGeneratedCommandsEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPreprocessGeneratedCommandsEXT")
	vtable.CmdPreprocessGeneratedCommandsNV                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPreprocessGeneratedCommandsNV")
	vtable.CmdPushConstants                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushConstants")
	vtable.CmdPushConstants2KHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushConstants2KHR")
	vtable.CmdPushDescriptorSet2KHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushDescriptorSet2KHR")
	vtable.CmdPushDescriptorSetKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushDescriptorSetKHR")
	vtable.CmdPushDescriptorSetWithTemplate2KHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushDescriptorSetWithTemplate2KHR")
	vtable.CmdPushDescriptorSetWithTemplateKHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdPushDescriptorSetWithTemplateKHR")
	vtable.CmdResetEvent                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResetEvent")
	vtable.CmdResetEvent2                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResetEvent2")
	vtable.CmdResetEvent2KHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResetEvent2KHR")
	vtable.CmdResetQueryPool                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResetQueryPool")
	vtable.CmdResolveImage                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResolveImage")
	vtable.CmdResolveImage2                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResolveImage2")
	vtable.CmdResolveImage2KHR                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdResolveImage2KHR")
	vtable.CmdSetAlphaToCoverageEnableEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetAlphaToCoverageEnableEXT")
	vtable.CmdSetAlphaToOneEnableEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetAlphaToOneEnableEXT")
	vtable.CmdSetAttachmentFeedbackLoopEnableEXT                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetAttachmentFeedbackLoopEnableEXT")
	vtable.CmdSetBlendConstants                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetBlendConstants")
	vtable.CmdSetCheckpointNV                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCheckpointNV")
	vtable.CmdSetCoarseSampleOrderNV                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoarseSampleOrderNV")
	vtable.CmdSetColorBlendAdvancedEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetColorBlendAdvancedEXT")
	vtable.CmdSetColorBlendEnableEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetColorBlendEnableEXT")
	vtable.CmdSetColorBlendEquationEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetColorBlendEquationEXT")
	vtable.CmdSetColorWriteMaskEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetColorWriteMaskEXT")
	vtable.CmdSetConservativeRasterizationModeEXT                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetConservativeRasterizationModeEXT")
	vtable.CmdSetCoverageModulationModeNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageModulationModeNV")
	vtable.CmdSetCoverageModulationTableEnableNV                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageModulationTableEnableNV")
	vtable.CmdSetCoverageModulationTableNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageModulationTableNV")
	vtable.CmdSetCoverageReductionModeNV                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageReductionModeNV")
	vtable.CmdSetCoverageToColorEnableNV                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageToColorEnableNV")
	vtable.CmdSetCoverageToColorLocationNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCoverageToColorLocationNV")
	vtable.CmdSetCullMode                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCullMode")
	vtable.CmdSetCullModeEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetCullModeEXT")
	vtable.CmdSetDepthBias                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBias")
	vtable.CmdSetDepthBias2EXT                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBias2EXT")
	vtable.CmdSetDepthBiasEnable                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBiasEnable")
	vtable.CmdSetDepthBiasEnableEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBiasEnableEXT")
	vtable.CmdSetDepthBounds                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBounds")
	vtable.CmdSetDepthBoundsTestEnable                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBoundsTestEnable")
	vtable.CmdSetDepthBoundsTestEnableEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthBoundsTestEnableEXT")
	vtable.CmdSetDepthClampEnableEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthClampEnableEXT")
	vtable.CmdSetDepthClampRangeEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthClampRangeEXT")
	vtable.CmdSetDepthClipEnableEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthClipEnableEXT")
	vtable.CmdSetDepthClipNegativeOneToOneEXT                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthClipNegativeOneToOneEXT")
	vtable.CmdSetDepthCompareOp                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthCompareOp")
	vtable.CmdSetDepthCompareOpEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthCompareOpEXT")
	vtable.CmdSetDepthTestEnable                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthTestEnable")
	vtable.CmdSetDepthTestEnableEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthTestEnableEXT")
	vtable.CmdSetDepthWriteEnable                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthWriteEnable")
	vtable.CmdSetDepthWriteEnableEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDepthWriteEnableEXT")
	vtable.CmdSetDescriptorBufferOffsets2EXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDescriptorBufferOffsets2EXT")
	vtable.CmdSetDescriptorBufferOffsetsEXT                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDescriptorBufferOffsetsEXT")
	vtable.CmdSetDeviceMask                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDeviceMask")
	vtable.CmdSetDeviceMaskKHR                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDeviceMaskKHR")
	vtable.CmdSetDiscardRectangleEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDiscardRectangleEXT")
	vtable.CmdSetDiscardRectangleEnableEXT                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDiscardRectangleEnableEXT")
	vtable.CmdSetDiscardRectangleModeEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetDiscardRectangleModeEXT")
	vtable.CmdSetEvent                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetEvent")
	vtable.CmdSetEvent2                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetEvent2")
	vtable.CmdSetEvent2KHR                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetEvent2KHR")
	vtable.CmdSetExclusiveScissorEnableNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetExclusiveScissorEnableNV")
	vtable.CmdSetExclusiveScissorNV                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetExclusiveScissorNV")
	vtable.CmdSetExtraPrimitiveOverestimationSizeEXT                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetExtraPrimitiveOverestimationSizeEXT")
	vtable.CmdSetFragmentShadingRateEnumNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetFragmentShadingRateEnumNV")
	vtable.CmdSetFragmentShadingRateKHR                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetFragmentShadingRateKHR")
	vtable.CmdSetFrontFace                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetFrontFace")
	vtable.CmdSetFrontFaceEXT                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetFrontFaceEXT")
	vtable.CmdSetLineRasterizationModeEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLineRasterizationModeEXT")
	vtable.CmdSetLineStippleEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLineStippleEXT")
	vtable.CmdSetLineStippleEnableEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLineStippleEnableEXT")
	vtable.CmdSetLineStippleKHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLineStippleKHR")
	vtable.CmdSetLineWidth                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLineWidth")
	vtable.CmdSetLogicOpEXT                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLogicOpEXT")
	vtable.CmdSetLogicOpEnableEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetLogicOpEnableEXT")
	vtable.CmdSetPatchControlPointsEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPatchControlPointsEXT")
	vtable.CmdSetPerformanceMarkerINTEL                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPerformanceMarkerINTEL")
	vtable.CmdSetPerformanceOverrideINTEL                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPerformanceOverrideINTEL")
	vtable.CmdSetPerformanceStreamMarkerINTEL                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPerformanceStreamMarkerINTEL")
	vtable.CmdSetPolygonModeEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPolygonModeEXT")
	vtable.CmdSetPrimitiveRestartEnable                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPrimitiveRestartEnable")
	vtable.CmdSetPrimitiveRestartEnableEXT                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPrimitiveRestartEnableEXT")
	vtable.CmdSetPrimitiveTopology                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPrimitiveTopology")
	vtable.CmdSetPrimitiveTopologyEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetPrimitiveTopologyEXT")
	vtable.CmdSetProvokingVertexModeEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetProvokingVertexModeEXT")
	vtable.CmdSetRasterizationSamplesEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRasterizationSamplesEXT")
	vtable.CmdSetRasterizationStreamEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRasterizationStreamEXT")
	vtable.CmdSetRasterizerDiscardEnable                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRasterizerDiscardEnable")
	vtable.CmdSetRasterizerDiscardEnableEXT                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRasterizerDiscardEnableEXT")
	vtable.CmdSetRayTracingPipelineStackSizeKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRayTracingPipelineStackSizeKHR")
	vtable.CmdSetRenderingAttachmentLocationsKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRenderingAttachmentLocationsKHR")
	vtable.CmdSetRenderingInputAttachmentIndicesKHR                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRenderingInputAttachmentIndicesKHR")
	vtable.CmdSetRepresentativeFragmentTestEnableNV                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetRepresentativeFragmentTestEnableNV")
	vtable.CmdSetSampleLocationsEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetSampleLocationsEXT")
	vtable.CmdSetSampleLocationsEnableEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetSampleLocationsEnableEXT")
	vtable.CmdSetSampleMaskEXT                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetSampleMaskEXT")
	vtable.CmdSetScissor                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetScissor")
	vtable.CmdSetScissorWithCount                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetScissorWithCount")
	vtable.CmdSetScissorWithCountEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetScissorWithCountEXT")
	vtable.CmdSetShadingRateImageEnableNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetShadingRateImageEnableNV")
	vtable.CmdSetStencilCompareMask                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilCompareMask")
	vtable.CmdSetStencilOp                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilOp")
	vtable.CmdSetStencilOpEXT                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilOpEXT")
	vtable.CmdSetStencilReference                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilReference")
	vtable.CmdSetStencilTestEnable                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilTestEnable")
	vtable.CmdSetStencilTestEnableEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilTestEnableEXT")
	vtable.CmdSetStencilWriteMask                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetStencilWriteMask")
	vtable.CmdSetTessellationDomainOriginEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetTessellationDomainOriginEXT")
	vtable.CmdSetVertexInputEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetVertexInputEXT")
	vtable.CmdSetViewport                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewport")
	vtable.CmdSetViewportShadingRatePaletteNV                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportShadingRatePaletteNV")
	vtable.CmdSetViewportSwizzleNV                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportSwizzleNV")
	vtable.CmdSetViewportWScalingEnableNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportWScalingEnableNV")
	vtable.CmdSetViewportWScalingNV                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportWScalingNV")
	vtable.CmdSetViewportWithCount                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportWithCount")
	vtable.CmdSetViewportWithCountEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSetViewportWithCountEXT")
	vtable.CmdSubpassShadingHUAWEI                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdSubpassShadingHUAWEI")
	vtable.CmdTraceRaysIndirect2KHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdTraceRaysIndirect2KHR")
	vtable.CmdTraceRaysIndirectKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdTraceRaysIndirectKHR")
	vtable.CmdTraceRaysKHR                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdTraceRaysKHR")
	vtable.CmdTraceRaysNV                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdTraceRaysNV")
	vtable.CmdUpdateBuffer                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdUpdateBuffer")
	vtable.CmdUpdatePipelineIndirectBufferNV                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdUpdatePipelineIndirectBufferNV")
	vtable.CmdWaitEvents                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWaitEvents")
	vtable.CmdWaitEvents2                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWaitEvents2")
	vtable.CmdWaitEvents2KHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWaitEvents2KHR")
	vtable.CmdWriteAccelerationStructuresPropertiesKHR                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteAccelerationStructuresPropertiesKHR")
	vtable.CmdWriteAccelerationStructuresPropertiesNV                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteAccelerationStructuresPropertiesNV")
	vtable.CmdWriteBufferMarker2AMD                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteBufferMarker2AMD")
	vtable.CmdWriteBufferMarkerAMD                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteBufferMarkerAMD")
	vtable.CmdWriteMicromapsPropertiesEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteMicromapsPropertiesEXT")
	vtable.CmdWriteTimestamp                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteTimestamp")
	vtable.CmdWriteTimestamp2                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteTimestamp2")
	vtable.CmdWriteTimestamp2KHR                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCmdWriteTimestamp2KHR")
	vtable.CompileDeferredNV                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCompileDeferredNV")
	vtable.CopyAccelerationStructureKHR                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyAccelerationStructureKHR")
	vtable.CopyAccelerationStructureToMemoryKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyAccelerationStructureToMemoryKHR")
	vtable.CopyImageToImageEXT                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyImageToImageEXT")
	vtable.CopyImageToMemoryEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyImageToMemoryEXT")
	vtable.CopyMemoryToAccelerationStructureKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyMemoryToAccelerationStructureKHR")
	vtable.CopyMemoryToImageEXT                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyMemoryToImageEXT")
	vtable.CopyMemoryToMicromapEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyMemoryToMicromapEXT")
	vtable.CopyMicromapEXT                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyMicromapEXT")
	vtable.CopyMicromapToMemoryEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCopyMicromapToMemoryEXT")
	vtable.CreateAccelerationStructureKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateAccelerationStructureKHR")
	vtable.CreateAccelerationStructureNV                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateAccelerationStructureNV")
	vtable.CreateBuffer                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateBuffer")
	vtable.CreateBufferView                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateBufferView")
	vtable.CreateCommandPool                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateCommandPool")
	vtable.CreateComputePipelines                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateComputePipelines")
	vtable.CreateCuFunctionNVX                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateCuFunctionNVX")
	vtable.CreateCuModuleNVX                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateCuModuleNVX")
	vtable.CreateCudaFunctionNV                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateCudaFunctionNV")
	vtable.CreateCudaModuleNV                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateCudaModuleNV")
	vtable.CreateDeferredOperationKHR                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDeferredOperationKHR")
	vtable.CreateDescriptorPool                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDescriptorPool")
	vtable.CreateDescriptorSetLayout                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDescriptorSetLayout")
	vtable.CreateDescriptorUpdateTemplate                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDescriptorUpdateTemplate")
	vtable.CreateDescriptorUpdateTemplateKHR                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateDescriptorUpdateTemplateKHR")
	vtable.CreateEvent                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateEvent")
	vtable.CreateFence                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateFence")
	vtable.CreateFramebuffer                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateFramebuffer")
	vtable.CreateGraphicsPipelines                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateGraphicsPipelines")
	vtable.CreateImage                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateImage")
	vtable.CreateImageView                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateImageView")
	vtable.CreateIndirectCommandsLayoutEXT                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateIndirectCommandsLayoutEXT")
	vtable.CreateIndirectCommandsLayoutNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateIndirectCommandsLayoutNV")
	vtable.CreateIndirectExecutionSetEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateIndirectExecutionSetEXT")
	vtable.CreateMicromapEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateMicromapEXT")
	vtable.CreateOpticalFlowSessionNV                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateOpticalFlowSessionNV")
	vtable.CreatePipelineBinariesKHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreatePipelineBinariesKHR")
	vtable.CreatePipelineCache                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreatePipelineCache")
	vtable.CreatePipelineLayout                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreatePipelineLayout")
	vtable.CreatePrivateDataSlot                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreatePrivateDataSlot")
	vtable.CreatePrivateDataSlotEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreatePrivateDataSlotEXT")
	vtable.CreateQueryPool                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateQueryPool")
	vtable.CreateRayTracingPipelinesKHR                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateRayTracingPipelinesKHR")
	vtable.CreateRayTracingPipelinesNV                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateRayTracingPipelinesNV")
	vtable.CreateRenderPass                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateRenderPass")
	vtable.CreateRenderPass2                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateRenderPass2")
	vtable.CreateRenderPass2KHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateRenderPass2KHR")
	vtable.CreateSampler                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSampler")
	vtable.CreateSamplerYcbcrConversion                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSamplerYcbcrConversion")
	vtable.CreateSamplerYcbcrConversionKHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSamplerYcbcrConversionKHR")
	vtable.CreateSemaphore                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSemaphore")
	vtable.CreateShaderModule                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateShaderModule")
	vtable.CreateShadersEXT                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateShadersEXT")
	vtable.CreateSharedSwapchainsKHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSharedSwapchainsKHR")
	vtable.CreateSwapchainKHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateSwapchainKHR")
	vtable.CreateValidationCacheEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateValidationCacheEXT")
	vtable.CreateVideoSessionKHR                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateVideoSessionKHR")
	vtable.CreateVideoSessionParametersKHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkCreateVideoSessionParametersKHR")
	vtable.DebugMarkerSetObjectNameEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkDebugMarkerSetObjectNameEXT")
	vtable.DebugMarkerSetObjectTagEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkDebugMarkerSetObjectTagEXT")
	vtable.DeferredOperationJoinKHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkDeferredOperationJoinKHR")
	vtable.DestroyAccelerationStructureKHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyAccelerationStructureKHR")
	vtable.DestroyAccelerationStructureNV                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyAccelerationStructureNV")
	vtable.DestroyBuffer                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyBuffer")
	vtable.DestroyBufferView                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyBufferView")
	vtable.DestroyCommandPool                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyCommandPool")
	vtable.DestroyCuFunctionNVX                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyCuFunctionNVX")
	vtable.DestroyCuModuleNVX                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyCuModuleNVX")
	vtable.DestroyCudaFunctionNV                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyCudaFunctionNV")
	vtable.DestroyCudaModuleNV                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyCudaModuleNV")
	vtable.DestroyDeferredOperationKHR                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDeferredOperationKHR")
	vtable.DestroyDescriptorPool                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDescriptorPool")
	vtable.DestroyDescriptorSetLayout                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDescriptorSetLayout")
	vtable.DestroyDescriptorUpdateTemplate                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDescriptorUpdateTemplate")
	vtable.DestroyDescriptorUpdateTemplateKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDescriptorUpdateTemplateKHR")
	vtable.DestroyDevice                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyDevice")
	vtable.DestroyEvent                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyEvent")
	vtable.DestroyFence                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyFence")
	vtable.DestroyFramebuffer                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyFramebuffer")
	vtable.DestroyImage                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyImage")
	vtable.DestroyImageView                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyImageView")
	vtable.DestroyIndirectCommandsLayoutEXT                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyIndirectCommandsLayoutEXT")
	vtable.DestroyIndirectCommandsLayoutNV                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyIndirectCommandsLayoutNV")
	vtable.DestroyIndirectExecutionSetEXT                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyIndirectExecutionSetEXT")
	vtable.DestroyMicromapEXT                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyMicromapEXT")
	vtable.DestroyOpticalFlowSessionNV                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyOpticalFlowSessionNV")
	vtable.DestroyPipeline                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPipeline")
	vtable.DestroyPipelineBinaryKHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPipelineBinaryKHR")
	vtable.DestroyPipelineCache                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPipelineCache")
	vtable.DestroyPipelineLayout                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPipelineLayout")
	vtable.DestroyPrivateDataSlot                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPrivateDataSlot")
	vtable.DestroyPrivateDataSlotEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyPrivateDataSlotEXT")
	vtable.DestroyQueryPool                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyQueryPool")
	vtable.DestroyRenderPass                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyRenderPass")
	vtable.DestroySampler                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySampler")
	vtable.DestroySamplerYcbcrConversion                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySamplerYcbcrConversion")
	vtable.DestroySamplerYcbcrConversionKHR                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySamplerYcbcrConversionKHR")
	vtable.DestroySemaphore                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySemaphore")
	vtable.DestroyShaderEXT                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyShaderEXT")
	vtable.DestroyShaderModule                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyShaderModule")
	vtable.DestroySwapchainKHR                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroySwapchainKHR")
	vtable.DestroyValidationCacheEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyValidationCacheEXT")
	vtable.DestroyVideoSessionKHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyVideoSessionKHR")
	vtable.DestroyVideoSessionParametersKHR                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkDestroyVideoSessionParametersKHR")
	vtable.DeviceWaitIdle                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkDeviceWaitIdle")
	vtable.DisplayPowerControlEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkDisplayPowerControlEXT")
	vtable.EndCommandBuffer                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkEndCommandBuffer")
	vtable.ExportMetalObjectsEXT                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkExportMetalObjectsEXT")
	vtable.FlushMappedMemoryRanges                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkFlushMappedMemoryRanges")
	vtable.FreeCommandBuffers                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkFreeCommandBuffers")
	vtable.FreeDescriptorSets                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkFreeDescriptorSets")
	vtable.FreeMemory                                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkFreeMemory")
	vtable.GetAccelerationStructureBuildSizesKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetAccelerationStructureBuildSizesKHR")
	vtable.GetAccelerationStructureDeviceAddressKHR                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetAccelerationStructureDeviceAddressKHR")
	vtable.GetAccelerationStructureHandleNV                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetAccelerationStructureHandleNV")
	vtable.GetAccelerationStructureMemoryRequirementsNV                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetAccelerationStructureMemoryRequirementsNV")
	vtable.GetAccelerationStructureOpaqueCaptureDescriptorDataEXT          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetAccelerationStructureOpaqueCaptureDescriptorDataEXT")
	vtable.GetBufferDeviceAddress                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferDeviceAddress")
	vtable.GetBufferDeviceAddressEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferDeviceAddressEXT")
	vtable.GetBufferDeviceAddressKHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferDeviceAddressKHR")
	vtable.GetBufferMemoryRequirements                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferMemoryRequirements")
	vtable.GetBufferMemoryRequirements2                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferMemoryRequirements2")
	vtable.GetBufferMemoryRequirements2KHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferMemoryRequirements2KHR")
	vtable.GetBufferOpaqueCaptureAddress                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferOpaqueCaptureAddress")
	vtable.GetBufferOpaqueCaptureAddressKHR                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferOpaqueCaptureAddressKHR")
	vtable.GetBufferOpaqueCaptureDescriptorDataEXT                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetBufferOpaqueCaptureDescriptorDataEXT")
	vtable.GetCalibratedTimestampsEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetCalibratedTimestampsEXT")
	vtable.GetCalibratedTimestampsKHR                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetCalibratedTimestampsKHR")
	vtable.GetCudaModuleCacheNV                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetCudaModuleCacheNV")
	vtable.GetDeferredOperationMaxConcurrencyKHR                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeferredOperationMaxConcurrencyKHR")
	vtable.GetDeferredOperationResultKHR                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeferredOperationResultKHR")
	vtable.GetDescriptorEXT                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorEXT")
	vtable.GetDescriptorSetHostMappingVALVE                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetHostMappingVALVE")
	vtable.GetDescriptorSetLayoutBindingOffsetEXT                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetLayoutBindingOffsetEXT")
	vtable.GetDescriptorSetLayoutHostMappingInfoVALVE                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetLayoutHostMappingInfoVALVE")
	vtable.GetDescriptorSetLayoutSizeEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetLayoutSizeEXT")
	vtable.GetDescriptorSetLayoutSupport                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetLayoutSupport")
	vtable.GetDescriptorSetLayoutSupportKHR                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDescriptorSetLayoutSupportKHR")
	vtable.GetDeviceAccelerationStructureCompatibilityKHR                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceAccelerationStructureCompatibilityKHR")
	vtable.GetDeviceBufferMemoryRequirements                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceBufferMemoryRequirements")
	vtable.GetDeviceBufferMemoryRequirementsKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceBufferMemoryRequirementsKHR")
	vtable.GetDeviceFaultInfoEXT                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceFaultInfoEXT")
	vtable.GetDeviceGroupPeerMemoryFeatures                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceGroupPeerMemoryFeatures")
	vtable.GetDeviceGroupPeerMemoryFeaturesKHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceGroupPeerMemoryFeaturesKHR")
	vtable.GetDeviceGroupPresentCapabilitiesKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceGroupPresentCapabilitiesKHR")
	vtable.GetDeviceGroupSurfacePresentModes2EXT                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceGroupSurfacePresentModes2EXT")
	vtable.GetDeviceGroupSurfacePresentModesKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceGroupSurfacePresentModesKHR")
	vtable.GetDeviceImageMemoryRequirements                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceImageMemoryRequirements")
	vtable.GetDeviceImageMemoryRequirementsKHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceImageMemoryRequirementsKHR")
	vtable.GetDeviceImageSparseMemoryRequirements                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceImageSparseMemoryRequirements")
	vtable.GetDeviceImageSparseMemoryRequirementsKHR                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceImageSparseMemoryRequirementsKHR")
	vtable.GetDeviceImageSubresourceLayoutKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceImageSubresourceLayoutKHR")
	vtable.GetDeviceMemoryCommitment                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceMemoryCommitment")
	vtable.GetDeviceMemoryOpaqueCaptureAddress                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceMemoryOpaqueCaptureAddress")
	vtable.GetDeviceMemoryOpaqueCaptureAddressKHR                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceMemoryOpaqueCaptureAddressKHR")
	vtable.GetDeviceMicromapCompatibilityEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceMicromapCompatibilityEXT")
	vtable.GetDeviceProcAddr                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceProcAddr")
	vtable.GetDeviceQueue                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceQueue")
	vtable.GetDeviceQueue2                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceQueue2")
	vtable.GetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI")
	vtable.GetDynamicRenderingTilePropertiesQCOM                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetDynamicRenderingTilePropertiesQCOM")
	vtable.GetEncodedVideoSessionParametersKHR                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetEncodedVideoSessionParametersKHR")
	vtable.GetEventStatus                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetEventStatus")
	vtable.GetFenceFdKHR                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetFenceFdKHR")
	vtable.GetFenceStatus                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetFenceStatus")
	vtable.GetFenceWin32HandleKHR                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetFenceWin32HandleKHR")
	vtable.GetFramebufferTilePropertiesQCOM                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetFramebufferTilePropertiesQCOM")
	vtable.GetGeneratedCommandsMemoryRequirementsEXT                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetGeneratedCommandsMemoryRequirementsEXT")
	vtable.GetGeneratedCommandsMemoryRequirementsNV                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetGeneratedCommandsMemoryRequirementsNV")
	vtable.GetImageDrmFormatModifierPropertiesEXT                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageDrmFormatModifierPropertiesEXT")
	vtable.GetImageMemoryRequirements                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageMemoryRequirements")
	vtable.GetImageMemoryRequirements2                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageMemoryRequirements2")
	vtable.GetImageMemoryRequirements2KHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageMemoryRequirements2KHR")
	vtable.GetImageOpaqueCaptureDescriptorDataEXT                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageOpaqueCaptureDescriptorDataEXT")
	vtable.GetImageSparseMemoryRequirements                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSparseMemoryRequirements")
	vtable.GetImageSparseMemoryRequirements2                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSparseMemoryRequirements2")
	vtable.GetImageSparseMemoryRequirements2KHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSparseMemoryRequirements2KHR")
	vtable.GetImageSubresourceLayout                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSubresourceLayout")
	vtable.GetImageSubresourceLayout2EXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSubresourceLayout2EXT")
	vtable.GetImageSubresourceLayout2KHR                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageSubresourceLayout2KHR")
	vtable.GetImageViewAddressNVX                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageViewAddressNVX")
	vtable.GetImageViewHandleNVX                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageViewHandleNVX")
	vtable.GetImageViewOpaqueCaptureDescriptorDataEXT                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetImageViewOpaqueCaptureDescriptorDataEXT")
	vtable.GetLatencyTimingsNV                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetLatencyTimingsNV")
	vtable.GetMemoryFdKHR                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryFdKHR")
	vtable.GetMemoryFdPropertiesKHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryFdPropertiesKHR")
	vtable.GetMemoryHostPointerPropertiesEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryHostPointerPropertiesEXT")
	vtable.GetMemoryRemoteAddressNV                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryRemoteAddressNV")
	vtable.GetMemoryWin32HandleKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryWin32HandleKHR")
	vtable.GetMemoryWin32HandleNV                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryWin32HandleNV")
	vtable.GetMemoryWin32HandlePropertiesKHR                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMemoryWin32HandlePropertiesKHR")
	vtable.GetMicromapBuildSizesEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetMicromapBuildSizesEXT")
	vtable.GetPastPresentationTimingGOOGLE                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPastPresentationTimingGOOGLE")
	vtable.GetPerformanceParameterINTEL                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPerformanceParameterINTEL")
	vtable.GetPipelineBinaryDataKHR                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineBinaryDataKHR")
	vtable.GetPipelineCacheData                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineCacheData")
	vtable.GetPipelineExecutableInternalRepresentationsKHR                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineExecutableInternalRepresentationsKHR")
	vtable.GetPipelineExecutablePropertiesKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineExecutablePropertiesKHR")
	vtable.GetPipelineExecutableStatisticsKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineExecutableStatisticsKHR")
	vtable.GetPipelineIndirectDeviceAddressNV                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineIndirectDeviceAddressNV")
	vtable.GetPipelineIndirectMemoryRequirementsNV                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineIndirectMemoryRequirementsNV")
	vtable.GetPipelineKeyKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelineKeyKHR")
	vtable.GetPipelinePropertiesEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPipelinePropertiesEXT")
	vtable.GetPrivateData                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPrivateData")
	vtable.GetPrivateDataEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetPrivateDataEXT")
	vtable.GetQueryPoolResults                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetQueryPoolResults")
	vtable.GetQueueCheckpointData2NV                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetQueueCheckpointData2NV")
	vtable.GetQueueCheckpointDataNV                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetQueueCheckpointDataNV")
	vtable.GetRayTracingCaptureReplayShaderGroupHandlesKHR                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRayTracingCaptureReplayShaderGroupHandlesKHR")
	vtable.GetRayTracingShaderGroupHandlesKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRayTracingShaderGroupHandlesKHR")
	vtable.GetRayTracingShaderGroupHandlesNV                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRayTracingShaderGroupHandlesNV")
	vtable.GetRayTracingShaderGroupStackSizeKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRayTracingShaderGroupStackSizeKHR")
	vtable.GetRefreshCycleDurationGOOGLE                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRefreshCycleDurationGOOGLE")
	vtable.GetRenderAreaGranularity                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRenderAreaGranularity")
	vtable.GetRenderingAreaGranularityKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetRenderingAreaGranularityKHR")
	vtable.GetSamplerOpaqueCaptureDescriptorDataEXT                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSamplerOpaqueCaptureDescriptorDataEXT")
	vtable.GetSemaphoreCounterValue                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSemaphoreCounterValue")
	vtable.GetSemaphoreCounterValueKHR                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSemaphoreCounterValueKHR")
	vtable.GetSemaphoreFdKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSemaphoreFdKHR")
	vtable.GetSemaphoreWin32HandleKHR                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSemaphoreWin32HandleKHR")
	vtable.GetShaderBinaryDataEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetShaderBinaryDataEXT")
	vtable.GetShaderInfoAMD                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetShaderInfoAMD")
	vtable.GetShaderModuleCreateInfoIdentifierEXT                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetShaderModuleCreateInfoIdentifierEXT")
	vtable.GetShaderModuleIdentifierEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetShaderModuleIdentifierEXT")
	vtable.GetSwapchainCounterEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSwapchainCounterEXT")
	vtable.GetSwapchainImagesKHR                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSwapchainImagesKHR")
	vtable.GetSwapchainStatusKHR                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetSwapchainStatusKHR")
	vtable.GetValidationCacheDataEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetValidationCacheDataEXT")
	vtable.GetVideoSessionMemoryRequirementsKHR                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkGetVideoSessionMemoryRequirementsKHR")
	vtable.ImportFenceFdKHR                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkImportFenceFdKHR")
	vtable.ImportFenceWin32HandleKHR                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkImportFenceWin32HandleKHR")
	vtable.ImportSemaphoreFdKHR                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkImportSemaphoreFdKHR")
	vtable.ImportSemaphoreWin32HandleKHR                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkImportSemaphoreWin32HandleKHR")
	vtable.InitializePerformanceApiINTEL                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkInitializePerformanceApiINTEL")
	vtable.InvalidateMappedMemoryRanges                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkInvalidateMappedMemoryRanges")
	vtable.LatencySleepNV                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkLatencySleepNV")
	vtable.MapMemory                                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkMapMemory")
	vtable.MapMemory2KHR                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkMapMemory2KHR")
	vtable.MergePipelineCaches                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkMergePipelineCaches")
	vtable.MergeValidationCachesEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkMergeValidationCachesEXT")
	vtable.QueueBeginDebugUtilsLabelEXT                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueBeginDebugUtilsLabelEXT")
	vtable.QueueBindSparse                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueBindSparse")
	vtable.QueueEndDebugUtilsLabelEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueEndDebugUtilsLabelEXT")
	vtable.QueueInsertDebugUtilsLabelEXT                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueInsertDebugUtilsLabelEXT")
	vtable.QueueNotifyOutOfBandNV                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueNotifyOutOfBandNV")
	vtable.QueuePresentKHR                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueuePresentKHR")
	vtable.QueueSetPerformanceConfigurationINTEL                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueSetPerformanceConfigurationINTEL")
	vtable.QueueSubmit                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueSubmit")
	vtable.QueueSubmit2                                                    = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueSubmit2")
	vtable.QueueSubmit2KHR                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueSubmit2KHR")
	vtable.QueueWaitIdle                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkQueueWaitIdle")
	vtable.RegisterDeviceEventEXT                                          = auto_cast vtable.GetInstanceProcAddr(instance, "vkRegisterDeviceEventEXT")
	vtable.RegisterDisplayEventEXT                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkRegisterDisplayEventEXT")
	vtable.ReleaseCapturedPipelineDataKHR                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleaseCapturedPipelineDataKHR")
	vtable.ReleaseFullScreenExclusiveModeEXT                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleaseFullScreenExclusiveModeEXT")
	vtable.ReleasePerformanceConfigurationINTEL                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleasePerformanceConfigurationINTEL")
	vtable.ReleaseProfilingLockKHR                                         = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleaseProfilingLockKHR")
	vtable.ReleaseSwapchainImagesEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkReleaseSwapchainImagesEXT")
	vtable.ResetCommandBuffer                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetCommandBuffer")
	vtable.ResetCommandPool                                                = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetCommandPool")
	vtable.ResetDescriptorPool                                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetDescriptorPool")
	vtable.ResetEvent                                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetEvent")
	vtable.ResetFences                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetFences")
	vtable.ResetQueryPool                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetQueryPool")
	vtable.ResetQueryPoolEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkResetQueryPoolEXT")
	vtable.SetDebugUtilsObjectNameEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetDebugUtilsObjectNameEXT")
	vtable.SetDebugUtilsObjectTagEXT                                       = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetDebugUtilsObjectTagEXT")
	vtable.SetDeviceMemoryPriorityEXT                                      = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetDeviceMemoryPriorityEXT")
	vtable.SetEvent                                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetEvent")
	vtable.SetHdrMetadataEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetHdrMetadataEXT")
	vtable.SetLatencyMarkerNV                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetLatencyMarkerNV")
	vtable.SetLatencySleepModeNV                                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetLatencySleepModeNV")
	vtable.SetLocalDimmingAMD                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetLocalDimmingAMD")
	vtable.SetPrivateData                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetPrivateData")
	vtable.SetPrivateDataEXT                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkSetPrivateDataEXT")
	vtable.SignalSemaphore                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkSignalSemaphore")
	vtable.SignalSemaphoreKHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkSignalSemaphoreKHR")
	vtable.TransitionImageLayoutEXT                                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkTransitionImageLayoutEXT")
	vtable.TrimCommandPool                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkTrimCommandPool")
	vtable.TrimCommandPoolKHR                                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkTrimCommandPoolKHR")
	vtable.UninitializePerformanceApiINTEL                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkUninitializePerformanceApiINTEL")
	vtable.UnmapMemory                                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkUnmapMemory")
	vtable.UnmapMemory2KHR                                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkUnmapMemory2KHR")
	vtable.UpdateDescriptorSetWithTemplate                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateDescriptorSetWithTemplate")
	vtable.UpdateDescriptorSetWithTemplateKHR                              = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateDescriptorSetWithTemplateKHR")
	vtable.UpdateDescriptorSets                                            = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateDescriptorSets")
	vtable.UpdateIndirectExecutionSetPipelineEXT                           = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateIndirectExecutionSetPipelineEXT")
	vtable.UpdateIndirectExecutionSetShaderEXT                             = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateIndirectExecutionSetShaderEXT")
	vtable.UpdateVideoSessionParametersKHR                                 = auto_cast vtable.GetInstanceProcAddr(instance, "vkUpdateVideoSessionParametersKHR")
	vtable.WaitForFences                                                   = auto_cast vtable.GetInstanceProcAddr(instance, "vkWaitForFences")
	vtable.WaitForPresentKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkWaitForPresentKHR")
	vtable.WaitSemaphores                                                  = auto_cast vtable.GetInstanceProcAddr(instance, "vkWaitSemaphores")
	vtable.WaitSemaphoresKHR                                               = auto_cast vtable.GetInstanceProcAddr(instance, "vkWaitSemaphoresKHR")
	vtable.WriteAccelerationStructuresPropertiesKHR                        = auto_cast vtable.GetInstanceProcAddr(instance, "vkWriteAccelerationStructuresPropertiesKHR")
	vtable.WriteMicromapsPropertiesEXT                                     = auto_cast vtable.GetInstanceProcAddr(instance, "vkWriteMicromapsPropertiesEXT")
}

load_proc_addresses_device_vtable :: proc(device: Device, vtable: ^VTable) {
	vtable.AcquireFullScreenExclusiveModeEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkAcquireFullScreenExclusiveModeEXT")
	vtable.AcquireNextImage2KHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkAcquireNextImage2KHR")
	vtable.AcquireNextImageKHR                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkAcquireNextImageKHR")
	vtable.AcquirePerformanceConfigurationINTEL                   = auto_cast vtable.GetDeviceProcAddr(device, "vkAcquirePerformanceConfigurationINTEL")
	vtable.AcquireProfilingLockKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkAcquireProfilingLockKHR")
	vtable.AllocateCommandBuffers                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkAllocateCommandBuffers")
	vtable.AllocateDescriptorSets                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkAllocateDescriptorSets")
	vtable.AllocateMemory                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkAllocateMemory")
	vtable.AntiLagUpdateAMD                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkAntiLagUpdateAMD")
	vtable.BeginCommandBuffer                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkBeginCommandBuffer")
	vtable.BindAccelerationStructureMemoryNV                      = auto_cast vtable.GetDeviceProcAddr(device, "vkBindAccelerationStructureMemoryNV")
	vtable.BindBufferMemory                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkBindBufferMemory")
	vtable.BindBufferMemory2                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkBindBufferMemory2")
	vtable.BindBufferMemory2KHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkBindBufferMemory2KHR")
	vtable.BindImageMemory                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkBindImageMemory")
	vtable.BindImageMemory2                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkBindImageMemory2")
	vtable.BindImageMemory2KHR                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkBindImageMemory2KHR")
	vtable.BindOpticalFlowSessionImageNV                          = auto_cast vtable.GetDeviceProcAddr(device, "vkBindOpticalFlowSessionImageNV")
	vtable.BindVideoSessionMemoryKHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkBindVideoSessionMemoryKHR")
	vtable.BuildAccelerationStructuresKHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkBuildAccelerationStructuresKHR")
	vtable.BuildMicromapsEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkBuildMicromapsEXT")
	vtable.CmdBeginConditionalRenderingEXT                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginConditionalRenderingEXT")
	vtable.CmdBeginDebugUtilsLabelEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginDebugUtilsLabelEXT")
	vtable.CmdBeginQuery                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginQuery")
	vtable.CmdBeginQueryIndexedEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginQueryIndexedEXT")
	vtable.CmdBeginRenderPass                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginRenderPass")
	vtable.CmdBeginRenderPass2                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginRenderPass2")
	vtable.CmdBeginRenderPass2KHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginRenderPass2KHR")
	vtable.CmdBeginRendering                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginRendering")
	vtable.CmdBeginRenderingKHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginRenderingKHR")
	vtable.CmdBeginTransformFeedbackEXT                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginTransformFeedbackEXT")
	vtable.CmdBeginVideoCodingKHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBeginVideoCodingKHR")
	vtable.CmdBindDescriptorBufferEmbeddedSamplers2EXT            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindDescriptorBufferEmbeddedSamplers2EXT")
	vtable.CmdBindDescriptorBufferEmbeddedSamplersEXT             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindDescriptorBufferEmbeddedSamplersEXT")
	vtable.CmdBindDescriptorBuffersEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindDescriptorBuffersEXT")
	vtable.CmdBindDescriptorSets                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindDescriptorSets")
	vtable.CmdBindDescriptorSets2KHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindDescriptorSets2KHR")
	vtable.CmdBindIndexBuffer                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindIndexBuffer")
	vtable.CmdBindIndexBuffer2KHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindIndexBuffer2KHR")
	vtable.CmdBindInvocationMaskHUAWEI                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindInvocationMaskHUAWEI")
	vtable.CmdBindPipeline                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindPipeline")
	vtable.CmdBindPipelineShaderGroupNV                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindPipelineShaderGroupNV")
	vtable.CmdBindShadersEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindShadersEXT")
	vtable.CmdBindShadingRateImageNV                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindShadingRateImageNV")
	vtable.CmdBindTransformFeedbackBuffersEXT                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindTransformFeedbackBuffersEXT")
	vtable.CmdBindVertexBuffers                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindVertexBuffers")
	vtable.CmdBindVertexBuffers2                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindVertexBuffers2")
	vtable.CmdBindVertexBuffers2EXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBindVertexBuffers2EXT")
	vtable.CmdBlitImage                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBlitImage")
	vtable.CmdBlitImage2                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBlitImage2")
	vtable.CmdBlitImage2KHR                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBlitImage2KHR")
	vtable.CmdBuildAccelerationStructureNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBuildAccelerationStructureNV")
	vtable.CmdBuildAccelerationStructuresIndirectKHR              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBuildAccelerationStructuresIndirectKHR")
	vtable.CmdBuildAccelerationStructuresKHR                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBuildAccelerationStructuresKHR")
	vtable.CmdBuildMicromapsEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdBuildMicromapsEXT")
	vtable.CmdClearAttachments                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdClearAttachments")
	vtable.CmdClearColorImage                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdClearColorImage")
	vtable.CmdClearDepthStencilImage                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdClearDepthStencilImage")
	vtable.CmdControlVideoCodingKHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdControlVideoCodingKHR")
	vtable.CmdCopyAccelerationStructureKHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyAccelerationStructureKHR")
	vtable.CmdCopyAccelerationStructureNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyAccelerationStructureNV")
	vtable.CmdCopyAccelerationStructureToMemoryKHR                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyAccelerationStructureToMemoryKHR")
	vtable.CmdCopyBuffer                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBuffer")
	vtable.CmdCopyBuffer2                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBuffer2")
	vtable.CmdCopyBuffer2KHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBuffer2KHR")
	vtable.CmdCopyBufferToImage                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBufferToImage")
	vtable.CmdCopyBufferToImage2                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBufferToImage2")
	vtable.CmdCopyBufferToImage2KHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyBufferToImage2KHR")
	vtable.CmdCopyImage                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImage")
	vtable.CmdCopyImage2                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImage2")
	vtable.CmdCopyImage2KHR                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImage2KHR")
	vtable.CmdCopyImageToBuffer                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImageToBuffer")
	vtable.CmdCopyImageToBuffer2                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImageToBuffer2")
	vtable.CmdCopyImageToBuffer2KHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyImageToBuffer2KHR")
	vtable.CmdCopyMemoryIndirectNV                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMemoryIndirectNV")
	vtable.CmdCopyMemoryToAccelerationStructureKHR                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMemoryToAccelerationStructureKHR")
	vtable.CmdCopyMemoryToImageIndirectNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMemoryToImageIndirectNV")
	vtable.CmdCopyMemoryToMicromapEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMemoryToMicromapEXT")
	vtable.CmdCopyMicromapEXT                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMicromapEXT")
	vtable.CmdCopyMicromapToMemoryEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyMicromapToMemoryEXT")
	vtable.CmdCopyQueryPoolResults                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCopyQueryPoolResults")
	vtable.CmdCuLaunchKernelNVX                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCuLaunchKernelNVX")
	vtable.CmdCudaLaunchKernelNV                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdCudaLaunchKernelNV")
	vtable.CmdDebugMarkerBeginEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDebugMarkerBeginEXT")
	vtable.CmdDebugMarkerEndEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDebugMarkerEndEXT")
	vtable.CmdDebugMarkerInsertEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDebugMarkerInsertEXT")
	vtable.CmdDecodeVideoKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDecodeVideoKHR")
	vtable.CmdDecompressMemoryIndirectCountNV                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDecompressMemoryIndirectCountNV")
	vtable.CmdDecompressMemoryNV                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDecompressMemoryNV")
	vtable.CmdDispatch                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDispatch")
	vtable.CmdDispatchBase                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDispatchBase")
	vtable.CmdDispatchBaseKHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDispatchBaseKHR")
	vtable.CmdDispatchIndirect                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDispatchIndirect")
	vtable.CmdDraw                                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDraw")
	vtable.CmdDrawClusterHUAWEI                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawClusterHUAWEI")
	vtable.CmdDrawClusterIndirectHUAWEI                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawClusterIndirectHUAWEI")
	vtable.CmdDrawIndexed                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndexed")
	vtable.CmdDrawIndexedIndirect                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndexedIndirect")
	vtable.CmdDrawIndexedIndirectCount                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndexedIndirectCount")
	vtable.CmdDrawIndexedIndirectCountAMD                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndexedIndirectCountAMD")
	vtable.CmdDrawIndexedIndirectCountKHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndexedIndirectCountKHR")
	vtable.CmdDrawIndirect                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndirect")
	vtable.CmdDrawIndirectByteCountEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndirectByteCountEXT")
	vtable.CmdDrawIndirectCount                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndirectCount")
	vtable.CmdDrawIndirectCountAMD                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndirectCountAMD")
	vtable.CmdDrawIndirectCountKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawIndirectCountKHR")
	vtable.CmdDrawMeshTasksEXT                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksEXT")
	vtable.CmdDrawMeshTasksIndirectCountEXT                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksIndirectCountEXT")
	vtable.CmdDrawMeshTasksIndirectCountNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksIndirectCountNV")
	vtable.CmdDrawMeshTasksIndirectEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksIndirectEXT")
	vtable.CmdDrawMeshTasksIndirectNV                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksIndirectNV")
	vtable.CmdDrawMeshTasksNV                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMeshTasksNV")
	vtable.CmdDrawMultiEXT                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMultiEXT")
	vtable.CmdDrawMultiIndexedEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdDrawMultiIndexedEXT")
	vtable.CmdEncodeVideoKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEncodeVideoKHR")
	vtable.CmdEndConditionalRenderingEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndConditionalRenderingEXT")
	vtable.CmdEndDebugUtilsLabelEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndDebugUtilsLabelEXT")
	vtable.CmdEndQuery                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndQuery")
	vtable.CmdEndQueryIndexedEXT                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndQueryIndexedEXT")
	vtable.CmdEndRenderPass                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndRenderPass")
	vtable.CmdEndRenderPass2                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndRenderPass2")
	vtable.CmdEndRenderPass2KHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndRenderPass2KHR")
	vtable.CmdEndRendering                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndRendering")
	vtable.CmdEndRenderingKHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndRenderingKHR")
	vtable.CmdEndTransformFeedbackEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndTransformFeedbackEXT")
	vtable.CmdEndVideoCodingKHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdEndVideoCodingKHR")
	vtable.CmdExecuteCommands                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdExecuteCommands")
	vtable.CmdExecuteGeneratedCommandsEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdExecuteGeneratedCommandsEXT")
	vtable.CmdExecuteGeneratedCommandsNV                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdExecuteGeneratedCommandsNV")
	vtable.CmdFillBuffer                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdFillBuffer")
	vtable.CmdInsertDebugUtilsLabelEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdInsertDebugUtilsLabelEXT")
	vtable.CmdNextSubpass                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdNextSubpass")
	vtable.CmdNextSubpass2                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdNextSubpass2")
	vtable.CmdNextSubpass2KHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdNextSubpass2KHR")
	vtable.CmdOpticalFlowExecuteNV                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdOpticalFlowExecuteNV")
	vtable.CmdPipelineBarrier                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPipelineBarrier")
	vtable.CmdPipelineBarrier2                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPipelineBarrier2")
	vtable.CmdPipelineBarrier2KHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPipelineBarrier2KHR")
	vtable.CmdPreprocessGeneratedCommandsEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPreprocessGeneratedCommandsEXT")
	vtable.CmdPreprocessGeneratedCommandsNV                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPreprocessGeneratedCommandsNV")
	vtable.CmdPushConstants                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushConstants")
	vtable.CmdPushConstants2KHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushConstants2KHR")
	vtable.CmdPushDescriptorSet2KHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushDescriptorSet2KHR")
	vtable.CmdPushDescriptorSetKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushDescriptorSetKHR")
	vtable.CmdPushDescriptorSetWithTemplate2KHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushDescriptorSetWithTemplate2KHR")
	vtable.CmdPushDescriptorSetWithTemplateKHR                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdPushDescriptorSetWithTemplateKHR")
	vtable.CmdResetEvent                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResetEvent")
	vtable.CmdResetEvent2                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResetEvent2")
	vtable.CmdResetEvent2KHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResetEvent2KHR")
	vtable.CmdResetQueryPool                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResetQueryPool")
	vtable.CmdResolveImage                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResolveImage")
	vtable.CmdResolveImage2                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResolveImage2")
	vtable.CmdResolveImage2KHR                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdResolveImage2KHR")
	vtable.CmdSetAlphaToCoverageEnableEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetAlphaToCoverageEnableEXT")
	vtable.CmdSetAlphaToOneEnableEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetAlphaToOneEnableEXT")
	vtable.CmdSetAttachmentFeedbackLoopEnableEXT                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetAttachmentFeedbackLoopEnableEXT")
	vtable.CmdSetBlendConstants                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetBlendConstants")
	vtable.CmdSetCheckpointNV                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCheckpointNV")
	vtable.CmdSetCoarseSampleOrderNV                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoarseSampleOrderNV")
	vtable.CmdSetColorBlendAdvancedEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetColorBlendAdvancedEXT")
	vtable.CmdSetColorBlendEnableEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetColorBlendEnableEXT")
	vtable.CmdSetColorBlendEquationEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetColorBlendEquationEXT")
	vtable.CmdSetColorWriteMaskEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetColorWriteMaskEXT")
	vtable.CmdSetConservativeRasterizationModeEXT                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetConservativeRasterizationModeEXT")
	vtable.CmdSetCoverageModulationModeNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageModulationModeNV")
	vtable.CmdSetCoverageModulationTableEnableNV                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageModulationTableEnableNV")
	vtable.CmdSetCoverageModulationTableNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageModulationTableNV")
	vtable.CmdSetCoverageReductionModeNV                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageReductionModeNV")
	vtable.CmdSetCoverageToColorEnableNV                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageToColorEnableNV")
	vtable.CmdSetCoverageToColorLocationNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCoverageToColorLocationNV")
	vtable.CmdSetCullMode                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCullMode")
	vtable.CmdSetCullModeEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetCullModeEXT")
	vtable.CmdSetDepthBias                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBias")
	vtable.CmdSetDepthBias2EXT                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBias2EXT")
	vtable.CmdSetDepthBiasEnable                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBiasEnable")
	vtable.CmdSetDepthBiasEnableEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBiasEnableEXT")
	vtable.CmdSetDepthBounds                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBounds")
	vtable.CmdSetDepthBoundsTestEnable                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBoundsTestEnable")
	vtable.CmdSetDepthBoundsTestEnableEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthBoundsTestEnableEXT")
	vtable.CmdSetDepthClampEnableEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthClampEnableEXT")
	vtable.CmdSetDepthClampRangeEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthClampRangeEXT")
	vtable.CmdSetDepthClipEnableEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthClipEnableEXT")
	vtable.CmdSetDepthClipNegativeOneToOneEXT                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthClipNegativeOneToOneEXT")
	vtable.CmdSetDepthCompareOp                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthCompareOp")
	vtable.CmdSetDepthCompareOpEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthCompareOpEXT")
	vtable.CmdSetDepthTestEnable                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthTestEnable")
	vtable.CmdSetDepthTestEnableEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthTestEnableEXT")
	vtable.CmdSetDepthWriteEnable                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthWriteEnable")
	vtable.CmdSetDepthWriteEnableEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDepthWriteEnableEXT")
	vtable.CmdSetDescriptorBufferOffsets2EXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDescriptorBufferOffsets2EXT")
	vtable.CmdSetDescriptorBufferOffsetsEXT                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDescriptorBufferOffsetsEXT")
	vtable.CmdSetDeviceMask                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDeviceMask")
	vtable.CmdSetDeviceMaskKHR                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDeviceMaskKHR")
	vtable.CmdSetDiscardRectangleEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDiscardRectangleEXT")
	vtable.CmdSetDiscardRectangleEnableEXT                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDiscardRectangleEnableEXT")
	vtable.CmdSetDiscardRectangleModeEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetDiscardRectangleModeEXT")
	vtable.CmdSetEvent                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetEvent")
	vtable.CmdSetEvent2                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetEvent2")
	vtable.CmdSetEvent2KHR                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetEvent2KHR")
	vtable.CmdSetExclusiveScissorEnableNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetExclusiveScissorEnableNV")
	vtable.CmdSetExclusiveScissorNV                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetExclusiveScissorNV")
	vtable.CmdSetExtraPrimitiveOverestimationSizeEXT              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetExtraPrimitiveOverestimationSizeEXT")
	vtable.CmdSetFragmentShadingRateEnumNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetFragmentShadingRateEnumNV")
	vtable.CmdSetFragmentShadingRateKHR                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetFragmentShadingRateKHR")
	vtable.CmdSetFrontFace                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetFrontFace")
	vtable.CmdSetFrontFaceEXT                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetFrontFaceEXT")
	vtable.CmdSetLineRasterizationModeEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLineRasterizationModeEXT")
	vtable.CmdSetLineStippleEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLineStippleEXT")
	vtable.CmdSetLineStippleEnableEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLineStippleEnableEXT")
	vtable.CmdSetLineStippleKHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLineStippleKHR")
	vtable.CmdSetLineWidth                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLineWidth")
	vtable.CmdSetLogicOpEXT                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLogicOpEXT")
	vtable.CmdSetLogicOpEnableEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetLogicOpEnableEXT")
	vtable.CmdSetPatchControlPointsEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPatchControlPointsEXT")
	vtable.CmdSetPerformanceMarkerINTEL                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPerformanceMarkerINTEL")
	vtable.CmdSetPerformanceOverrideINTEL                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPerformanceOverrideINTEL")
	vtable.CmdSetPerformanceStreamMarkerINTEL                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPerformanceStreamMarkerINTEL")
	vtable.CmdSetPolygonModeEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPolygonModeEXT")
	vtable.CmdSetPrimitiveRestartEnable                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPrimitiveRestartEnable")
	vtable.CmdSetPrimitiveRestartEnableEXT                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPrimitiveRestartEnableEXT")
	vtable.CmdSetPrimitiveTopology                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPrimitiveTopology")
	vtable.CmdSetPrimitiveTopologyEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetPrimitiveTopologyEXT")
	vtable.CmdSetProvokingVertexModeEXT                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetProvokingVertexModeEXT")
	vtable.CmdSetRasterizationSamplesEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRasterizationSamplesEXT")
	vtable.CmdSetRasterizationStreamEXT                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRasterizationStreamEXT")
	vtable.CmdSetRasterizerDiscardEnable                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRasterizerDiscardEnable")
	vtable.CmdSetRasterizerDiscardEnableEXT                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRasterizerDiscardEnableEXT")
	vtable.CmdSetRayTracingPipelineStackSizeKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRayTracingPipelineStackSizeKHR")
	vtable.CmdSetRenderingAttachmentLocationsKHR                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRenderingAttachmentLocationsKHR")
	vtable.CmdSetRenderingInputAttachmentIndicesKHR               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRenderingInputAttachmentIndicesKHR")
	vtable.CmdSetRepresentativeFragmentTestEnableNV               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetRepresentativeFragmentTestEnableNV")
	vtable.CmdSetSampleLocationsEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetSampleLocationsEXT")
	vtable.CmdSetSampleLocationsEnableEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetSampleLocationsEnableEXT")
	vtable.CmdSetSampleMaskEXT                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetSampleMaskEXT")
	vtable.CmdSetScissor                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetScissor")
	vtable.CmdSetScissorWithCount                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetScissorWithCount")
	vtable.CmdSetScissorWithCountEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetScissorWithCountEXT")
	vtable.CmdSetShadingRateImageEnableNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetShadingRateImageEnableNV")
	vtable.CmdSetStencilCompareMask                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilCompareMask")
	vtable.CmdSetStencilOp                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilOp")
	vtable.CmdSetStencilOpEXT                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilOpEXT")
	vtable.CmdSetStencilReference                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilReference")
	vtable.CmdSetStencilTestEnable                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilTestEnable")
	vtable.CmdSetStencilTestEnableEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilTestEnableEXT")
	vtable.CmdSetStencilWriteMask                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetStencilWriteMask")
	vtable.CmdSetTessellationDomainOriginEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetTessellationDomainOriginEXT")
	vtable.CmdSetVertexInputEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetVertexInputEXT")
	vtable.CmdSetViewport                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewport")
	vtable.CmdSetViewportShadingRatePaletteNV                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportShadingRatePaletteNV")
	vtable.CmdSetViewportSwizzleNV                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportSwizzleNV")
	vtable.CmdSetViewportWScalingEnableNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportWScalingEnableNV")
	vtable.CmdSetViewportWScalingNV                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportWScalingNV")
	vtable.CmdSetViewportWithCount                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportWithCount")
	vtable.CmdSetViewportWithCountEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSetViewportWithCountEXT")
	vtable.CmdSubpassShadingHUAWEI                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdSubpassShadingHUAWEI")
	vtable.CmdTraceRaysIndirect2KHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdTraceRaysIndirect2KHR")
	vtable.CmdTraceRaysIndirectKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdTraceRaysIndirectKHR")
	vtable.CmdTraceRaysKHR                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdTraceRaysKHR")
	vtable.CmdTraceRaysNV                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdTraceRaysNV")
	vtable.CmdUpdateBuffer                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdUpdateBuffer")
	vtable.CmdUpdatePipelineIndirectBufferNV                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdUpdatePipelineIndirectBufferNV")
	vtable.CmdWaitEvents                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWaitEvents")
	vtable.CmdWaitEvents2                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWaitEvents2")
	vtable.CmdWaitEvents2KHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWaitEvents2KHR")
	vtable.CmdWriteAccelerationStructuresPropertiesKHR            = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteAccelerationStructuresPropertiesKHR")
	vtable.CmdWriteAccelerationStructuresPropertiesNV             = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteAccelerationStructuresPropertiesNV")
	vtable.CmdWriteBufferMarker2AMD                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteBufferMarker2AMD")
	vtable.CmdWriteBufferMarkerAMD                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteBufferMarkerAMD")
	vtable.CmdWriteMicromapsPropertiesEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteMicromapsPropertiesEXT")
	vtable.CmdWriteTimestamp                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteTimestamp")
	vtable.CmdWriteTimestamp2                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteTimestamp2")
	vtable.CmdWriteTimestamp2KHR                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCmdWriteTimestamp2KHR")
	vtable.CompileDeferredNV                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCompileDeferredNV")
	vtable.CopyAccelerationStructureKHR                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyAccelerationStructureKHR")
	vtable.CopyAccelerationStructureToMemoryKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyAccelerationStructureToMemoryKHR")
	vtable.CopyImageToImageEXT                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyImageToImageEXT")
	vtable.CopyImageToMemoryEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyImageToMemoryEXT")
	vtable.CopyMemoryToAccelerationStructureKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyMemoryToAccelerationStructureKHR")
	vtable.CopyMemoryToImageEXT                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyMemoryToImageEXT")
	vtable.CopyMemoryToMicromapEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyMemoryToMicromapEXT")
	vtable.CopyMicromapEXT                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyMicromapEXT")
	vtable.CopyMicromapToMemoryEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCopyMicromapToMemoryEXT")
	vtable.CreateAccelerationStructureKHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateAccelerationStructureKHR")
	vtable.CreateAccelerationStructureNV                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateAccelerationStructureNV")
	vtable.CreateBuffer                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateBuffer")
	vtable.CreateBufferView                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateBufferView")
	vtable.CreateCommandPool                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateCommandPool")
	vtable.CreateComputePipelines                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateComputePipelines")
	vtable.CreateCuFunctionNVX                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateCuFunctionNVX")
	vtable.CreateCuModuleNVX                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateCuModuleNVX")
	vtable.CreateCudaFunctionNV                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateCudaFunctionNV")
	vtable.CreateCudaModuleNV                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateCudaModuleNV")
	vtable.CreateDeferredOperationKHR                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateDeferredOperationKHR")
	vtable.CreateDescriptorPool                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateDescriptorPool")
	vtable.CreateDescriptorSetLayout                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateDescriptorSetLayout")
	vtable.CreateDescriptorUpdateTemplate                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateDescriptorUpdateTemplate")
	vtable.CreateDescriptorUpdateTemplateKHR                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateDescriptorUpdateTemplateKHR")
	vtable.CreateEvent                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateEvent")
	vtable.CreateFence                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateFence")
	vtable.CreateFramebuffer                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateFramebuffer")
	vtable.CreateGraphicsPipelines                                = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateGraphicsPipelines")
	vtable.CreateImage                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateImage")
	vtable.CreateImageView                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateImageView")
	vtable.CreateIndirectCommandsLayoutEXT                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateIndirectCommandsLayoutEXT")
	vtable.CreateIndirectCommandsLayoutNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateIndirectCommandsLayoutNV")
	vtable.CreateIndirectExecutionSetEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateIndirectExecutionSetEXT")
	vtable.CreateMicromapEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateMicromapEXT")
	vtable.CreateOpticalFlowSessionNV                             = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateOpticalFlowSessionNV")
	vtable.CreatePipelineBinariesKHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCreatePipelineBinariesKHR")
	vtable.CreatePipelineCache                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkCreatePipelineCache")
	vtable.CreatePipelineLayout                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCreatePipelineLayout")
	vtable.CreatePrivateDataSlot                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCreatePrivateDataSlot")
	vtable.CreatePrivateDataSlotEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCreatePrivateDataSlotEXT")
	vtable.CreateQueryPool                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateQueryPool")
	vtable.CreateRayTracingPipelinesKHR                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateRayTracingPipelinesKHR")
	vtable.CreateRayTracingPipelinesNV                            = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateRayTracingPipelinesNV")
	vtable.CreateRenderPass                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateRenderPass")
	vtable.CreateRenderPass2                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateRenderPass2")
	vtable.CreateRenderPass2KHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateRenderPass2KHR")
	vtable.CreateSampler                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSampler")
	vtable.CreateSamplerYcbcrConversion                           = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSamplerYcbcrConversion")
	vtable.CreateSamplerYcbcrConversionKHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSamplerYcbcrConversionKHR")
	vtable.CreateSemaphore                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSemaphore")
	vtable.CreateShaderModule                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateShaderModule")
	vtable.CreateShadersEXT                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateShadersEXT")
	vtable.CreateSharedSwapchainsKHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSharedSwapchainsKHR")
	vtable.CreateSwapchainKHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateSwapchainKHR")
	vtable.CreateValidationCacheEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateValidationCacheEXT")
	vtable.CreateVideoSessionKHR                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateVideoSessionKHR")
	vtable.CreateVideoSessionParametersKHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkCreateVideoSessionParametersKHR")
	vtable.DebugMarkerSetObjectNameEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkDebugMarkerSetObjectNameEXT")
	vtable.DebugMarkerSetObjectTagEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkDebugMarkerSetObjectTagEXT")
	vtable.DeferredOperationJoinKHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkDeferredOperationJoinKHR")
	vtable.DestroyAccelerationStructureKHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyAccelerationStructureKHR")
	vtable.DestroyAccelerationStructureNV                         = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyAccelerationStructureNV")
	vtable.DestroyBuffer                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyBuffer")
	vtable.DestroyBufferView                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyBufferView")
	vtable.DestroyCommandPool                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyCommandPool")
	vtable.DestroyCuFunctionNVX                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyCuFunctionNVX")
	vtable.DestroyCuModuleNVX                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyCuModuleNVX")
	vtable.DestroyCudaFunctionNV                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyCudaFunctionNV")
	vtable.DestroyCudaModuleNV                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyCudaModuleNV")
	vtable.DestroyDeferredOperationKHR                            = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDeferredOperationKHR")
	vtable.DestroyDescriptorPool                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDescriptorPool")
	vtable.DestroyDescriptorSetLayout                             = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDescriptorSetLayout")
	vtable.DestroyDescriptorUpdateTemplate                        = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDescriptorUpdateTemplate")
	vtable.DestroyDescriptorUpdateTemplateKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDescriptorUpdateTemplateKHR")
	vtable.DestroyDevice                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyDevice")
	vtable.DestroyEvent                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyEvent")
	vtable.DestroyFence                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyFence")
	vtable.DestroyFramebuffer                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyFramebuffer")
	vtable.DestroyImage                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyImage")
	vtable.DestroyImageView                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyImageView")
	vtable.DestroyIndirectCommandsLayoutEXT                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyIndirectCommandsLayoutEXT")
	vtable.DestroyIndirectCommandsLayoutNV                        = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyIndirectCommandsLayoutNV")
	vtable.DestroyIndirectExecutionSetEXT                         = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyIndirectExecutionSetEXT")
	vtable.DestroyMicromapEXT                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyMicromapEXT")
	vtable.DestroyOpticalFlowSessionNV                            = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyOpticalFlowSessionNV")
	vtable.DestroyPipeline                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPipeline")
	vtable.DestroyPipelineBinaryKHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPipelineBinaryKHR")
	vtable.DestroyPipelineCache                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPipelineCache")
	vtable.DestroyPipelineLayout                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPipelineLayout")
	vtable.DestroyPrivateDataSlot                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPrivateDataSlot")
	vtable.DestroyPrivateDataSlotEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyPrivateDataSlotEXT")
	vtable.DestroyQueryPool                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyQueryPool")
	vtable.DestroyRenderPass                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyRenderPass")
	vtable.DestroySampler                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroySampler")
	vtable.DestroySamplerYcbcrConversion                          = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroySamplerYcbcrConversion")
	vtable.DestroySamplerYcbcrConversionKHR                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroySamplerYcbcrConversionKHR")
	vtable.DestroySemaphore                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroySemaphore")
	vtable.DestroyShaderEXT                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyShaderEXT")
	vtable.DestroyShaderModule                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyShaderModule")
	vtable.DestroySwapchainKHR                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroySwapchainKHR")
	vtable.DestroyValidationCacheEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyValidationCacheEXT")
	vtable.DestroyVideoSessionKHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyVideoSessionKHR")
	vtable.DestroyVideoSessionParametersKHR                       = auto_cast vtable.GetDeviceProcAddr(device, "vkDestroyVideoSessionParametersKHR")
	vtable.DeviceWaitIdle                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkDeviceWaitIdle")
	vtable.DisplayPowerControlEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkDisplayPowerControlEXT")
	vtable.EndCommandBuffer                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkEndCommandBuffer")
	vtable.ExportMetalObjectsEXT                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkExportMetalObjectsEXT")
	vtable.FlushMappedMemoryRanges                                = auto_cast vtable.GetDeviceProcAddr(device, "vkFlushMappedMemoryRanges")
	vtable.FreeCommandBuffers                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkFreeCommandBuffers")
	vtable.FreeDescriptorSets                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkFreeDescriptorSets")
	vtable.FreeMemory                                             = auto_cast vtable.GetDeviceProcAddr(device, "vkFreeMemory")
	vtable.GetAccelerationStructureBuildSizesKHR                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetAccelerationStructureBuildSizesKHR")
	vtable.GetAccelerationStructureDeviceAddressKHR               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetAccelerationStructureDeviceAddressKHR")
	vtable.GetAccelerationStructureHandleNV                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetAccelerationStructureHandleNV")
	vtable.GetAccelerationStructureMemoryRequirementsNV           = auto_cast vtable.GetDeviceProcAddr(device, "vkGetAccelerationStructureMemoryRequirementsNV")
	vtable.GetAccelerationStructureOpaqueCaptureDescriptorDataEXT = auto_cast vtable.GetDeviceProcAddr(device, "vkGetAccelerationStructureOpaqueCaptureDescriptorDataEXT")
	vtable.GetBufferDeviceAddress                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferDeviceAddress")
	vtable.GetBufferDeviceAddressEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferDeviceAddressEXT")
	vtable.GetBufferDeviceAddressKHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferDeviceAddressKHR")
	vtable.GetBufferMemoryRequirements                            = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferMemoryRequirements")
	vtable.GetBufferMemoryRequirements2                           = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferMemoryRequirements2")
	vtable.GetBufferMemoryRequirements2KHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferMemoryRequirements2KHR")
	vtable.GetBufferOpaqueCaptureAddress                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferOpaqueCaptureAddress")
	vtable.GetBufferOpaqueCaptureAddressKHR                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferOpaqueCaptureAddressKHR")
	vtable.GetBufferOpaqueCaptureDescriptorDataEXT                = auto_cast vtable.GetDeviceProcAddr(device, "vkGetBufferOpaqueCaptureDescriptorDataEXT")
	vtable.GetCalibratedTimestampsEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetCalibratedTimestampsEXT")
	vtable.GetCalibratedTimestampsKHR                             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetCalibratedTimestampsKHR")
	vtable.GetCudaModuleCacheNV                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetCudaModuleCacheNV")
	vtable.GetDeferredOperationMaxConcurrencyKHR                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeferredOperationMaxConcurrencyKHR")
	vtable.GetDeferredOperationResultKHR                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeferredOperationResultKHR")
	vtable.GetDescriptorEXT                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorEXT")
	vtable.GetDescriptorSetHostMappingVALVE                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetHostMappingVALVE")
	vtable.GetDescriptorSetLayoutBindingOffsetEXT                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetLayoutBindingOffsetEXT")
	vtable.GetDescriptorSetLayoutHostMappingInfoVALVE             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetLayoutHostMappingInfoVALVE")
	vtable.GetDescriptorSetLayoutSizeEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetLayoutSizeEXT")
	vtable.GetDescriptorSetLayoutSupport                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetLayoutSupport")
	vtable.GetDescriptorSetLayoutSupportKHR                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDescriptorSetLayoutSupportKHR")
	vtable.GetDeviceAccelerationStructureCompatibilityKHR         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceAccelerationStructureCompatibilityKHR")
	vtable.GetDeviceBufferMemoryRequirements                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceBufferMemoryRequirements")
	vtable.GetDeviceBufferMemoryRequirementsKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceBufferMemoryRequirementsKHR")
	vtable.GetDeviceFaultInfoEXT                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceFaultInfoEXT")
	vtable.GetDeviceGroupPeerMemoryFeatures                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceGroupPeerMemoryFeatures")
	vtable.GetDeviceGroupPeerMemoryFeaturesKHR                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceGroupPeerMemoryFeaturesKHR")
	vtable.GetDeviceGroupPresentCapabilitiesKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceGroupPresentCapabilitiesKHR")
	vtable.GetDeviceGroupSurfacePresentModes2EXT                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceGroupSurfacePresentModes2EXT")
	vtable.GetDeviceGroupSurfacePresentModesKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceGroupSurfacePresentModesKHR")
	vtable.GetDeviceImageMemoryRequirements                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceImageMemoryRequirements")
	vtable.GetDeviceImageMemoryRequirementsKHR                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceImageMemoryRequirementsKHR")
	vtable.GetDeviceImageSparseMemoryRequirements                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceImageSparseMemoryRequirements")
	vtable.GetDeviceImageSparseMemoryRequirementsKHR              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceImageSparseMemoryRequirementsKHR")
	vtable.GetDeviceImageSubresourceLayoutKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceImageSubresourceLayoutKHR")
	vtable.GetDeviceMemoryCommitment                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceMemoryCommitment")
	vtable.GetDeviceMemoryOpaqueCaptureAddress                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceMemoryOpaqueCaptureAddress")
	vtable.GetDeviceMemoryOpaqueCaptureAddressKHR                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceMemoryOpaqueCaptureAddressKHR")
	vtable.GetDeviceMicromapCompatibilityEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceMicromapCompatibilityEXT")
	vtable.GetDeviceProcAddr                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceProcAddr")
	vtable.GetDeviceQueue                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceQueue")
	vtable.GetDeviceQueue2                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceQueue2")
	vtable.GetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI")
	vtable.GetDynamicRenderingTilePropertiesQCOM                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetDynamicRenderingTilePropertiesQCOM")
	vtable.GetEncodedVideoSessionParametersKHR                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetEncodedVideoSessionParametersKHR")
	vtable.GetEventStatus                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetEventStatus")
	vtable.GetFenceFdKHR                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetFenceFdKHR")
	vtable.GetFenceStatus                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetFenceStatus")
	vtable.GetFenceWin32HandleKHR                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetFenceWin32HandleKHR")
	vtable.GetFramebufferTilePropertiesQCOM                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetFramebufferTilePropertiesQCOM")
	vtable.GetGeneratedCommandsMemoryRequirementsEXT              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetGeneratedCommandsMemoryRequirementsEXT")
	vtable.GetGeneratedCommandsMemoryRequirementsNV               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetGeneratedCommandsMemoryRequirementsNV")
	vtable.GetImageDrmFormatModifierPropertiesEXT                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageDrmFormatModifierPropertiesEXT")
	vtable.GetImageMemoryRequirements                             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageMemoryRequirements")
	vtable.GetImageMemoryRequirements2                            = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageMemoryRequirements2")
	vtable.GetImageMemoryRequirements2KHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageMemoryRequirements2KHR")
	vtable.GetImageOpaqueCaptureDescriptorDataEXT                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageOpaqueCaptureDescriptorDataEXT")
	vtable.GetImageSparseMemoryRequirements                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSparseMemoryRequirements")
	vtable.GetImageSparseMemoryRequirements2                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSparseMemoryRequirements2")
	vtable.GetImageSparseMemoryRequirements2KHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSparseMemoryRequirements2KHR")
	vtable.GetImageSubresourceLayout                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSubresourceLayout")
	vtable.GetImageSubresourceLayout2EXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSubresourceLayout2EXT")
	vtable.GetImageSubresourceLayout2KHR                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageSubresourceLayout2KHR")
	vtable.GetImageViewAddressNVX                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageViewAddressNVX")
	vtable.GetImageViewHandleNVX                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageViewHandleNVX")
	vtable.GetImageViewOpaqueCaptureDescriptorDataEXT             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetImageViewOpaqueCaptureDescriptorDataEXT")
	vtable.GetLatencyTimingsNV                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetLatencyTimingsNV")
	vtable.GetMemoryFdKHR                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryFdKHR")
	vtable.GetMemoryFdPropertiesKHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryFdPropertiesKHR")
	vtable.GetMemoryHostPointerPropertiesEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryHostPointerPropertiesEXT")
	vtable.GetMemoryRemoteAddressNV                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryRemoteAddressNV")
	vtable.GetMemoryWin32HandleKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryWin32HandleKHR")
	vtable.GetMemoryWin32HandleNV                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryWin32HandleNV")
	vtable.GetMemoryWin32HandlePropertiesKHR                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMemoryWin32HandlePropertiesKHR")
	vtable.GetMicromapBuildSizesEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetMicromapBuildSizesEXT")
	vtable.GetPastPresentationTimingGOOGLE                        = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPastPresentationTimingGOOGLE")
	vtable.GetPerformanceParameterINTEL                           = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPerformanceParameterINTEL")
	vtable.GetPipelineBinaryDataKHR                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineBinaryDataKHR")
	vtable.GetPipelineCacheData                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineCacheData")
	vtable.GetPipelineExecutableInternalRepresentationsKHR        = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineExecutableInternalRepresentationsKHR")
	vtable.GetPipelineExecutablePropertiesKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineExecutablePropertiesKHR")
	vtable.GetPipelineExecutableStatisticsKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineExecutableStatisticsKHR")
	vtable.GetPipelineIndirectDeviceAddressNV                     = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineIndirectDeviceAddressNV")
	vtable.GetPipelineIndirectMemoryRequirementsNV                = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineIndirectMemoryRequirementsNV")
	vtable.GetPipelineKeyKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelineKeyKHR")
	vtable.GetPipelinePropertiesEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPipelinePropertiesEXT")
	vtable.GetPrivateData                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPrivateData")
	vtable.GetPrivateDataEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetPrivateDataEXT")
	vtable.GetQueryPoolResults                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkGetQueryPoolResults")
	vtable.GetQueueCheckpointData2NV                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetQueueCheckpointData2NV")
	vtable.GetQueueCheckpointDataNV                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetQueueCheckpointDataNV")
	vtable.GetRayTracingCaptureReplayShaderGroupHandlesKHR        = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRayTracingCaptureReplayShaderGroupHandlesKHR")
	vtable.GetRayTracingShaderGroupHandlesKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRayTracingShaderGroupHandlesKHR")
	vtable.GetRayTracingShaderGroupHandlesNV                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRayTracingShaderGroupHandlesNV")
	vtable.GetRayTracingShaderGroupStackSizeKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRayTracingShaderGroupStackSizeKHR")
	vtable.GetRefreshCycleDurationGOOGLE                          = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRefreshCycleDurationGOOGLE")
	vtable.GetRenderAreaGranularity                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRenderAreaGranularity")
	vtable.GetRenderingAreaGranularityKHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkGetRenderingAreaGranularityKHR")
	vtable.GetSamplerOpaqueCaptureDescriptorDataEXT               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSamplerOpaqueCaptureDescriptorDataEXT")
	vtable.GetSemaphoreCounterValue                               = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSemaphoreCounterValue")
	vtable.GetSemaphoreCounterValueKHR                            = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSemaphoreCounterValueKHR")
	vtable.GetSemaphoreFdKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSemaphoreFdKHR")
	vtable.GetSemaphoreWin32HandleKHR                             = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSemaphoreWin32HandleKHR")
	vtable.GetShaderBinaryDataEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetShaderBinaryDataEXT")
	vtable.GetShaderInfoAMD                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkGetShaderInfoAMD")
	vtable.GetShaderModuleCreateInfoIdentifierEXT                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetShaderModuleCreateInfoIdentifierEXT")
	vtable.GetShaderModuleIdentifierEXT                           = auto_cast vtable.GetDeviceProcAddr(device, "vkGetShaderModuleIdentifierEXT")
	vtable.GetSwapchainCounterEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSwapchainCounterEXT")
	vtable.GetSwapchainImagesKHR                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSwapchainImagesKHR")
	vtable.GetSwapchainStatusKHR                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkGetSwapchainStatusKHR")
	vtable.GetValidationCacheDataEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkGetValidationCacheDataEXT")
	vtable.GetVideoSessionMemoryRequirementsKHR                   = auto_cast vtable.GetDeviceProcAddr(device, "vkGetVideoSessionMemoryRequirementsKHR")
	vtable.ImportFenceFdKHR                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkImportFenceFdKHR")
	vtable.ImportFenceWin32HandleKHR                              = auto_cast vtable.GetDeviceProcAddr(device, "vkImportFenceWin32HandleKHR")
	vtable.ImportSemaphoreFdKHR                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkImportSemaphoreFdKHR")
	vtable.ImportSemaphoreWin32HandleKHR                          = auto_cast vtable.GetDeviceProcAddr(device, "vkImportSemaphoreWin32HandleKHR")
	vtable.InitializePerformanceApiINTEL                          = auto_cast vtable.GetDeviceProcAddr(device, "vkInitializePerformanceApiINTEL")
	vtable.InvalidateMappedMemoryRanges                           = auto_cast vtable.GetDeviceProcAddr(device, "vkInvalidateMappedMemoryRanges")
	vtable.LatencySleepNV                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkLatencySleepNV")
	vtable.MapMemory                                              = auto_cast vtable.GetDeviceProcAddr(device, "vkMapMemory")
	vtable.MapMemory2KHR                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkMapMemory2KHR")
	vtable.MergePipelineCaches                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkMergePipelineCaches")
	vtable.MergeValidationCachesEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkMergeValidationCachesEXT")
	vtable.QueueBeginDebugUtilsLabelEXT                           = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueBeginDebugUtilsLabelEXT")
	vtable.QueueBindSparse                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueBindSparse")
	vtable.QueueEndDebugUtilsLabelEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueEndDebugUtilsLabelEXT")
	vtable.QueueInsertDebugUtilsLabelEXT                          = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueInsertDebugUtilsLabelEXT")
	vtable.QueueNotifyOutOfBandNV                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueNotifyOutOfBandNV")
	vtable.QueuePresentKHR                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkQueuePresentKHR")
	vtable.QueueSetPerformanceConfigurationINTEL                  = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueSetPerformanceConfigurationINTEL")
	vtable.QueueSubmit                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueSubmit")
	vtable.QueueSubmit2                                           = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueSubmit2")
	vtable.QueueSubmit2KHR                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueSubmit2KHR")
	vtable.QueueWaitIdle                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkQueueWaitIdle")
	vtable.RegisterDeviceEventEXT                                 = auto_cast vtable.GetDeviceProcAddr(device, "vkRegisterDeviceEventEXT")
	vtable.RegisterDisplayEventEXT                                = auto_cast vtable.GetDeviceProcAddr(device, "vkRegisterDisplayEventEXT")
	vtable.ReleaseCapturedPipelineDataKHR                         = auto_cast vtable.GetDeviceProcAddr(device, "vkReleaseCapturedPipelineDataKHR")
	vtable.ReleaseFullScreenExclusiveModeEXT                      = auto_cast vtable.GetDeviceProcAddr(device, "vkReleaseFullScreenExclusiveModeEXT")
	vtable.ReleasePerformanceConfigurationINTEL                   = auto_cast vtable.GetDeviceProcAddr(device, "vkReleasePerformanceConfigurationINTEL")
	vtable.ReleaseProfilingLockKHR                                = auto_cast vtable.GetDeviceProcAddr(device, "vkReleaseProfilingLockKHR")
	vtable.ReleaseSwapchainImagesEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkReleaseSwapchainImagesEXT")
	vtable.ResetCommandBuffer                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkResetCommandBuffer")
	vtable.ResetCommandPool                                       = auto_cast vtable.GetDeviceProcAddr(device, "vkResetCommandPool")
	vtable.ResetDescriptorPool                                    = auto_cast vtable.GetDeviceProcAddr(device, "vkResetDescriptorPool")
	vtable.ResetEvent                                             = auto_cast vtable.GetDeviceProcAddr(device, "vkResetEvent")
	vtable.ResetFences                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkResetFences")
	vtable.ResetQueryPool                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkResetQueryPool")
	vtable.ResetQueryPoolEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkResetQueryPoolEXT")
	vtable.SetDebugUtilsObjectNameEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkSetDebugUtilsObjectNameEXT")
	vtable.SetDebugUtilsObjectTagEXT                              = auto_cast vtable.GetDeviceProcAddr(device, "vkSetDebugUtilsObjectTagEXT")
	vtable.SetDeviceMemoryPriorityEXT                             = auto_cast vtable.GetDeviceProcAddr(device, "vkSetDeviceMemoryPriorityEXT")
	vtable.SetEvent                                               = auto_cast vtable.GetDeviceProcAddr(device, "vkSetEvent")
	vtable.SetHdrMetadataEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkSetHdrMetadataEXT")
	vtable.SetLatencyMarkerNV                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkSetLatencyMarkerNV")
	vtable.SetLatencySleepModeNV                                  = auto_cast vtable.GetDeviceProcAddr(device, "vkSetLatencySleepModeNV")
	vtable.SetLocalDimmingAMD                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkSetLocalDimmingAMD")
	vtable.SetPrivateData                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkSetPrivateData")
	vtable.SetPrivateDataEXT                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkSetPrivateDataEXT")
	vtable.SignalSemaphore                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkSignalSemaphore")
	vtable.SignalSemaphoreKHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkSignalSemaphoreKHR")
	vtable.TransitionImageLayoutEXT                               = auto_cast vtable.GetDeviceProcAddr(device, "vkTransitionImageLayoutEXT")
	vtable.TrimCommandPool                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkTrimCommandPool")
	vtable.TrimCommandPoolKHR                                     = auto_cast vtable.GetDeviceProcAddr(device, "vkTrimCommandPoolKHR")
	vtable.UninitializePerformanceApiINTEL                        = auto_cast vtable.GetDeviceProcAddr(device, "vkUninitializePerformanceApiINTEL")
	vtable.UnmapMemory                                            = auto_cast vtable.GetDeviceProcAddr(device, "vkUnmapMemory")
	vtable.UnmapMemory2KHR                                        = auto_cast vtable.GetDeviceProcAddr(device, "vkUnmapMemory2KHR")
	vtable.UpdateDescriptorSetWithTemplate                        = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateDescriptorSetWithTemplate")
	vtable.UpdateDescriptorSetWithTemplateKHR                     = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateDescriptorSetWithTemplateKHR")
	vtable.UpdateDescriptorSets                                   = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateDescriptorSets")
	vtable.UpdateIndirectExecutionSetPipelineEXT                  = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateIndirectExecutionSetPipelineEXT")
	vtable.UpdateIndirectExecutionSetShaderEXT                    = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateIndirectExecutionSetShaderEXT")
	vtable.UpdateVideoSessionParametersKHR                        = auto_cast vtable.GetDeviceProcAddr(device, "vkUpdateVideoSessionParametersKHR")
	vtable.WaitForFences                                          = auto_cast vtable.GetDeviceProcAddr(device, "vkWaitForFences")
	vtable.WaitForPresentKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkWaitForPresentKHR")
	vtable.WaitSemaphores                                         = auto_cast vtable.GetDeviceProcAddr(device, "vkWaitSemaphores")
	vtable.WaitSemaphoresKHR                                      = auto_cast vtable.GetDeviceProcAddr(device, "vkWaitSemaphoresKHR")
	vtable.WriteAccelerationStructuresPropertiesKHR               = auto_cast vtable.GetDeviceProcAddr(device, "vkWriteAccelerationStructuresPropertiesKHR")
	vtable.WriteMicromapsPropertiesEXT                            = auto_cast vtable.GetDeviceProcAddr(device, "vkWriteMicromapsPropertiesEXT")
}


load_proc_addresses :: proc{
	load_proc_addresses_loader_vtable,
	load_proc_addresses_instance_vtable,
	load_proc_addresses_device_vtable,
}
