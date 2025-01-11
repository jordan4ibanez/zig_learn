const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const za = @import("zalgebra");
const shader = @import("shader.zig");

const Vec2_usize = za.Vec2_usize;

var gl_procs: gl.ProcTable = undefined;
var window: glfw.Window = undefined;

var viewPortSize: Vec2_usize = Vec2_usize.new(0, 0);

//* ON/OFF SWITCH. ==============================================

pub fn initialize(width: u32, height: u32) void {
    glfw.setErrorCallback(glfwErrorCallback);

    if (!glfw.init(.{})) {
        std.log.err("[GLFW] Error: Failed to initialize. {?s}", .{glfw.getErrorString()});
    } else {
        std.debug.print("[GLFW]: Successfully initialized.\n", .{});
    }

    makeWindow(width, height);

    std.debug.print("[GLFW]: Created window.\n", .{});

    glfw.makeContextCurrent(window);

    window.setFramebufferSizeCallback(glfwFramebufferSizeCallback);

    glfw.swapInterval(1);

    if (!gl_procs.init(glfw.getProcAddress)) {
        std.log.err("[GLFW]: Failed to get process address.", .{});
        std.process.exit(1);
    }
    gl.makeProcTableCurrent(&gl_procs);
    std.debug.print("[OpenGL]: Process pointers assigned.\n", .{});

    if (gl.GetString(gl.VERSION)) |ver| {
        std.debug.print("[OpenGL]: Running version {?s}\n", .{ver});
    } else {
        std.log.err("[OpenGL]: Failed to get OpenGL version.\n", .{});
        std.process.exit(1);
    }

    // Allow debugging output for OpenGL.
    gl.Enable(gl.DEBUG_OUTPUT);
    gl.Enable(gl.DEBUG_OUTPUT_SYNCHRONOUS);
    gl.DebugMessageCallback(openglDebugCallback, null);
    gl.DebugMessageControl(gl.DONT_CARE, gl.DONT_CARE, gl.DONT_CARE, 0, null, gl.TRUE);

    gl.DepthMask(gl.TRUE);
    gl.Enable(gl.DEPTH_TEST);
    gl.DepthFunc(gl.LESS);

    gl.DebugMessageInsert(gl.DEBUG_SOURCE_APPLICATION, gl.DEBUG_TYPE_ERROR, 0, gl.DEBUG_SEVERITY_MEDIUM, -1, "Test error. :)");

    // gl.Enable(gl.CULL_FACE);
}

pub fn terminate() void {
    gl.makeProcTableCurrent(null);
    std.debug.print("[OpenGL]: Process pointers nullified.\n", .{});
    window.destroy();
    std.debug.print("[GLFW]: Window destroyed.\n", .{});
    glfw.terminate();
    std.debug.print("[GLFW]: Terminated.\n", .{});
}

//* PUBLIC API. ===========================================================

pub fn shouldClose() bool {
    return window.shouldClose();
}

pub fn close() void {
    window.setShouldClose(true);
}

pub fn swapBuffers() void {
    window.swapBuffers();
}

pub fn pollEvents() void {
    glfw.pollEvents();
}

pub fn getAspectRatio() f32 {
    const width: f32 = @floatFromInt(viewPortSize.x());
    const height: f32 = @floatFromInt(viewPortSize.y());
    return width / height;
}

pub fn getSize() Vec2_usize {
    return viewPortSize;
}

///
/// Set the wobbly vertices like the PS1.
///
/// The lower this value is, the wobblier things get.
///
/// Good range: 20-40.
///
pub fn setPs1Blockiness(blockiness: f32) void {
    shader.setF32Uniform(shader.PS1_BLOCKINESS_UNIFORM_LOCATION, blockiness);
}

//* INTERNAL API. ==============================================

fn makeWindow(width: u32, height: u32) void {
    window = glfw.Window.create(width, height, "Program", null, null, .{
        .context_version_major = gl.info.version_major,
        .context_version_minor = gl.info.version_minor,
        .opengl_profile = .opengl_core_profile,
        .opengl_forward_compat = true,
    }) orelse {
        std.log.err("[GLFW] Error: Failed to create glfw window. {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    viewPortSize = Vec2_usize.new(width, height);
}

fn glfwFramebufferSizeCallback(win: glfw.Window, width: u32, height: u32) void {
    gl.Viewport(0, 0, @intCast(width), @intCast(height));
    viewPortSize = Vec2_usize.new(width, height);
    _ = &win;
    _ = &width;
    _ = &height;
}

fn glfwErrorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("[GLFW]: {}: {s}\n", .{ error_code, description });
}

fn openglDebugCallback(source: gl.@"enum", @"type": gl.@"enum", id: gl.uint, severity: gl.@"enum", length: gl.sizei, message: [*:0]const gl.char, userParam: ?*const anyopaque) callconv(gl.APIENTRY) void {
    std.debug.print("[OpenGL]: {s}\n", .{message});
    _ = &source;
    _ = &@"type";
    _ = &id;
    _ = &severity;
    _ = &length;
    _ = &message;
    _ = &userParam;
}
