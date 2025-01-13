const std = @import("std");
const glfw = @import("mach-glfw");

//* PUBLIC API. ===========================================================

///
/// Check if a key is down.
///
// pub fn isDown(key: glfw.Key) bool {
//     return (window.getKey(key) == glfw.Action.press);
// }

///
/// Check if a key is up.
///
// pub fn isUp(key: glfw.Key) bool {
//     return (window.getKey(key) == glfw.Action.release);
// }

pub fn _keyCallback(window: glfw.Window, key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods) void {
    std.debug.print("{any}\n", .{key});
    _ = &window;
    _ = &key;
    _ = &scancode;
    _ = &action;
    _ = &mods;
}
