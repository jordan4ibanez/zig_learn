const std = @import("std");
const allocator = @import("allocator.zig");

///
/// Extract a file name from a location string.
///
/// This allocates. Ensure you free.
///
/// todo: test on windows.
///
pub fn getFileName(location: []const u8) []const u8 {
    var indexOfFileName: usize = 0;
    var stringIterator = std.mem.split(u8, location, "/");

    while (stringIterator.next()) |val| {
        _ = &val;
        indexOfFileName += 1;
    }

    stringIterator.reset();

    var fileName = allocator.alloc(u8, 0);

    var i: usize = 0;
    while (stringIterator.next()) |val| {
        i += 1;

        if (i == indexOfFileName) {
            fileName = allocator.realloc(fileName, val.len);
            @memcpy(fileName, val);
        }
    }

    if (fileName.len == 0) {
        std.log.err("[Texture]: Failed to find file name for {s}.", .{location});
        std.process.exit(1);
    }

    return fileName;
}
