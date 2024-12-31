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

    const vertex_code: []const u8 = file.readToNullTerminatedString(vert_path);
    defer allocator.free(vertex_code);

    const blah: [:0]const u8 = @as([:0]const u8, @ptrCast(vertex_code));

    std.debug.print("{s}", .{blah});

    // I took this part from https://github.com/slimsag/mach-glfw-opengl-example/blob/main/src/main.zig#L158
    // Ain't know way I'm gonna figure out that as a noobie.
    gl.ShaderSource(vertex_id, 1, (&vertex_code.ptr)[0..1], (&@as(c_int, @intCast(vertex_code.len)))[0..1]);

    std.debug.print("{} {}\n", .{ program_id, vertex_id });
}

///
/// In OpenGL, when generating buffers, object, arrays, 0 means failure.
///
fn check_validity(id: c_uint, data_component: []const u8, name: []const u8) c_uint {
    if (id == 0) {
        std.log.err("[Shader]: Failed to create {s} for shader {s}.", .{ data_component, name });
        std.process.exit(1);
    }
    return id;
}
