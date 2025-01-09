const NATIVE_ENDIAN = @import("builtin").target.cpu.arch.endian();
const std = @import("std");
const stbi = @import("zstbi");
const string = @import("../utility/string.zig");
const allocator = @import("../utility/allocator.zig");

pub const HeightMap = struct {
    width: u32,
    height: u32,
    data: [][]f32,
};

//* PUBLIC API. ==============================================

pub fn new(location: []const u8) HeightMap {
    const nullTerminatedLocation = string.nullTerminate(location);
    defer allocator.free(nullTerminatedLocation);

    var image = stbi.Image.loadFromFile(nullTerminatedLocation, 1) catch |err| {
        std.log.err("[Texture]: Failed to load texture {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer image.deinit();

    // Height map gets -1 width and height because the edges are vertex points.
    // (You make tiles out of each pixel quadrant)
    var map = HeightMap{
        .width = image.width - 1,
        .height = image.height - 1,
        .data = allocator.alloc([]f32, image.height),
    };
    for (0..image.height) |i| {
        map.data[i] = allocator.alloc(f32, image.width);
    }

    var i: usize = 0;
    for (0..image.width) |x| {
        for (0..image.height) |y| {
            const index = i * image.bytes_per_component;

            const byteData = [2]u8{ image.data[index], image.data[index + 1] };
            const rawValue: u16 = std.mem.readInt(u16, &byteData, NATIVE_ENDIAN);

            // Heightmap data is of scalar [0.0 - 1.0]
            const floatingLiteral: f32 = @floatFromInt(rawValue);
            const converted = floatingLiteral / 65535.0;

            const flippedY = (image.height - 1) - y;

            // this might need to be inverted on the Y axis.
            map.data[x][flippedY] = converted;

            // std.debug.print("{d}, {d} = {d}\n", .{ x, flippedY, converted });

            i += 1;
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
