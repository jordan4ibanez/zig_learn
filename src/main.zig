const std = @import("std");
const gl = @import("gl");
const za = @import("zalgebra");
const allocator = @import("utility/allocator.zig");
const shader = @import("graphics/shader.zig");
const mesh = @import("graphics/mesh.zig");
const window = @import("graphics/window.zig");

const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

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

    const positions = [_]f32{
        1.0,
        1.0,
        1.0,
    };

    const colors = [_]f32{
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

    const indices = [_]u32{ 0, 1, 2 };

    mesh.new(
        "test",
        positions[0..],
        colors[0..],
        indices[0..],
    );

    while (!window.shouldClose()) {
        gl.ClearColor(1.0, 1.0, 1.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        // var projection: Mat4 = Mat4.identity(); //Mat4.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);

        mesh.draw("test");

        window.swapBuffers();
        window.pollEvents();

        window.close();
    }
}
