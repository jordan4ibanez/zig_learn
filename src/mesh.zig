const std = @import("std");
const allocator = @import("allocator.zig");
const gl = @import("gl");

const Mesh = struct {
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
    database.clearAndFree();
}
