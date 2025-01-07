const std = @import("std");
const allocator = @import("allocator.zig");

//* PUBLIC API. ===========================================================

///
/// The easy way to read an entire file to a string buffer.
///
pub fn readToString(location: []const u8) []const u8 {
    const codeFile = std.fs.cwd().openFile(location, .{}) catch |err| {
        std.log.err("[File]: Failed to open file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };
    defer codeFile.close();

    const fileSizeBytes = codeFile.getEndPos() catch |err| {
        std.log.err("[File]: Failed to get file length for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    const buffer: []u8 = allocator.alloc(u8, fileSizeBytes);

    _ = codeFile.readAll(buffer) catch |err| {
        std.log.err("[File]: Failed to read file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    return buffer;
}

///
/// The easy way to read an entire file to a string buffer.
/// For talking to C.
///
pub fn readToNullTerminatedString(location: []const u8) [:0]const u8 {
    const codeFile = std.fs.cwd().openFile(location, .{}) catch |err| {
        std.log.err("[File]: Failed to open file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    defer codeFile.close();

    const fileSizeBytes = codeFile.getEndPos() catch |err| {
        std.log.err("[File]: Failed to get file length for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    const buffer: []u8 = allocator.alloc(u8, fileSizeBytes);
    defer allocator.free(buffer);

    _ = codeFile.readAll(buffer) catch |err| {
        std.log.err("[File]: Failed to read file for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    const nullTerminatedBuffer = std.fmt.allocPrintZ(allocator.get(), "{s}", .{buffer}) catch |err| {
        std.log.err("[File]: Failed to null terminate string for {s}. {s}", .{ location, @errorName(err) });
        std.process.exit(1);
    };

    return nullTerminatedBuffer;
}
