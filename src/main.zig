const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const init = @import("init");

var gl_procs: gl.ProcTable = undefined;

fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn main() !void {
    std.debug.print("[Main]: Hello!\n", .{});
    glfw.setErrorCallback(errorCallback);

    if (!glfw.init(.{})) {
        std.log.err("[GLFW] Error: Failed to initialize. {?s}", .{glfw.getErrorString()});
    } else {
        std.debug.print("[GLFW]: Successfully initialized.\n", .{});
    }
    defer glfw.terminate();

    const window: glfw.Window = glfw.Window.create(1024, 768, "Program", null, null, .{
        .context_version_major = gl.info.version_major,
        .context_version_minor = gl.info.version_minor,
        .opengl_profile = .opengl_core_profile,
        .opengl_forward_compat = true,
    }) orelse {
        std.log.err("[GLFW] Error: Failed to create glfw window. {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    std.debug.print("[GLFW]: Created window.\n", .{});
    defer window.destroy();

    glfw.makeContextCurrent(window);

    if (!gl_procs.init(glfw.getProcAddress)) {
        std.log.err("[GLFW]: Failed to get process address.", .{});
        std.process.exit(1);
    }
    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    if (gl.GetString(gl.VERSION)) |ver| {
        std.debug.print("[OpenGL]: Running version {?s}\n", .{ver});
    } else {
        std.log.err("[OpenGL]: Failed to get OpenGL version.\n", .{});
        std.process.exit(1);
    }

    while (!window.shouldClose()) {
        gl.ClearColor(1.0, 1.0, 1.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        window.swapBuffers();
        glfw.pollEvents();
    }
}
