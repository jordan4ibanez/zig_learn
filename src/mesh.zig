const std = @import("std");
const allocator = @import("allocator.zig");

const Mesh = struct {
    todo: i32,
    // bjkasdfljsdf
};

var database: std.StringHashMap(u32) = undefined;

pub fn initialize() void {
    database = std.StringHashMap(u32).init(allocator.get());
}

pub fn terminate() void {
    database.clearAndFree();
}

