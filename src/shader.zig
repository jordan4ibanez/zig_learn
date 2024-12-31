const std = @import("std");
const allocator = @import("allocator.zig");
const gl = @import("gl");

var database: std.StringHashMap(u32) = undefined;

const 

pub fn initialize() void {
    database = std.StringHashMap(u32).init(allocator.get());
}

pub fn terminate() void {
    // todo: make this thing clean the GPU memory.
    database.clearAndFree();
}

//* PUBLIC API ==============================================

pub fn new(name: []const u8, vert_path: []const u8, frag_path: []const u8) void {
    std.debug.print("{s}{s}{s}\n", .{ name, vert_path, frag_path });
}
