const std = @import("std");
const gl = @import("gl");

const window = @import("window.zig");

pub fn main() !void {
    std.debug.print("[Main]: Hello!\n", .{});

    window.initialize();
    defer window.terminate();

    while (!window.shouldClose()) {
        gl.ClearColor(1.0, 1.0, 1.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        window.swapBuffers();
        window.pollEvents();
    }
}
