const std = @import("std");
const gl = @import("gl");
const za = @import("zalgebra");
const glfw = @import("mach-glfw");
const stbi = @import("zstbi");
const allocator = @import("utility/allocator.zig");
const window = @import("graphics/window.zig");
const shader = @import("graphics/shader.zig");
const mesh = @import("graphics/mesh.zig");
const texture = @import("graphics/texture.zig");
const heightmap = @import("graphics/heightmap.zig");

const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

pub fn main() !void {
    allocator.initialize();
    defer allocator.terminate();

    window.initialize();
    defer window.terminate();

    shader.initialize();
    defer shader.terminate();

    stbi.init(allocator.get());
    defer stbi.deinit();

    mesh.initialize();
    defer mesh.terminate();

    texture.initialize();
    defer texture.terminate();

    shader.new(
        "main",
        "shaders/vertex.vert",
        "shaders/fragment.frag",
    );

    gl.Viewport(0, 0, 1024, 768);

    shader.start("main");

    _ = heightmap.load("levels/test_height_map.png");

    const positions = [_]f32{
        -0.5, 0.5, 0.0, // top left
        -0.5, -0.5, 0.0, // bottom left
        0.5, -0.5, 0.0, // bottom right
        0.5, 0.5, 0.0, // top right
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

    //     0.0,
    //     1.0,
    //     1.0,
    // };

    const textureCoords = [_]f32{
        0.0, 0.0, // top left
        0.0, 1.0, // bottom left
        1.0, 1.0, // bottom right
        1.0, 0.0, // top right
    };

    const indices = [_]u32{ 0, 1, 2, 2, 3, 0 };

    mesh.new(
        "test",
        positions[0..],
        textureCoords[0..],
        indices[0..],
    );

    texture.new("textures/test.png");

    texture.use("test.png");

    var rotation: f32 = 0;
    while (!window.shouldClose()) {
        window.pollEvents();

        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.Clear(gl.DEPTH_BUFFER_BIT);

        const cameraMatrix = Mat4.perspective(65.0, 1024.0 / 768.0, 0.1, 100.0);
        shader.setMat4Uniform(shader.CAMERA_MATRIX_UNIFORM_LOCATION, cameraMatrix);

        var objectMatrix = Mat4.identity();
        objectMatrix = objectMatrix.translate(Vec3.new(0, 0, -1));
        objectMatrix = objectMatrix.rotate(rotation, Vec3.new(0, 1, 0));
        objectMatrix = objectMatrix.scale(Vec3.new(1, 1, 1));

        rotation += 1.5;

        shader.setMat4Uniform(shader.OBJECT_MATRIX_UNIFORM_LOCATION, objectMatrix);

        mesh.draw("test");

        window.swapBuffers();

        // window.close();
    }
}
