const std = @import("std");
const gl = @import("gl");
// const za = @import("zalgebra");
const allocator = @import("utility/allocator.zig");
const shader = @import("graphics/shader.zig");
const mesh = @import("graphics/mesh.zig");
const window = @import("graphics/window.zig");

// const Vec3 = za.Vec3;
// const Mat4 = za.Mat4;

// const blah = struct { x: i32 = 0 };

// pub fn cool(x: i32) void {
//     std.debug.print("{i}\n", .{x});
// }

pub fn main() !void {
    allocator.initialize();
    defer allocator.terminate();

    window.initialize();
    defer window.terminate();

    shader.initialize();
    defer shader.terminate();

    mesh.initialize();
    defer mesh.terminate();

    shader.new(
        "main",
        "shaders/vertex.vert",
        "shaders/fragment.frag",
    );

    shader.start("main");

    var positions = [_]f32{
        1.0,
        1.0,
        1.0,
    };

    var colors = [_]f32{
        1.0,
        0.0,
        0.0,

        0.0,
        1.0,
        0.0,

        0.0,
        0.0,
        1.0,
    };

    mesh.new(
        positions[0..],
        colors[0..],
    );

    // var projection = za.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);
    // projection.debugPrint();

    while (window.shouldClose()) {
        gl.ClearColor(1.0, 1.0, 1.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        window.swapBuffers();
        window.pollEvents();
    }
}
