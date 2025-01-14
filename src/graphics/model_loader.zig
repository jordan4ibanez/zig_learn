const std = @import("std");
const allocator = @import("../utility/allocator.zig");
const gltf = @import("zgltf");

pub fn loadModel(location: []const u8) void {
    _ = &location;

    const buffer = std.fs.cwd().readFileAllocOptions(
        allocator.get(),
        "test-samples/rigged_simple/RiggedSimple.gltf",
        512_000,
        null,
        4,
        null,
    ) catch |err| {
        std.log.err("[Model Loader]: Failed to load file {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    var blah = gltf.init(allocator.get());

    defer blah.deinit();

    _ = &blah;
    _ = &buffer;
}
