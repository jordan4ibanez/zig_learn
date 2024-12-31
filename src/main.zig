const std = @import("std");
const glfw = @import("mach-glfw");

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
    defer window.destroy();

    while (!window.shouldClose()) {
        window.swapBuffers();
        glfw.pollEvents();
    }
}
