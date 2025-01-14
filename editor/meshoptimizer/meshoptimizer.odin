package meshopt

import _c "core:c"


MESHOPTIMIZER_VERSION :: 220

EncodeExpMode :: enum {
	/* When encoding exponents, use separate values for each component (maximum quality) */
	meshopt_EncodeExpSeparate,
	/* When encoding exponents, use shared value for all components of each vector (better compression) */
	meshopt_EncodeExpSharedVector,
	/* When encoding exponents, use shared value for each component of all vectors (best compression) */
	meshopt_EncodeExpSharedComponent,
	/* Experimental: When encoding exponents, use separate values for each component, but clamp to 0 (good quality if very small values are not important) */
	meshopt_EncodeExpClamped,
}

SimplifyLockBorder :: 1
SimplifySparse :: 2
SimplifyErrorAbsolute :: 4
SimplifyPrune :: 8


Stream :: struct {
	data:   rawptr,
	size:   uint,
	stride: uint,
}

VertexCacheStatistics :: struct {
	vertices_transformed: _c.uint,
	warps_executed:       _c.uint,
	acmr:                 _c.float,
	atvr:                 _c.float,
}

OverdrawStatistics :: struct {
	pixels_covered: _c.uint,
	pixels_shaded:  _c.uint,
	overdraw:       _c.float,
}

VertexFetchStatistics :: struct {
	bytes_fetched: _c.uint,
	overfetch:     _c.float,
}

Meshlet :: struct {
	vertex_offset:   _c.uint,
	triangle_offset: _c.uint,
	vertex_count:    _c.uint,
	triangle_count:  _c.uint,
}

Bounds :: struct {
	center:         [3]_c.float,
	radius:         _c.float,
	cone_apex:      [3]_c.float,
	cone_axis:      [3]_c.float,
	cone_cutoff:    _c.float,
	cone_axis_s8:   [3]_c.schar,
	cone_cutoff_s8: _c.schar,
}


/***** meshoptimizer *****/
foreign import meshoptimizer "external/meshoptimizer.lib"

