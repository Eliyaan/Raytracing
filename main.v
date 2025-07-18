module main

import gg
import sokol.sapp
import sokol.gfx

#include "@VMODROOT/rtc.h" # # It should be generated with `v shader .`

fn C.rtc_shader_desc(gfx.Backend) &gfx.ShaderDesc

struct Vertex_t {
	x f32
	y f32
	z f32
}

struct App {
	pass_action gfx.PassAction
mut:
	ctx              &gg.Context = unsafe { nil }
	shader_pipeline gfx.Pipeline
	bind            gfx.Bindings
	mouse_x         f32
	mouse_y         f32
}

fn main() {
	mut app := &App{
		pass_action: gfx.create_clear_pass_action(0.0, 0.0, 0.0, 1.0) // This will create a black color as a default pass (window background color)
	}
	app.ctx = gg.new_context(
		width: 1920
		height: 1080
		user_data: app
		init_fn: init
		frame_fn: frame
		event_fn: event
		window_title: 'Raytracing'
		sample_count: 4
		fullscreen: true
	)
	app.ctx.run()
}

fn event(mut e gg.Event, mut app App) {
	if e.typ == .mouse_move {
		app.mouse_x = e.mouse_x
		app.mouse_y = e.mouse_y
	}
}

fn init(mut app App) {
	mut desc := sapp.create_desc()
	gfx.setup(&desc)

	vertices := [
		Vertex_t{-1.0, 1.0, 0.0},
		Vertex_t{1.0, 1.0, 0.0},
		Vertex_t{1.0, -1.0, 0.0},
		Vertex_t{-1.0, -1.0, 0.0},
		Vertex_t{-1.0, 1.0, 0.0},
		Vertex_t{1.0, -1.0, 0.0},
	]

	// Complex buffer stuff
	mut vertex_buffer_desc := gfx.BufferDesc{
		label: c'triangles-vertices'
	}
	unsafe { vmemset(&vertex_buffer_desc, 0, int(sizeof(vertex_buffer_desc))) } // put 0 to all bytes

	vertex_buffer_desc.size = usize(vertices.len * int(sizeof(Vertex_t)))
	vertex_buffer_desc.data = gfx.Range{
		ptr: vertices.data
		size: vertex_buffer_desc.size
	}
	app.bind.vertex_buffers[0] = gfx.make_buffer(&vertex_buffer_desc)

	// creates the shader
	shader := gfx.make_shader(C.rtc_shader_desc(gfx.query_backend()))

	// setups the pipeline
	mut pipeline_desc := gfx.PipelineDesc{}
	unsafe { vmemset(&pipeline_desc, 0, int(sizeof(pipeline_desc))) }

	pipeline_desc.shader = shader
	pipeline_desc.label = c'triangle-pipeline'
	// input via the buffer:
	pipeline_desc.layout.attrs[C.ATTR_vs_position].format = .float3 // x,y,z as f32

	app.shader_pipeline = gfx.make_pipeline(&pipeline_desc)
}

fn frame(mut app App) {
	pass := sapp.create_default_pass(app.pass_action)
	gfx.begin_pass(&pass)

	gfx.apply_pipeline(app.shader_pipeline)
	gfx.apply_bindings(&app.bind)


	// Create the data to send
	size := app.ctx.window_size()

	mouse_x := app.mouse_x/f32(size.width)
	mouse_y := app.mouse_y/f32(size.width)
	// vfmt off
	tmp_fs_params := [
		f32(size.width), f32(size.height), mouse_x, mouse_y // /!\ need to send the floats 4 by 4 
	]!
	// vfmt on
	fs_uniforms_range := gfx.Range{
		ptr: unsafe { &tmp_fs_params }
		size: usize(sizeof(tmp_fs_params))
	}
	// send it to the fragment shader
	gfx.apply_uniforms(.fs, C.SLOT_fs_params, &fs_uniforms_range)

	gfx.draw(0, 6, 1)

	gfx.end_pass()
	gfx.commit()
}
