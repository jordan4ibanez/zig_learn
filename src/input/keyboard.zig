const std = @import("std");
const glfw = @import("mach-glfw");
const window = @import("../graphics/window.zig");

//* PUBLIC API. ===========================================================

///
/// Check if a key is down.
///
pub fn isDown(key: glfw.Key) bool {
    return (window.getKey(key) == glfw.Action.press);
}

///
/// Check if a key is up.
///
pub fn isUp(key: glfw.Key) bool {
    return (window.getKey(key) == glfw.Action.release);
}
