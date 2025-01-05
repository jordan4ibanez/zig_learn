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

    // shader.new(
    //     "main",
    //     "shaders/vertex.vert",
    //     "shaders/fragment.frag",
    // );

    gl.Viewport(0, 0, 800, 600);

    // shader.start("main");

    const vertex: [:0]const u8 =
        \\#version 330 core
        \\layout (location = 0) in vec3 aPos;
        \\void main()
        \\{
        \\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
        \\}
    ;
    const fragment: [:0]const u8 =
        \\#version 330 core
        \\out vec4 FragColor;
        \\void main()
        \\{
        \\    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
        \\} 
    ;

    _ = &vertex;
    _ = &fragment;

    var vertexShader: gl.uint = 0;
    vertexShader = gl.CreateShader(gl.VERTEX_SHADER);
    gl.ShaderSource(vertexShader, 1, (&vertex.ptr)[0..1], (&@as(c_int, @intCast(vertex.len)))[0..1]);
    gl.CompileShader(vertexShader);

    var fragmentShader: gl.uint = 0;
    fragmentShader = gl.CreateShader(gl.FRAGMENT_SHADER);
    gl.ShaderSource(fragmentShader, 1, (&fragment.ptr)[0..1], (&@as(c_int, @intCast(fragment.len)))[0..1]);
    gl.CompileShader(fragmentShader);

    var shaderProgram: gl.uint = 0;
    shaderProgram = gl.CreateProgram();
    gl.AttachShader(shaderProgram, vertexShader);
    gl.AttachShader(shaderProgram, fragmentShader);
    gl.LinkProgram(shaderProgram);

    gl.UseProgram(shaderProgram);

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
    gl.BufferData(gl.ARRAY_BUFFER, 16, &positions, gl.STATIC_DRAW);
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

        // rotation += 0.1;

        // shader.setMat4Uniform(shader.OBJECT_MATRIX_UNIFORM_LOCATION, objectMatrix);

        // mesh.draw("test");

        window.swapBuffers();

        // window.close();
    }
}
