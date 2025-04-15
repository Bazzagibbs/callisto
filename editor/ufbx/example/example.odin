package ufbx_example

import "core:fmt"
import "core:math"
import la "core:math/linalg"
import "core:time"

import "vendor:glfw"
import gl "vendor:OpenGL"

import fbx ".."

load_mesh :: proc() -> (indices: []u32, positions: [][3]f32, normals: [][3]f32, uvs: [][2]f32) {
	// Load the .fbx file
	opts := fbx.Load_Opts{}
	err := fbx.Error{}
	scene := fbx.load_file("example/suzanne.fbx", &opts, &err)
	if scene == nil {
		fmt.printf("%s\n", err.description)
		panic("Failed to load")
	}

	// Retrieve the first mesh
	mesh: ^fbx.Mesh
	for node in scene.nodes {
		if node.is_root || node.mesh == nil { continue }
		mesh = node.mesh
		break
	}

	// Unpack / triangulate the index data
	index_count := 3 * mesh.num_triangles
	indices = make([]u32, index_count)
	off := u32(0)
	for face in mesh.faces {
		tris := fbx.catch_triangulate_face(nil, &indices[off], uint(index_count), mesh, face)
		off += 3 * tris
	}

	// Unpack the vertex data
	vertex_count := mesh.num_indices
	positions = make([][3]f32, vertex_count)
	normals = make([][3]f32, vertex_count)
	uvs = make([][2]f32, vertex_count)

	for i in 0..< vertex_count {
		pos := mesh.vertex_position.values[mesh.vertex_position.indices[i]]
		norm := mesh.vertex_normal.values[mesh.vertex_normal.indices[i]]
		uv := mesh.vertex_uv.values[mesh.vertex_uv.indices[i]]
		positions[i] = {f32(pos.x), f32(pos.y), f32(pos.z)}
		normals[i] = {f32(norm.x), f32(norm.y), f32(norm.z)}
		uvs[i] = {f32(uv.x), f32(uv.y)}
	}

	// Free the fbx data
	fbx.free_scene(scene)

	return
}

vert_src := #load("shader.vert")
frag_src := #load("shader.frag")

WIDTH :: 1920
HEIGHT :: 1920

main :: proc() {
	// Load mesh data from the fbx
	indices, positions, normals, uvs := load_mesh()

	// Render it in a window
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
	w := glfw.CreateWindow(WIDTH, HEIGHT, "odin-ufbx", nil, nil)

	glfw.MakeContextCurrent(w)
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
	gl.Enable(gl.DEPTH_TEST)

	// Load up the vertex + index buffers
	vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	idx_buf: u32
	gl.GenBuffers(1, &idx_buf)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, idx_buf)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 4 * len(indices), &indices[0], gl.STATIC_DRAW)

	pos_buf: u32
	gl.GenBuffers(1, &pos_buf)
	gl.BindBuffer(gl.ARRAY_BUFFER, pos_buf)
	gl.BufferData(gl.ARRAY_BUFFER, 12 * len(positions), &positions[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 12, 0)
	gl.EnableVertexAttribArray(0)

	norm_buf: u32
	gl.GenBuffers(1, &norm_buf)
	gl.BindBuffer(gl.ARRAY_BUFFER, norm_buf)
	gl.BufferData(gl.ARRAY_BUFFER, 12 * len(normals), &normals[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, 12, 0)
	gl.EnableVertexAttribArray(1)

	uv_buf: u32
	gl.GenBuffers(1, &uv_buf)
	gl.BindBuffer(gl.ARRAY_BUFFER, uv_buf)
	gl.BufferData(gl.ARRAY_BUFFER, 8 * len(uvs), &uvs[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, 8, 0)
	gl.EnableVertexAttribArray(2)

	// Load a shader
	vert_shd := gl.CreateShader(gl.VERTEX_SHADER)
	vert_src_copy := cstring(raw_data(vert_src))
	vert_src_len := i32(len(vert_src))
	gl.ShaderSource(vert_shd, 1, &vert_src_copy, &vert_src_len)
	gl.CompileShader(vert_shd)

	success: i32
	gl.GetShaderiv(vert_shd, gl.COMPILE_STATUS, &success)
	if success == 0 {
		info_log: [512]u8
		gl.GetShaderInfoLog(vert_shd, 512, nil, &info_log[0])
		fmt.printf("Vertex shader compilation failed:\n %s\n", info_log)
	}

	frag_shd := gl.CreateShader(gl.FRAGMENT_SHADER)
	frag_src_copy := cstring(raw_data(frag_src))
	frag_src_len := i32(len(frag_src))
	gl.ShaderSource(frag_shd, 1, &frag_src_copy, &frag_src_len)
	gl.CompileShader(frag_shd)

	gl.GetShaderiv(frag_shd, gl.COMPILE_STATUS, &success)
	if success == 0 {
		info_log: [512]u8
		gl.GetShaderInfoLog(frag_shd, 512,  nil, &info_log[0])
		fmt.printf("Fragment shader compilation failed:\n %s\n", info_log)
	}

	program := gl.CreateProgram()
	gl.AttachShader(program, vert_shd)
	gl.AttachShader(program, frag_shd)
	gl.LinkProgram(program)

	gl.GetProgramiv(program, gl.LINK_STATUS, &success)
	if success == 0 {
		info_log: [512]u8
		gl.GetProgramInfoLog(program, 512, nil, &info_log[0])
		fmt.printf("Program Linking failed:\n %s\n", info_log)
	}

	gl.DeleteShader(vert_shd)
	gl.DeleteShader(frag_shd)

	sw: time.Stopwatch
	time.stopwatch_start(&sw)

	// Render the mesh
	for !glfw.WindowShouldClose(w) {
		glfw.PollEvents()

		d := time.stopwatch_duration(sw)
		t := time.duration_seconds(d)
		x := 3.0 * math.sin(f32(t))
		z := 3.0 * math.cos(f32(t))
		model := la.matrix4_rotate_f32(-math.PI / 2.0, {1, 0, 0})
		view := la.matrix4_look_at_f32({x, 0, z}, {0, 0, 0}, {0, 1, 0})
		proj := la.matrix4_perspective_f32(45.0, f32(WIDTH)/f32(HEIGHT), 0.1, 10.0)
		view_proj := proj * view * model


		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		
		gl.UseProgram(program)
		gl.UniformMatrix4fv(0, 1, false, &view_proj[0][0])
		gl.BindVertexArray(vao)
		gl.DrawElements(gl.TRIANGLES, i32(len(indices)), gl.UNSIGNED_INT, nil)
		glfw.SwapBuffers(w)
	}
}
