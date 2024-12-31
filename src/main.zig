const std = @import("std");
const gl = @import("gl");
const za = @import("zalgebra");
const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

const window = @import("window.zig");

pub fn main() !void {
    std.debug.print("[Main]: Hello!\n", .{});

    window.initialize();
    defer window.terminate();

    var projection = za.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);
    projection.debugPrint();

    while (!window.shouldClose()) {
        gl.ClearColor(1.0, 1.0, 1.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        window.swapBuffers();
        window.pollEvents();
    }
}
