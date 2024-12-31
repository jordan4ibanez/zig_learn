const std = @import("std");
const glfw = @import("mach-glfw");

fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn main() !void {
    std.debug.print("hello\n", .{});

    // glfw.setErrorCallback(errorCallback);

    // if (!glfw.init()) {

    // }
}
