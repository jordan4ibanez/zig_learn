const std = @import("std");
const za = @import("zalgebra");
const allocator = @import("utility/allocator.zig");
const rl = @import("raylib");
const heightMap = @import("graphics/heightmap.zig");
// const texture = @import("graphics/texture.zig");
// const glfw = @import("mach-glfw");

// const gl = @import("gl");
// const window = @import("graphics/window.zig");
// const shader = @import("graphics/shader.zig");
// const mesh = @import("graphics/mesh.zig");

// const map = @import("world/map.zig");
// const camera = @import("graphics/camera.zig");
// const keyboard = @import("input/keyboard.zig");
// const modelLoader = @import("graphics/model_loader.zig");

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

    rl.setTraceLogLevel(rl.TraceLogLevel.err);

    rl.initWindow(800, 800, "hi");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    if (true) {
        std.debug.print("was turning this thing into a heightmap!\n", .{});
        std.process.exit(0);
    }
    heightMap.new("levels/big_map_test.png", 1.0);

    // _ = &boof;

    // var mesh = allocator.create(rl.Mesh);

    // rl.drawModel()

    while (rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
    }

    // window.initialize(800, 600);
    // defer window.terminate();

    // shader.initialize();
    // defer shader.terminate();

    // mesh.initialize();
    // defer mesh.terminate();

    // texture.initialize();
    // defer texture.terminate();

    // keyboard.initialize();
    // defer keyboard.terminate();

    // shader.new(
    //     "main",
    //     "shaders/vertex.vert",
    //     "shaders/fragment.frag",
    // );

    // shader.start("main");

    // // Set up the initial ps1 blockiness.
    // // todo: make this a settings menu element.
    // // window.setPs1Blockiness(40.0);

    // map.load("levels/big_map_test.png");

    // texture.new("textures/sand.png");

    // texture.use("sand.png");

    // var rotation: f32 = -30;
    // const translation: f32 = 0;

    // modelLoader.loadModel("models/largemouth.glb");

    // while (!window.shouldClose()) {
    //     window.pollEvents();

    //     camera.setClearColor(0.2, 0.3, 0.3);
    //     camera.clearColorBuffer();
    //     camera.clearDepthBuffer();

    //     camera.setCameraPosition(10, 2, 0);
    //     camera.setCameraRotation(-20.0, rotation);
    //     camera.updateCameraMatrix();

    //     rotation += 1;

    //     camera.updateObjectMatrix(50, 0, translation, 0, 0, 1);

    //     // todo: the map should have a function to draw this lol. This is anarchic.
    //     // mesh.draw("ground");

    //     mesh.draw("model");

    //     if (keyboard.isPressed(glfw.Key.escape)) {
    //         window.close();
    //     }

    //     window.swapBuffers();

    //     // Make sure this is always last.
    //     keyboard._pressReleaseMemoryReset();
    // }
}
