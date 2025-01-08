const std = @import("std");
const stbi = @import("zstbi");
const gl = @import("gl");
const allocator = @import("../utility/allocator.zig");

var database: std.StringHashMap(gl.uint) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    stbi.setFlipVerticallyOnLoad(true);
    stbi.init(allocator.get());
    database = std.StringHashMap(gl.uint).init(allocator.get());
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
    const nullTerminatedLocation: [:0]const u8 = std.fmt.allocPrintZ(allocator.get(), "{s}", .{location}) catch |err| {
        std.log.err("[Texture]: Failed to null terminate string {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(nullTerminatedLocation);

    var image = stbi.Image.loadFromFile(nullTerminatedLocation, 4) catch |err| {
        std.log.err("[Texture]: Failed to load texture {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer image.deinit();

    var textureID: gl.uint = 0;
    gl.GenTextures(1, (&textureID)[0..1]);
    gl.BindTexture(gl.TEXTURE_2D, textureID);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, @intCast(image.width), @intCast(image.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data.ptr);
    gl.GenerateMipmap(gl.TEXTURE_2D);
    gl.BindTexture(gl.TEXTURE_2D, 0);
    if (gl.IsTexture(textureID) == gl.FALSE) {
        std.log.err("[Texture]: Failed to generate texture {s}. Not texture.", .{location});
        std.process.exit(1);
    }

    // Getting the file name here. //todo: This should probably be in a string library.

    var indexOfFileName: usize = 0;
    var stringIterator = std.mem.split(u8, location, "/");

    while (stringIterator.next()) |val| {
        _ = &val;
        indexOfFileName += 1;
    }

    stringIterator.reset();

    var fileName = allocator.alloc(u8, 0);

    var j: usize = 0;
    while (stringIterator.next()) |val| {
        j += 1;

        if (j == indexOfFileName) {
            fileName = allocator.realloc(fileName, val.len);
            @memcpy(fileName, val);
        }
    }

    if (fileName.len == 0) {
        std.log.err("[Texture]: Failed to find file name for {s}.", .{location});
        std.process.exit(1);
    }

    database.putNoClobber(fileName, textureID) catch |err| {
        std.log.err("[Texture]: Failed store texture {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
}
