const std = @import("std");
const gl = @import("gl");
const za = @import("zalgebra");
const allocator = @import("utility/allocator.zig");
const shader = @import("graphics/shader.zig");
const mesh = @import("graphics/mesh.zig");
const window = @import("graphics/window.zig");
const glfw = @import("mach-glfw");

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

    gl.Viewport(0, 0, 800, 600);

    shader.start("main");

    const positions = [_]f32{
        -0.5, -0.5, 0.0,

        0.5,  -0.5, 0.0,

        0.0,  0.5,  0.0,
    };

    _ = &positions;

    // const colors = [_]f32{
    //     1.0,
    //     0.0,
    //     0.0,

    //     0.0,
    //     1.0,
    //     0.0,

    //     0.0,
    //     0.0,
    //     1.0,
    // };

    // const indices = [_]u32{ 0, 1, 2 };

    // mesh.new(
    //     "test",
    //     positions[0..],
    //     // colors[0..],
    //     // indices[0..],
    // );

    var vao: gl.uint = 0;
    gl.GenVertexArrays(1, (&vao)[0..1]);
    gl.BindVertexArray(vao);

    var vbo: gl.uint = 0;
    gl.GenBuffers(1, (&vbo)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * positions.len), (&positions)[0..positions.len], gl.STATIC_DRAW);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(0);

    // var rotation: f32 = 0;
    while (!window.shouldClose()) {
        window.pollEvents();

        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        gl.Viewport(0, 0, 800, 600);
        // shader.start("main");

        gl.BindVertexArray(vao);
        gl.DrawArrays(gl.TRIANGLES, 0, 3);
        // const cameraMatrix = Mat4.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);
        // shader.setMat4Uniform(shader.CAMERA_MATRIX_UNIFORM_LOCATION, cameraMatrix);

        // var objectMatrix = Mat4.identity();
        // objectMatrix = objectMatrix.translate(Vec3.new(0, 0, -1));
        // objectMatrix = objectMatrix.rotate(rotation, Vec3.new(0, 1, 0));
        // objectMatrix = objectMatrix.scale(Vec3.new(1, 1, 1));

        window.swapBuffers();
        // rotation += 0.1;

        // shader.setMat4Uniform(shader.OBJECT_MATRIX_UNIFORM_LOCATION, objectMatrix);

        // mesh.draw("test");

        // window.close();
    }
}
