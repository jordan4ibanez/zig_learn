const std = @import("std");
const stbi = @import("zstbi");
const allocator = @import("../utility/allocator.zig");

var database: std.StringHashMap(u8) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    stbi.setFlipVerticallyOnLoad(true);
    stbi.init(allocator.get());
    database = std.StringHashMap(u8).init(allocator.get());
}

pub fn terminate() void {
    stbi.deinit();

    //todo: free the gpu memory.

    database.clearAndFree();
}

//* PUBLIC API. ==============================================

///
/// Create a texture from a file location.
///
/// This will take in your /path/to/image.png and create a new string as the key image.png.
///
pub fn new(location: []const u8) void {
    _ = &location;

    const nullTerminatedLocation: [:0]const u8 = std.fmt.allocPrintZ(allocator.get(), "{s}", .{location}) catch |err| {
        std.log.err("[Texture]: Failed to null terminate string {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(nullTerminatedLocation);

    var blah = stbi.Image.loadFromFile(nullTerminatedLocation, 4) catch |err| {
        std.log.err("[Texture]: Failed to load texutre {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    blah.deinit();

    

    _ = &blah;
}
