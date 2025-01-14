const std = @import("std");
const allocator = @import("../utility/allocator.zig");
const heightmap = @import("../graphics/heightmap.zig");
const mesh = @import("../graphics/mesh.zig");

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
    const map = heightmap.new(location, 5.0);
    defer heightmap.destroy(map);

    var vertexData: []f32 = allocator.alloc(f32, 0);
    defer allocator.free(vertexData);
    var indices: []u32 = allocator.alloc(u32, 0);
    defer allocator.free(indices);

    var i: u32 = 0;

    for (0..map.width) |x| {
        for (0..map.height) |y| {
            const indexVertexData = vertexData.len;
            vertexData = allocator.realloc(vertexData, vertexData.len + 20);

            const heightTopLeft = map.data[x][y + 1];
            const heightBottomLeft = map.data[x][y];
            const heightBottomRight = map.data[x + 1][y];
            const heightTopRight = map.data[x + 1][y + 1];

            // todo: map texture to texture map with some kind of data type etc.
            // todo: I think just using an 8 bit png should work.
            // todo: and the json data could hold what each color data represents.
            // zig fmt: off
            const currentTile = [_]f32{
                @floatFromInt(x),     heightTopLeft,     @floatFromInt(y + 1), 0.0, 0.0, // top left
                @floatFromInt(x),     heightBottomLeft,  @floatFromInt(y),     0.0, 1.0, // bottom left
                @floatFromInt(x + 1), heightBottomRight, @floatFromInt(y),     1.0, 1.0, // bottom right
                @floatFromInt(x + 1), heightTopRight,    @floatFromInt(y + 1), 1.0, 0.0, // top right
            };
            // zig fmt: on

            @memcpy(vertexData[indexVertexData..], &currentTile);

            const indexIndices = indices.len;
            indices = allocator.realloc(indices, indices.len + 6);

            std.debug.print("curretN: {d}\n", .{i});

            const indexData = [_]u32{
                0 + i,
                1 + i,
                2 + i,
                2 + i,
                3 + i,
                0 + i,
            };

            @memcpy(indices[indexIndices..], &indexData);

            i += 4;

            _ = &currentTile;
            _ = &x;
            _ = &y;
            _ = &indexVertexData;
            _ = &indexIndices;
            _ = &vertexData;
            _ = &indices;
        }
    }

    mesh.new(
        "ground",
        vertexData,
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
