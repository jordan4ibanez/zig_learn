const std = @import("std");
const stbi = @import("zstbi");
const allocator = @import("../utility/allocator.zig");

var database: std.StringHashMap(u8) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    stbi.init(allocator.get());
    database = std.StringHashMap(u8).init(allocator.get());
}

pub fn terminate() void {
    stbi.deinit();

    //todo: free the gpu memory.

    database.clearAndFree();
}

//* PUBLIC API. ==============================================

pub fn new(location: []const u8) void {
    _ = &location;
}