/* Procedures */
@(link_prefix = "meshopt_")
foreign meshoptimizer {
	generateVertexRemap :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertices: rawptr, vertex_count: uint, vertex_size: uint) -> uint ---
	generateVertexRemapMulti :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint, streams: ^Stream, stream_count: uint) -> uint ---
	remapVertexBuffer :: proc(destination: rawptr, vertices: rawptr, vertex_count: uint, vertex_size: uint, remap: ^_c.uint) ---
	remapIndexBuffer :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, remap: ^_c.uint) ---
	generateShadowIndexBuffer :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertices: rawptr, vertex_count: uint, vertex_size: uint, vertex_stride: uint) ---
	generateShadowIndexBufferMulti :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint, streams: ^Stream, stream_count: uint) ---
	generateAdjacencyIndexBuffer :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) ---
	generateTessellationIndexBuffer :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) ---
	optimizeVertexCache :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint) ---
	optimizeVertexCacheStrip :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint) ---
	optimizeVertexCacheFifo :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint, cache_size: _c.uint) ---
	optimizeOverdraw :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, threshold: _c.float) ---
	optimizeVertexFetch :: proc(destination: rawptr, indices: ^_c.uint, index_count: uint, vertices: rawptr, vertex_count: uint, vertex_size: uint) -> uint ---
	optimizeVertexFetchRemap :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint) -> uint ---
	encodeIndexBuffer :: proc(buffer: ^_c.uchar, buffer_size: uint, indices: ^_c.uint, index_count: uint) -> uint ---
	encodeIndexBufferBound :: proc(index_count: uint, vertex_count: uint) -> uint ---
	encodeIndexVersion :: proc(version: int) ---
	decodeIndexBuffer :: proc(destination: rawptr, index_count: uint, index_size: uint, buffer: ^_c.uchar, buffer_size: uint) -> int ---
	encodeIndexSequence :: proc(buffer: ^_c.uchar, buffer_size: uint, indices: ^_c.uint, index_count: uint) -> uint ---
	encodeIndexSequenceBound :: proc(index_count: uint, vertex_count: uint) -> uint ---
	decodeIndexSequence :: proc(destination: rawptr, index_count: uint, index_size: uint, buffer: ^_c.uchar, buffer_size: uint) -> int ---
	encodeVertexBuffer :: proc(buffer: ^_c.uchar, buffer_size: uint, vertices: rawptr, vertex_count: uint, vertex_size: uint) -> uint ---
	encodeVertexBufferBound :: proc(vertex_count: uint, vertex_size: uint) -> uint ---
	encodeVertexVersion :: proc(version: int) ---
	decodeVertexBuffer :: proc(destination: rawptr, vertex_count: uint, vertex_size: uint, buffer: ^_c.uchar, buffer_size: uint) -> int ---
	stripify :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_count: uint, restart_index: _c.uint) -> uint ---
	stripifyBound :: proc(index_count: uint) -> uint ---
	unstripify :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, restart_index: _c.uint) -> uint ---
	unstripifyBound :: proc(index_count: uint) -> uint ---
	analyzeVertexCache :: proc(indices: ^_c.uint, index_count: uint, vertex_count: uint, cache_size: _c.uint, warp_size: _c.uint, primgroup_size: _c.uint) -> VertexCacheStatistics ---
	analyzeOverdraw :: proc(indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) -> OverdrawStatistics ---
	analyzeVertexFetch :: proc(indices: ^_c.uint, index_count: uint, vertex_count: uint, vertex_size: uint) -> VertexFetchStatistics ---
	buildMeshlets :: proc(meshlets: ^Meshlet, meshlet_vertices: ^_c.uint, meshlet_triangles: ^_c.uchar, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, max_vertices: uint, max_triangles: uint, cone_weight: _c.float) -> uint ---
	buildMeshletsScan :: proc(meshlets: ^Meshlet, meshlet_vertices: ^_c.uint, meshlet_triangles: ^_c.uchar, indices: ^_c.uint, index_count: uint, vertex_count: uint, max_vertices: uint, max_triangles: uint) -> uint ---
	buildMeshletsBound :: proc(index_count: uint, max_vertices: uint, max_triangles: uint) -> uint ---
	computeClusterBounds :: proc(indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) -> Bounds ---
	computeMeshletBounds :: proc(meshlet_vertices: ^_c.uint, meshlet_triangles: ^_c.uchar, triangle_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) -> Bounds ---
	setAllocator :: proc(allocate: (proc "c" (_: uint) -> rawptr), deallocate: proc "c" (_: rawptr)) ---
	decodeFilterOct :: proc(buffer: rawptr, count: uint, stride: uint) ---
	decodeFilterQuat :: proc(buffer: rawptr, count: uint, stride: uint) ---
	decodeFilterExp :: proc(buffer: rawptr, count: uint, stride: uint) ---
	encodeFilterOct :: proc(destination: rawptr, count: uint, stride: uint, bits: int, data: ^_c.float) ---
	encodeFilterQuat :: proc(destination: rawptr, count: uint, stride: uint, bits: int, data: ^_c.float) ---
	encodeFilterExp :: proc(destination: rawptr, count: uint, stride: uint, bits: int, data: ^_c.float) ---
	simplifyWithAttributes :: proc(destination: rawptr, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, vertex_attributes: ^_c.float, vertex_attributes_stride: uint, attribute_weights: ^_c.float, attribute_count: uint, vertex_lock: ^u8, target_index_count: uint, target_error: f32, options: _c.uint, result_error: ^_c.float) ---
	simplify :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, target_index_count: uint, target_error: _c.float, options: _c.uint, result_error: ^_c.float) -> uint ---
	simplifySloppy :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, target_index_count: uint, target_error: _c.float, result_error: ^_c.float) -> uint ---
	simplifyPoints :: proc(destination: ^_c.uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint, target_vertex_count: uint) -> uint ---
	simplifyScale :: proc(vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) -> _c.float ---
	spatialSortRemap :: proc(destination: ^_c.uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) ---
	spatialSortTriangles :: proc(destination: ^_c.uint, indices: ^_c.uint, index_count: uint, vertex_positions: ^_c.float, vertex_count: uint, vertex_positions_stride: uint) ---
}
