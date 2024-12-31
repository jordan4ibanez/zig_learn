// I am very lazy, and I am also learning, let me do this stupid shit. Thanks.
const std = @import("std");

var gpa = undefined;
var allocator = undefined;

pub fn initialize() void {
    gpa = std.heap.GeneralPurposeAllocator(.{}){};
    allocator = gpa.allocator();
}

pub fn destroy() void {
    const deinit_status = gpa.deinit();
    if (deinit_status == .leak) {
        std.log.err("[Allocator]: Error, memory leak.", .{});
    }
}
