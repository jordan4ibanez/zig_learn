const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

var gl_procs: gl.ProcTable = undefined;
var window: glfw.Window = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    glfw.setErrorCallback(glfwErrorCallback);

    if (!glfw.init(.{})) {
        std.log.err("[GLFW] Error: Failed to initialize. {?s}", .{glfw.getErrorString()});
    } else {
        std.debug.print("[GLFW]: Successfully initialized.\n", .{});
    }

    window = glfw.Window.create(1024, 768, "Program", null, null, .{
        .context_version_major = gl.info.version_major,
        .context_version_minor = gl.info.version_minor,
        .opengl_profile = .opengl_core_profile,
        .opengl_forward_compat = true,
    }) orelse {
        std.log.err("[GLFW] Error: Failed to create glfw window. {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    std.debug.print("[GLFW]: Created window.\n", .{});

    glfw.makeContextCurrent(window);

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

//* INTERNAL API. ==============================================

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
