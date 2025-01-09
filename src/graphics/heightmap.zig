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

pub fn load(location: []const u8) HeightMap {
    var map: HeightMap = undefined;

    const nullTerminatedLocation = string.nullTerminate(location);
    defer allocator.free(nullTerminatedLocation);

    var image = stbi.Image.loadFromFile(nullTerminatedLocation, 1) catch |err| {
        std.log.err("[Texture]: Failed to load texture {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer image.deinit();

    // std.debug.print("{d}, {d}, {d}, {d}\n", .{ image.width, image.height, image.data.len, image.bytes_per_component });

    const len = image.data.len / image.bytes_per_component;
    for (0..len) |i| {
        const index = i * image.bytes_per_component;

        const byteData = [2]u8{ image.data[index], image.data[index + 1] };
        const rawValue: u16 = std.mem.readInt(u16, &byteData, .little);

        // Heightmap data is of scalar [0.0 - 1.0]
        const floatingLiteral: f32 = @floatFromInt(rawValue);

        // const converted
        _ = &floatingLiteral;

        // std.debug.print("{s}, {d}, {d}, {d}, {d}\n", .{ location, rawBytes, index, floatingValue, image.num_components });
    }

    _ = &map;
    return map;
}

//* INTERNAL API. ==============================================
