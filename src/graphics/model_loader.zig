const std = @import("std");
const gltf = @import("zgltf");
const allocator = @import("../utility/allocator.zig");
const mesh = @import("mesh.zig");

pub fn loadModel(location: []const u8) void {
    _ = &location;

    const buffer = std.fs.cwd().readFileAllocOptions(
        allocator.get(),
        location,
        5_000_000,
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

    const modelMesh: gltf.Mesh = loader.data.meshes.items[
        modelNode.mesh orelse {
            std.log.err("[Model Loader]: Has no mesh {s}.", .{location});
            std.process.exit(1);
        }
    ];

    const modelPrimitive: gltf.Primitive = modelMesh.primitives.items[0];

    for (modelPrimitive.attributes.items) |att| {
        std.debug.print("{}\n", .{att});
    }

    // std.debug.print("meshes size: {}\n", .{loader.data.meshes.items.len});
    // std.debug.print("primitives size: {}\n", .{loader.data.meshes.items[0].primitives.items.len});
    // const mainPrimitive: gltf.Primitive = loader.data.meshes.items[0].primitives.items[0];

    // const indicesIndex: usize = mainPrimitive.indices orelse {
    //     std.log.err("[Model Loader]: Cannot load model indices {s}.", .{location});
    //     std.process.exit(1);
    // };

    // std.debug.print("indices index: {}\n", .{indicesIndex});

    // var indicesOutput = std.ArrayList(u32).init(allocator.get());

    // const indicesAccessor: gltf.Accessor = loader.data.accessors.items[indicesIndex];

    // const indicesType = indicesAccessor.component_type;

    // if (indicesType == gltf.ComponentType.unsigned_short) {
    //     var temp = std.ArrayList(u16).init(allocator.get());
    //     defer temp.clearAndFree();

    //     loader.getDataFromBufferView(u16, &temp, loader.data.accessors.items[indicesIndex], buffer);

    //     // std.debug.print("blah: {}\n", .{temp.items[2]});

    //     for (temp.items) |index| {
    //         std.debug.print("{}, ", .{index});
    //     }
    // } else {
    //     std.log.err("[Model Loader]: Need to implement {any}.", .{indicesType});
    //     std.process.exit(1);
    // }

    // _ = &indicesOutput;
    // _ = &mainPrimitive;
    // _ = &indicesIndex;
    // for () |mesh| {
    //     for (mesh.primitives.items) |p| {
    //         std.debug.print("{any}\n", .{p.mode});
    //     }
    // }

    var meshIndex: usize = modelNode.mesh orelse {
        std.log.err("[Model Loader]: Cannot find mesh index {s}.", .{location});
        std.process.exit(1);
    };

    var positionData = std.ArrayList(f32).init(allocator.get());
    loader.getDataFromBufferView(f32, &positionData, loader.data.accessors.items[@intCast(meshIndex)], buffer);
    // for (boof.items) |i| {
    //     std.debug.print("{}", .{i});
    // }

    // ! Fake data for now.

    

    // modelNode.

    var indexData = std.ArrayList(u32).init(allocator.get());
    defer indexData.clearAndFree();

    for (0..positionData.items.len) |i| {
        indexData.append(@intCast(i)) catch |err| {
            std.log.err("[Model Loader]: Failed to append index {s}. {s}", .{ location, @errorName(err) });
            std.process.exit(1);
        };
    }

    positionData.clearAndFree();

    // _ = &boof;
    _ = &meshIndex;
    _ = &modelNode;
    _ = &loader;
    _ = &buffer;
}
