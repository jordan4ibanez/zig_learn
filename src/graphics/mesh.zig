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

pub fn new(positions: []const f32, colors: []const f32, indices: []const u32) void {
    std.debug.print("{any}, {any}\n", .{ positions, colors });

    const vboPosition = positionUpload(positions);

    const vboColor = colorUpload(colors);

    const vboIndex = indexUpload(indices);

    _ = &vboColor;
    _ = &vboIndex;
    std.debug.print("{any}, {any}, {any}\n", .{ positions, colors, vboPosition });
}

//* INTERNAL API. ==============================================

///
/// Upload array of indices.
///
fn indexUpload(indices: []const u32) gl.uint {
    var vboIndex: gl.uint = 0;
    gl.GenBuffers(1, (&vboIndex)[0..1]);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, vboIndex);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);
    return vboIndex;
}

///
/// Upload an array of colors into the GPU.
///
fn colorUpload(colors: []const f32) gl.uint {
    var vboColor: gl.uint = 0;
    gl.GenBuffers(1, (&vboColor)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vboColor);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * colors.len), colors.ptr, gl.STATIC_DRAW);
    gl.VertexAttribPointer(vboColor, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(shader.COLOR_VBO_LOCATION);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    return vboColor;
}

///
/// Upload an array of positions into the GPU.
///
fn positionUpload(positions: []const f32) gl.uint {
    var vboPosition: gl.uint = 0;
    gl.GenBuffers(1, (&vboPosition)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vboPosition);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * positions.len), positions.ptr, gl.STATIC_DRAW);
    gl.VertexAttribPointer(vboPosition, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(shader.POSITION_VBO_LOCATION);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    return vboPosition;
}
