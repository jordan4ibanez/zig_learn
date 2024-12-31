const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("zgl");

fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn main() !void {
    std.debug.print("[Main]: Hello!\n", .{});
    glfw.setErrorCallback(errorCallback);

    if (!glfw.init(.{})) {
        std.log.err("[GLFW] Error: Failed to initialize. {?s}", .{glfw.getErrorString()});
    } else {
        std.log.debug("[GLFW]: Successfully initialized.", .{});
    }
    defer glfw.terminate();

    const window: glfw.Window = glfw.Window.create(1024, 768, "Program", null, null, .{}) orelse {
        std.log.err("[GLFW] Error: Failed to create glfw window. {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    std.log.debug("[GLFW]: Created window.", .{});

    defer window.destroy();

    glfw.makeContextCurrent(window);

    while (!window.shouldClose()) {
        gl.clearColor(1.0, 1.0, 1.0, 1.0);
        gl.clear(.{ .color = true, .depth = false, .stencil = false });
        window.swapBuffers();
        glfw.pollEvents();
    }
}
