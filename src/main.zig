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

// const positions = [_]f32{
//     -0.5, 0.5, 0.0, // top left
//     -0.5, -0.5, 0.0, // bottom left
//     0.5, -0.5, 0.0, // bottom right
//     0.5, 0.5, 0.0, // top right
// };

// const textureCoords = [_]f32{
//     0.0, 0.0, // top left
//     0.0, 1.0, // bottom left
//     1.0, 1.0, // bottom right
//     1.0, 0.0, // top right
// };

// const indices = [_]u32{ 0, 1, 2, 2, 3, 0 };

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

    const map = heightmap.new("levels/4square.png");
    defer heightmap.destroy(map);

    var vertexData: []f32 = allocator.alloc(f32, 0);
    defer allocator.free(vertexData);
    var indices: []u32 = allocator.alloc(u32, 0);
    defer allocator.free(indices);

    var indicesTemplate = [_]u32{ 0, 1, 2, 2, 3, 0 };

    for (0..map.width) |x| {
        for (0..map.height) |y| {
            const indexVertexData = vertexData.len;
            // positions = allocator.realloc(positions, positions.len + 12);

            const indexIndices = indices.len;
            indices = allocator.realloc(indices, indices.len + 6);

            @memcpy(indices[indexIndices..], &indicesTemplate);

            // fixme: This is a workaround for the zig compiler being unfinished.
            for (0..indicesTemplate.len) |i| {
                indicesTemplate[i] += 4;
            }

            _ = &x;
            _ = &y;
            _ = &indexVertexData;
            _ = &indexIndices;
            _ = &indicesTemplate;
            _ = &vertexData;
            _ = &indices;
        }
    }

    std.debug.print("{any}\n", .{indices});

    // _ = &positions;
    // _ = &textureCoords;
    // _ = &indices;

    // const vertexData = [_]f32{
    //     // zig fmt: off
    //     -0.5, 0.5, 0.0,   0.0, 0.0, // top left
    //     -0.5, -0.5, 0.0,  0.0, 1.0, // bottom left
    //     0.5, -0.5, 0.0,   1.0, 1.0, // bottom right
    //     0.5, 0.5, 0.0,    1.0, 0.0, // top right
    //     // zig fmt: on
    // };

    mesh.new(
        "test",
        vertexData,
        indices,
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
