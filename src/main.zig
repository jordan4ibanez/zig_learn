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
const camera = @import("graphics/camera.zig");
const keyboard = @import("input/keyboard.zig");

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

    window.initialize(800, 600);
    defer window.terminate();

    shader.initialize();
    defer shader.terminate();

    stbi.init(allocator.get());
    defer stbi.deinit();

    mesh.initialize();
    defer mesh.terminate();

    texture.initialize();
    defer texture.terminate();

    keyboard.initialize();
    defer keyboard.terminate();

    shader.new(
        "main",
        "shaders/vertex.vert",
        "shaders/fragment.frag",
    );

    gl.Viewport(0, 0, 1024, 768);

    shader.start("main");

    // Set up the initial ps1 blockiness.
    // todo: make this a settings menu element.
    // window.setPs1Blockiness(40.0);

    //* Start heightmap into map data.

    const map = heightmap.new("levels/big_map_test.png", 5.0);
    defer heightmap.destroy(map);

    var vertexData: []f32 = allocator.alloc(f32, 0);
    defer allocator.free(vertexData);
    var indices: []u32 = allocator.alloc(u32, 0);
    defer allocator.free(indices);

    var indicesTemplate = [_]u32{ 0, 1, 2, 2, 3, 0 };

    for (0..map.width) |x| {
        for (0..map.height) |y| {
            const indexVertexData = vertexData.len;
            vertexData = allocator.realloc(vertexData, vertexData.len + 20);

            const heightTopLeft = map.data[x][y + 1];
            const heightBottomLeft = map.data[x][y];
            const heightBottomRight = map.data[x + 1][y];
            const heightTopRight = map.data[x + 1][y + 1];

            // todo: map texture to texture map with some kind of data type etc.
            // zig fmt: off
            const currentTile = [_]f32{
                
                @floatFromInt(x), heightTopLeft,     @floatFromInt(y + 1),   0.0, 0.0, // top left
                @floatFromInt(x), heightBottomLeft,  @floatFromInt(y),   0.0, 1.0, // bottom left
                @floatFromInt(x + 1), heightBottomRight, @floatFromInt(y),   1.0, 1.0, // bottom right
                @floatFromInt(x + 1), heightTopRight,    @floatFromInt(y + 1),   1.0, 0.0, // top right
                
            };
            // zig fmt: on

            @memcpy(vertexData[indexVertexData..], &currentTile);

            const indexIndices = indices.len;
            indices = allocator.realloc(indices, indices.len + 6);

            @memcpy(indices[indexIndices..], &indicesTemplate);

            // fixme: This is a workaround for the zig compiler being unfinished.
            for (0..indicesTemplate.len) |i| {
                indicesTemplate[i] += 4;
            }

            _ = &currentTile;
            _ = &x;
            _ = &y;
            _ = &indexVertexData;
            _ = &indexIndices;
            _ = &indicesTemplate;
            _ = &vertexData;
            _ = &indices;
        }
    }
    // std.debug.print("{any}\n", .{vertexData});
    // std.debug.print("{any}\n", .{indices});

    // _ = &positions;
    // _ = &textureCoords;
    // _ = &indices;

    // const vertexData = [_]f32{

    //     -0.5, 0.5, 0.0,   0.0, 0.0, // top left
    //     -0.5, -0.5, 0.0,  0.0, 1.0, // bottom left
    //     0.5, -0.5, 0.0,   1.0, 1.0, // bottom right
    //     0.5, 0.5, 0.0,    1.0, 0.0, // top right

    // };

    mesh.new(
        "test",
        vertexData,
        indices,
    );

    //* End heightmap into map data.

    texture.new("textures/sand.png");

    texture.use("sand.png");

    const rotation: f32 = -30;
    const translation: f32 = 0;

    while (!window.shouldClose()) {
        window.pollEvents();

        camera.setClearColor(0.2, 0.3, 0.3);
        camera.clearColorBuffer();
        camera.clearDepthBuffer();

        camera.setCameraPosition(10, 2, 0);
        camera.setCameraRotation(-20.0, rotation);
        camera.updateCameraMatrix();

        camera.updateObjectMatrix(0, 0, translation, 0, 0, 1.0);

        mesh.draw("test");

        if (keyboard.isPressed(glfw.Key.escape)) {
            window.close();
        }

        window.swapBuffers();

        // Make sure this is always last.
        keyboard._pressReleaseMemoryReset();
    }
}
