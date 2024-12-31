const std = @import("std");
const allocator = @import("allocator.zig");

pub fn readToString(location: []const u8) []const u8 {
    const code_file = std.fs.cwd().openFile(location, .{}) catch |err| {
        std.log.err("[Shader]: Failed to open file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer code_file.close();

    var fileSizeBytes: []u8 = allocator.alloc(u8, 0);

    const blah = code_file.getEndPos() catch |err| {
        std.log.err("[Shader]: Failed to get file length for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    fileSizeBytes = allocator.realloc(fileSizeBytes, blah);

    _ = code_file.readAll(fileSizeBytes) catch |err| {
        std.log.err("[Shader]: Failed to read file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    return fileSizeBytes;
}

pub fn readToNullTerminatedString(location: []const u8) []const u8 {
    const code_file = std.fs.cwd().openFile(location, .{}) catch |err| {
        std.log.err("[Shader]: Failed to open file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer code_file.close();

    var buffer: []u8 = allocator.alloc(u8, 0);

    const fileSizeBytes = code_file.getEndPos() catch |err| {
        std.log.err("[Shader]: Failed to get file length for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    buffer = allocator.realloc(buffer, fileSizeBytes);

    _ = code_file.readAll(buffer) catch |err| {
        std.log.err("[Shader]: Failed to read file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    return buffer;
}
