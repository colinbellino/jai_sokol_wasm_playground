#import "Basic";
#import,dir "modules/sokol-jai/sokol/app";
#import,dir "modules/sokol-jai/sokol/gfx";
#import,dir "modules/sokol-jai/sokol/glue";
#import,dir "modules/sokol-jai/sokol/log";
#load "./shader_triangle.jai";

default_context: Context;
state: struct {
    pip:         sg_pipeline;
    bind:        sg_bindings;
    pass_action: sg_pass_action;
}

#program_export
_main :: () #c_call {
    push_context,defer_pop default_context;
    context.logger = logger;

    log("Hello sailor!");
    log_content("Starting sokol triangle app...");
    log_warn("This is a warning");
    log_error("This is an error");

    sapp_run(*(sapp_desc.{
        init_cb = init,
        frame_cb = frame,
        cleanup_cb = cleanup,
        width = 640,
        height = 480,
        window_title = "triangle",
        // icon = .{ sokol_default = true },
        logger = .{ func = slog_func },
    }));
}

init :: () #c_call {
    push_context,defer_pop default_context;

    sg_setup(*(sg_desc.{
        environment = xx sglue_environment(),
        logger = .{ func = slog_func },
    }));

    // a vertex buffer with 3 vertices
    vertices := float.[
        // positions         // colors
        0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
        0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
        -0.5, -0.5, 0.5,    0.0, 0.0, 1.0, 1.0,
    ];
    buffer := sg_buffer_desc.{ data = .{ ptr = *vertices, size = size_of(type_of(vertices)) } };
    state.bind.vertex_buffers[0] = sg_make_buffer(*buffer);

    // create a shader and pipeline object (default render states are fine for triangle)
    pipeline: sg_pipeline_desc;
    shader_desc := triangle_shader_desc(sg_query_backend());
    pipeline.shader = sg_make_shader(*shader_desc);
    pipeline.layout.attrs[ATTR_vs_position] = .{ format = .FLOAT3 };
    pipeline.layout.attrs[ATTR_vs_color0]    = .{ format = .FLOAT4 };
    state.pip = sg_make_pipeline(*pipeline);

    // a pass action to clear framebuffer to black
    state.pass_action.colors[0] = .{ load_action = .CLEAR, clear_value = .{ r = 0, g = 0, b = 0, a = 1 } };
}

frame :: () #c_call {
    sg_begin_pass(*(sg_pass.{ action = state.pass_action, swapchain = xx sglue_swapchain() }));
        sg_apply_pipeline(state.pip);
        sg_apply_bindings(*state.bind);
        sg_draw(0, 3, 1);
    sg_end_pass();
    sg_commit();
}

cleanup :: () #c_call {
    sg_shutdown();
}

log_warn :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0, section : *Log_Section = null) {
    log(format_string, ..args, loc = loc, flags = flags | .WARNING, user_flags = user_flags, section = section);
} @PrintLike

log_content :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0, section : *Log_Section = null) {
    log(format_string, ..args, loc = loc, flags = flags | .CONTENT, user_flags = user_flags, section = section);
} @PrintLike

logger :: (message: string, data: *void, info: Log_Info) {
    wasm_write_string :: (count: s64, data: *void, log_flag: Log_Flags) #foreign; // You will need to provide this function as JS code in your WASM environment. :JaiWasm:
    wasm_write_string(message.count, message.data, info.common_flags);
}
