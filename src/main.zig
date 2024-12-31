const std = @import("std");
const gl = @import("gl");
const allocator = @import("allocator.zig");
const mesh = @import("mesh.zig");

// const za = @import("zalgebra");
// const Vec3 = za.Vec3;
// const Mat4 = za.Mat4;

const window = @import("window.zig");

const blah = struct { x: i32 = 0 };

pub fn cool(x: i32) void {
    std.debug.print("{i}\n", .{x});
}

pub fn main() !void {
    std.debug.print("[Main]: Hello!\n", .{});

    allocator.initialize();
    defer allocator.terminate();

    mesh.initialize();

    const data = try allocator.create(blah);
    defer allocator.destroy(data);

    std.debug.print("{any}\n", .{data});

    data.x = 1;

    std.debug.print("{any}", .{data});

    // window.initialize();
    // defer window.terminate();

    // var projection = za.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);
    // projection.debugPrint();

    // while (window.shouldClose()) {
    //     gl.ClearColor(1.0, 1.0, 1.0, 1.0);
    //     gl.Clear(gl.COLOR_BUFFER_BIT);
    //     window.swapBuffers();
    //     window.pollEvents();
    // }

}
