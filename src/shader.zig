const std = @import("std");
const allocator = @import("allocator.zig");
const gl = @import("gl");
const file = @import("file.zig");

var database: std.StringHashMap(gl.uint) = undefined;

const position_vbo_location = 0;
const color_vbo_location = 1;

const camera_matrix_uniform_location = 0;
const object_matrix_uniform_location = 1;

pub fn initialize() void {
    database = std.StringHashMap(gl.uint).init(allocator.get());
}

pub fn terminate() void {
    // todo: make this thing clean the GPU memory.
    database.clearAndFree();
}

//* PUBLIC API ==============================================

pub fn new(name: []const u8, vertPath: []const u8, fragPath: []const u8) void {
    std.debug.print("{s} {s} {s}\n", .{ name, vertPath, fragPath });

    const programID = checkValidity(
        gl.CreateProgram(),
        "program ID",
        name,
    );

    const vertexID = checkValidity(
        gl.CreateShader(gl.VERTEX_SHADER),
        "vertex shader",
        name,
    );
    compileAndCheckShader(vertexID, name, vertPath);

    const fragmentID = checkValidity(
        gl.CreateShader(gl.FRAGMENT_SHADER),
        "fragment shader",
        name,
    );
    compileAndCheckShader(fragmentID, name, fragPath);

    linkShader(programID, vertexID, fragmentID);
    ensureShaderLink(programID, name);

    detachShaders(name, programID, vertexID, fragmentID);
}

///
/// For detaching and deleting a shader. Simply encapsulates the logic in this function.
///
fn deleteShader(name: []const u8, shaderKind: []const u8, programID: gl.uint, shaderID: gl.uint) void {
    gl.DetachShader(programID, shaderID);
    gl.DeleteShader(shaderID);
    if (gl.IsShader(shaderID) == gl.TRUE) {
        std.log.err("[Shader]: Failed to delete {s} shader in shader {s}.", .{ shaderKind, name });
        std.process.exit(1);
    }
}

///
/// When the shaders are compiled into the program, we can detach and delete them.
///
fn detachShaders(name: []const u8, programID: gl.uint, vertexID: gl.uint, fragmentID: gl.uint) void {
    deleteShader(name, "vertex", programID, vertexID);
    deleteShader(name, "fragment", programID, fragmentID);
}

///
/// Link insurance.
///
fn ensureShaderLink(id: gl.uint, name: []const u8) void {
    var linkStatus: gl.int = 0;
    gl.GetProgramiv(id, gl.LINK_STATUS, &linkStatus);
    if (linkStatus == gl.FALSE) {
        std.log.err("[Shader]: Failed to link {s} shader, id {d} .", .{ name, id });
        std.process.exit(1);
    }
}

///
/// Link vertex and frag to program.
///
fn linkShader(programID: gl.uint, vertexID: gl.uint, fragmentID: gl.uint) void {
    gl.AttachShader(programID, vertexID);
    gl.AttachShader(programID, fragmentID);
    gl.LinkProgram(programID);
}

///
/// Compile shader. Make sure compiled correctly.
///
fn compileAndCheckShader(id: gl.uint, name: []const u8, codePath: []const u8) void {
    const shaderCode: []const u8 = file.readToNullTerminatedString(codePath);
    defer allocator.free(shaderCode);
    // I took this part from https://github.com/slimsag/mach-glfw-opengl-example/blob/main/src/main.zig#L158
    // Ain't know way I'm gonna figure out that as a noobie.
    gl.ShaderSource(id, 1, (&shaderCode.ptr)[0..1], (&@as(gl.int, @intCast(shaderCode.len)))[0..1]);
    gl.CompileShader(id);
    var success: gl.int = 0;
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &success);
    if (success == gl.FALSE) {
        std.log.err("[Shader]: Failed to compile {s} shader, id {d} .", .{ name, id });
        std.process.exit(1);
    }
}

///
/// In OpenGL, when generating buffers, object, arrays, 0 means failure.
///
fn checkValidity(id: gl.uint, data_component: []const u8, name: []const u8) gl.uint {
    if (id == 0) {
        std.log.err("[Shader]: Failed to create {s} for shader {d}.", .{ data_component, name });
        std.process.exit(1);
    }
    return id;
}
