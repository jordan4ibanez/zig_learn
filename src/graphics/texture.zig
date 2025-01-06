const std = @import("std");
const stbi = @import("zstbi");
const allocator = @import("../utility/allocator.zig");

var database: std.StringHashMap(u8) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    stbi.init(allocator.get());
    _ = &database;
}

pub fn terminate() void {
    stbi.deinit();
}

//* PUBLIC API. ==============================================
