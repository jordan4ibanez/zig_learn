const std = @import("std");
const gl = @import("gl");
const allocator = @import("../utility/allocator.zig");
const file = @import("../utility/file.zig");
const za = @import("zalgebra");

const Mat4 = za.Mat4;

var database: std.StringHashMap(gl.uint) = undefined;

pub const POSITION_VBO_LOCATION: gl.int = 0;
pub const COLOR_VBO_LOCATION: gl.int = 1;

pub const CAMERA_MATRIX_UNIFORM_LOCATION: gl.int = 0;
pub const OBJECT_MATRIX_UNIFORM_LOCATION: gl.int = 1;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    database = std.StringHashMap(gl.uint).init(allocator.get());
}

pub fn terminate() void {
    gl.UseProgram(0);
    var databaseIterator = database.iterator();
    while (databaseIterator.next()) |entry| {
        const currentID = entry.value_ptr.*;
        gl.DeleteProgram(currentID);
        if (gl.IsProgram(currentID) == gl.TRUE) {
            const currentName = entry.key_ptr.*;
            std.log.err("[Shader]: Failed to delete program {s}.", .{currentName});
            std.process.exit(1);
        }
    }

    database.clearAndFree();
}

//* PUBLIC API. ==============================================

///
/// Create a new shader from vertex and fragment files.
///
pub fn new(name: []const u8, vertPath: []const u8, fragPath: []const u8) void {
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

    database.put(name, programID) catch |err| {
        std.log.err("[Shader]: Failed to store shader {s} in database. {}", .{ name, err });
        std.process.exit(1);
    };

    std.debug.print("[Shader]: Successfully created shader {s}\n", .{name});
}

///
/// Start a shader.
///
pub fn start(name: []const u8) void {
    const currentID = database.get(name) orelse {
        std.log.err("[Shader]: Failed to start program {s}. Does not exist.", .{name});
        std.process.exit(1);
    };
    gl.UseProgram(currentID);
    std.debug.print("[Shader]: Started shader {s}.\n", .{name});
}

///
/// Simpler way to set Mat4 uniform data.
///
pub fn setMat4Uniform(location: gl.int, value: Mat4) void {
    gl.UniformMatrix4fv(location, 1, gl.FALSE, &value.data[0][0]);
}

//* INTERNAL API. ==============================================

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
        var infoLog: [512]u8 = std.mem.zeroes([512]u8);
        gl.GetShaderInfoLog(id, 512, null, &infoLog);
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
