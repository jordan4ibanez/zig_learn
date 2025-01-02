// I am very lazy, and I am also learning.
// Somehow, I will blow this thing up.
const std = @import("std");

var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
var allocator: std.mem.Allocator = undefined;
var valid_pointer = false;

pub fn initialize() void {
    // Thanks to Eyad for notifying that this will need to be [.init]
    // instead of [{}] when 0.14 releases.
    // todo: 0.14 release fix.
    // Freakman notes that it can literally be called as so:
    // gpa = .init;
    gpa = std.heap.GeneralPurposeAllocator(.{}){};
    allocator = gpa.allocator();
    valid_pointer = true;
}

pub fn terminate() void {
    const deinit_status = gpa.deinit();
    if (deinit_status == .leak) {
        std.log.err("[Allocator]: Error, memory leak.", .{});
    }
    valid_pointer = false;
}

pub fn create(comptime T: type) std.mem.Allocator.Error!*T {
    return try allocator.create(T);
}

pub fn destroy(ptr: anytype) void {
    allocator.destroy(ptr);
}

pub fn alloc(comptime T: type, n: usize) []T {
    return allocator.alloc(T, n) catch |err| {
        std.log.err("{}", .{err});
        std.process.exit(1);
    };
}

pub fn free(memory: anytype) void {
    allocator.free(memory);
}

pub fn realloc(old_mem: anytype, new_n: usize) @TypeOf(old_mem) {
    return allocator.realloc(old_mem, new_n) catch |err| {
        std.log.err("{}", .{err});
        std.process.exit(1);
    };
}

///
/// Only use this for talking to things like OpenGL and Vulkan.
///
pub fn get() std.mem.Allocator {
    if (!validPointer) {
        std.log.err("[Allocator]: The allocator is null", .{});
        std.process.exit(1);
    }
    return allocator;
}
