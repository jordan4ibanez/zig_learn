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

    if (loader.data.nodes.items.len == 0) {
        std.log.err("[Model Loader]: Loaded empty model {s}.", .{location});
        std.process.exit(1);
    }

    // Only loading the first node, the first primitive.
    // todo: animation of the first node, the first primitive.

    std.debug.print("{}\n", .{loader.data.nodes.items.len});

    var modelNode: gltf.Node = undefined;

    var found = false;

    for (loader.data.nodes.items) |node| {
        // I am terrible at using blender so I have to get rid of Empty.
        if (!std.mem.eql(u8, node.name, "Empty")) {
            modelNode = node;
            found = true;
            break;
        }
    }

    if (!found) {
        std.log.err("[Model Loader]: Cannot find model {s}.", .{location});
        std.process.exit(1);
    }

    const mainPrimitive: gltf.Primitive = loader.data.meshes.items[0].primitives.items[0];

    mainPrimitive.indices

    _ = &mainPrimitive;
    // for () |mesh| {
    //     for (mesh.primitives.items) |p| {
    //         std.debug.print("{any}\n", .{p.mode});
    //     }
    // }

    // var meshIndex: isize = @intCast(modelNode.mesh orelse {
    //     std.log.err("[Model Loader]: Cannot find mesh index {s}.", .{location});
    //     std.process.exit(1);
    // });
    // var boof = std.ArrayList(f32).init(allocator.get());
    // loader.getDataFromBufferView(f32, &boof, loader.data.accessors.items[@intCast(meshIndex)], buffer);
    // for (boof.items) |i| {
    //     std.debug.print("{}", .{i});
    // }

    // modelNode.

    // boof.clearAndFree();
    // _ = &boof;
    // _ = &meshIndex;
    _ = &modelNode;
    _ = &loader;
    _ = &buffer;
}
