// I am very lazy, and I am also learning.
// Somehow, I will blow this thing up.
const std = @import("std");

var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
var allocator: std.mem.Allocator = undefined;

pub fn initialize() void {
    // Thanks to Eyad for notifying that this will need to be [.init]
    // instead of [{}] when 0.14 releases.
    // todo: 0.14 release fix.
    gpa = std.heap.GeneralPurposeAllocator(.{}){};
    allocator = gpa.allocator();
}

pub fn terminate() void {
    const deinit_status = gpa.deinit();
    if (deinit_status == .leak) {
        std.log.err("[Allocator]: Error, memory leak.", .{});
    }
}

pub fn create(comptime T: type) std.mem.Allocator.Error!*T {
    return try allocator.create(T);
}

pub fn destroy(ptr: anytype) void {
    allocator.destroy(ptr);
}
