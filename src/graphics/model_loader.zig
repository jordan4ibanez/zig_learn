const std = @import("std");
const allocator = @import("../utility/allocator.zig");
const gltf = @import("zgltf");

pub fn loadModel(location: []const u8) void {
    _ = &location;

    const buffer = std.fs.cwd().readFileAllocOptions(
        allocator.get(),
        location,
        512_000,
        null,
        4,
        null,
    ) catch |err| {
        std.log.err("[Model Loader]: Failed to load file {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(buffer);

    var loader = gltf.init(allocator.get());
    defer loader.deinit();

    loader.parse(buffer) catch |err| {
        std.log.err("[Model Loader]: Failed to parse file {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    var vertices = std.ArrayList(f32).init(allocator.get());
    defer vertices.deinit();

    for (loader.data.nodes.items) |node| {
        std.debug.print("Node's name: {s}\nChildren count: {}\nHave skin: {}\nHave mesh: {}\n", .{
            node.name,
            node.children.items.len,
            node.skin != null,
            node.mesh != null,
        });
    }

    _ = &loader;
    _ = &buffer;
}
