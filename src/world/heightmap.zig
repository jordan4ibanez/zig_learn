const std = @import("std");
const rl = @import("raylib");
const zigimg = @import("zigimg");
const allocator = @import("../utility/allocator.zig");
const string = @import("../utility/string.zig");

pub const HeightMap = struct {
    width: u32,
    height: u32,
    data: [][]f32,
};

//* PUBLIC API. ==============================================

pub fn new(location: []const u8, yScale: f32) HeightMap {
    _ = &location;
    _ = &yScale;

    var image = zigimg.Image.fromFilePath(allocator.get(), location) catch |err| {
        std.log.err("[HeightMap]: Failed to load heightmap texture {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer image.deinit();

    if (image.pixelFormat() != zigimg.PixelFormat.grayscale16) {
        std.log.err("[HeightMap]: Heightmap must be 16 bit grayscale {s}. ", .{location});
        std.process.exit(1);
    }

    // Height map gets -1 width and height because the edges are vertex points.
    // (You make tiles out of each pixel quadrant)
    const w: u32 = @intCast(image.width);
    const h: u32 = @intCast(image.height);
    var map = HeightMap{
        .width = w - 1,
        .height = h - 1,
        .data = allocator.alloc([]f32, image.height),
    };

    for (0..image.height) |i| {
        map.data[i] = allocator.alloc(f32, image.width);
    }

    //* This is set up to have the bottom left of the image be the origin.

    var i: usize = 0;
    for (0..image.width) |x| {
        for (0..image.height) |y| {
            const rawValue = image.pixels.grayscale16[i].value;

            // Heightmap data is of scalar [-0.5 - 0.5]
            const floatingLiteral: f32 = @floatFromInt(rawValue);
            const converted = ((floatingLiteral / 65535.0) - 0.5) * yScale;

            const flippedX = (image.width - 1) - x;

            map.data[y][flippedX] = converted;

            i += 1;
        }
    }

    for (0..map.width + 1) |x| {
        for (0..map.height + 1) |y| {
            std.debug.print("x: {} | y: {} | data: {d}\n", .{ x, y, map.data[x][y] });
        }
    }

    return map;
}

///
/// Destroy a height map.
///
pub fn destroy(map: HeightMap) void {
    for (map.data) |element| {
        allocator.free(element);
    }
    allocator.free(map.data);
}

//* INTERNAL API. ==============================================
