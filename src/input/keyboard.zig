const std = @import("std");
const glfw = @import("mach-glfw");
const allocator = @import("../utility/allocator.zig");

// This is over-engineered, but I want to make sure it works.

var keyDownDatabase: std.AutoHashMap(glfw.Key, bool) = undefined;
var keyPressDatabase: std.AutoHashMap(glfw.Key, bool) = undefined;
var keyReleaseDatabase: std.AutoHashMap(glfw.Key, bool) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    keyDownDatabase = std.AutoHashMap(glfw.Key, bool).init(allocator.get());
    keyPressDatabase = std.AutoHashMap(glfw.Key, bool).init(allocator.get());
    keyReleaseDatabase = std.AutoHashMap(glfw.Key, bool).init(allocator.get());
}

pub fn terminate() void {
    keyDownDatabase.clearAndFree();
    keyPressDatabase.clearAndFree();
    keyReleaseDatabase.clearAndFree();
}

//* PUBLIC API. ===========================================================

///
/// Check if a key is down.
///
pub fn isDown(key: glfw.Key) bool {
    return keyDownDatabase.get(key) orelse false;
}

///
/// Check if a key is pressed.
///
pub fn isPressed(key: glfw.Key) bool {
    return keyPressDatabase.get(key) orelse false;
}

///
/// Check if a key is released.
///
pub fn isReleased(key: glfw.Key) bool {
    return keyReleaseDatabase.get(key) orelse false;
}

//* INTERNAL API. ==============================================

pub fn _keyCallback(window: glfw.Window, key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods) void {
    switch (action) {
        glfw.Action.press => {
            keyDownDatabase.put(key, true) catch |err| {
                std.log.err("[Keyboard]: Failed to store press state in key down database. {s}", .{@errorName(err)});
                std.process.exit(1);
            };

            keyPressDatabase.put(key, true) catch |err| {
                std.log.err("[Keyboard]: Failed to store press state in key press database. {s}", .{@errorName(err)});
                std.process.exit(1);
            };
        },
        glfw.Action.release => {
            keyDownDatabase.put(key, false) catch |err| {
                std.log.err("[Keyboard]: Failed to store release state in key down database. {s}", .{@errorName(err)});
                std.process.exit(1);
            };

            keyReleaseDatabase.put(key, true) catch |err| {
                std.log.err("[Keyboard]: Failed to store release state in key release database. {s}", .{@errorName(err)});
                std.process.exit(1);
            };
        },
        glfw.Action.repeat => {
            keyDownDatabase.put(key, true) catch |err| {
                std.log.err("[Keyboard]: Failed to store repeat state in key down database. {s}", .{@errorName(err)});
                std.process.exit(1);
            };
        },
    }

    _ = &window;
    _ = &key;
    _ = &scancode;
    _ = &action;
    _ = &mods;
}

pub fn _pressReleaseMemoryReset() void {
    keyPressDatabase.clearRetainingCapacity();
    keyReleaseDatabase.clearRetainingCapacity();
}
