const std = @import("std");
const allocator = @import("allocator.zig");
const gl = @import("gl");
const file = @import("file.zig");

var database: std.StringHashMap(u32) = undefined;

const position_vbo_location = 0;
const color_vbo_location = 1;

const camera_matrix_uniform_location = 0;
const object_matrix_uniform_location = 1;

pub fn initialize() void {
    database = std.StringHashMap(u32).init(allocator.get());
}

pub fn terminate() void {
    // todo: make this thing clean the GPU memory.
    database.clearAndFree();
}

//* PUBLIC API ==============================================

pub fn new(name: []const u8, vert_path: []const u8, frag_path: []const u8) void {
    std.debug.print("{s} {s} {s}\n", .{ name, vert_path, frag_path });

    const program_id = check_validity(
        gl.CreateProgram(),
        "program ID",
        name,
    );

    const vertex_id = check_validity(
        gl.CreateShader(gl.VERTEX_SHADER),
        "vertex shader",
        name,
    );

    compileAndCheckShader(vertex_id, name, vert_path);

    std.debug.print("{}\n", .{program_id});
}

///
/// Compile shader. Make sure compiled correctly.
///
fn compileAndCheckShader(id: gl.uint, name: []const u8, codePath: []const u8) void {
    const shaderCode: []const u8 = file.readToNullTerminatedString(codePath);
    defer allocator.free(shaderCode);
    // I took this part from https://github.com/slimsag/mach-glfw-opengl-example/blob/main/src/main.zig#L158
    // Ain't know way I'm gonna figure out that as a noobie.
    gl.ShaderSource(id, 1, (&shaderCode.ptr)[0..1], (&@as(c_int, @intCast(shaderCode.len)))[0..1]);
    gl.CompileShader(id);
    var success: c_int = 0;
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &success);
    if (success == gl.FALSE) {
        std.log.err("[Shader]: Failed to compile {s} shader, id {d} .", .{ name, id });
        std.process.exit(1);
    }
}

///
/// In OpenGL, when generating buffers, object, arrays, 0 means failure.
///
fn check_validity(id: c_uint, data_component: []const u8, name: []const u8) c_uint {
    if (id == 0) {
        std.log.err("[Shader]: Failed to create {s} for shader {d}.", .{ data_component, name });
        std.process.exit(1);
    }
    return id;
}
