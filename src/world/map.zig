const std = @import("std");
const allocator = @import("../utility/allocator.zig");
const heightmap = @import("heightmap.zig");
const model = @import("../graphics/model.zig");

//? The map doesn't really have an on/off switch, it is loaded or it isn't.

// keep this here in case I forget. :P
// const indicesTemplate = [_]u32{ 0, 1, 2, 2, 3, 0 };

//* PUBLIC API. ===========================================================

///
/// Load up a map.
///
/// todo: this probably should organize a bit better somehow.
///
/// todo: this should maybe use json to put things in places.
///
///! note: This should probably use some kind of sub-rendering techniques.
///
///! note: Water should have a resolution of 0.25 x and y
///
pub fn load(location: []const u8) void {

    // todo: map texture to texture map with some kind of data type etc.
    // todo: I think just using an 8 bit png should work.
    // todo: and the json data could hold what each color data represents.

    const map = heightmap.new(location, 5.0);
    // todo: don't destroy this. Store it.
    defer heightmap.destroy(map);

    var vertices = std.ArrayList(f32).init(allocator.get());
    // defer vertices.clearAndFree();

    var textureCoordinates = std.ArrayList(f32).init(allocator.get());
    // defer textureCoordinates.clearAndFree();

    var indices = std.ArrayList(u16).init(allocator.get());
    // defer indices.clearAndFree();

    var i: u16 = 0;

    for (0..map.width) |x| {
        for (0..map.height) |y| {
            // const indexVertexData = vertices.len;
            // vertices = allocator.realloc(vertices, vertices.len + 20);

            const heightTopLeft = map.data[x][y + 1];
            const heightBottomLeft = map.data[x][y];
            const heightBottomRight = map.data[x + 1][y];
            const heightTopRight = map.data[x + 1][y + 1];

            const currentTileVertices = [_]f32{
                @floatFromInt(x), heightTopLeft, @floatFromInt(y + 1), // top left.
                @floatFromInt(x), heightBottomLeft, @floatFromInt(y), // bottom left.
                @floatFromInt(x + 1), heightBottomRight, @floatFromInt(y), // bottom right.
                @floatFromInt(x + 1), heightTopRight, @floatFromInt(y + 1), // top right.
            };

            vertices.appendSlice(&currentTileVertices) catch |err| {
                std.log.err("[Map]: Failed to append vertices {s}. {s}", .{ location, @errorName(err) });
                std.process.exit(1);
            };

            const currentTileTextureCoordinates = [_]f32{
                0.0, 0.0, // top left.
                0.0, 1.0, // bottom left
                1.0, 1.0, // bottom right.
                1.0, 0.0, // top right.
            };

            textureCoordinates.appendSlice(&currentTileTextureCoordinates) catch |err| {
                std.log.err("[Map]: Failed to append texture coordinates {s}. {s}", .{ location, @errorName(err) });
                std.process.exit(1);
            };

            const currentIndices = [_]u16{
                0 + i,
                1 + i,
                2 + i,
                2 + i,
                3 + i,
                0 + i,
            };

            indices.appendSlice(&currentIndices) catch |err| {
                std.log.err("[Map]: Failed to append indices {s}. {s}", .{ location, @errorName(err) });
                std.process.exit(1);
            };

            i += 4;
        }
    }

    model.new(
        "ground",
        "sand.png",
        vertices,
        textureCoordinates,
        indices,
    );
}

// std.debug.print("{any}\n", .{vertexData});
// std.debug.print("{any}\n", .{indices});

// _ = &positions;
// _ = &textureCoords;
// _ = &indices;

// const vertexData = [_]f32{

//     -0.5, 0.5, 0.0,   0.0, 0.0, // top left
//     -0.5, -0.5, 0.0,  0.0, 1.0, // bottom left
//     0.5, -0.5, 0.0,   1.0, 1.0, // bottom right
//     0.5, 0.5, 0.0,    1.0, 0.0, // top right

// };
