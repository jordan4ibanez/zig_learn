const std = @import("std");
const gl = @import("gl");
const allocator = @import("../utility/allocator.zig");
const shader = @import("shader.zig");

pub const Mesh = struct {
    vao: gl.uint,
    position: gl.uint,
    color: gl.uint,
    indices: gl.uint,
    length: u32,
};

var database: std.StringHashMap(u32) = undefined;

pub fn initialize() void {
    database = std.StringHashMap(u32).init(allocator.get());
}

pub fn terminate() void {
    // todo: make this thing clean the GPU memory.
    database.clearAndFree();
}

//* PUBLIC API. ==============================================

pub fn new(positions: []f32, colors: []f32) void {
    std.debug.print("{any}, {any}\n", .{ positions, colors });

    const vboPosition = positionUpload(positions);

    std.debug.print("{any}, {any}, {any}\n", .{ positions, colors, vboPosition });
}

//* INTERNAL API. ==============================================

///
/// Upload an array of positions into the GPU.
///
fn positionUpload(positions: []f32) gl.uint {
    var vboPosition: gl.uint = 0;
    gl.GenBuffers(1, (&vboPosition)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vboPosition);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * positions.len), positions.ptr, gl.STATIC_DRAW);
    gl.VertexAttribPointer(vboPosition, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(vboPosition);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    return vboPosition;
}
