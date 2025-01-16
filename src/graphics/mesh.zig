const std = @import("std");
const rl = @import("raylib");
const allocator = @import("../utility/allocator.zig");
const shader = @import("shader.zig");

var database: std.StringHashMap(*rl.Model) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    database = std.StringHashMap(*rl.Model).init(allocator.get());
}

pub fn terminate() void {
    var databaseIterator = database.iterator();
    while (databaseIterator.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        rl.unloadModel(value);

        allocator.free(key);
        allocator.destroy(value);
    }

    database.clearAndFree();
}

//* PUBLIC API. ==============================================

///
/// Create a mesh from raw data.
///
/// Keep in mind, this will clone the name string. So free it after you run this.
///
pub fn new(name: []const u8, vertices: []const f32, textureCoords: []const f32, indices: []const u32) void {
    // var mesh = allocator.create(rl.Mesh);

    var mesh = allocator.create(rl.Mesh);

    mesh.vertexCount = @intCast(vertices.len);
    mesh.

    _ = &name;
    _ = &vertices;
    _ = &textureCoords;
    _ = &indices;

    // mesh.vao = createVao();
    // mesh.vboVertexData = vertexUpload(vertexData);
    // mesh.eboIndex = indexUpload(indices);
    // mesh.length = @intCast(indices.len);

}

///
/// Destroy a mesh from GPU and CPU memory.
///
pub fn destroy(name: []const u8) void {
    const currentMesh = database.get(name) orelse {
        std.log.err("[Mesh]: Failed to destroy mesh {s}. Does not exist", .{name});
        std.process.exit(1);
    };
    defer allocator.destroy(currentMesh);

    // destroyMesh(name, currentMesh);

    const key: []const u8 = database.getKey(name) orelse {
        std.log.err("[Mesh]: Failed to free mesh {s} key. Does not exist", .{name});
        std.process.exit(1);
    };
    defer allocator.free(key);

    if (!database.remove(name)) {
        std.log.err("[Mesh]: Failed to remove mesh {s} from database. Does not exist", .{name});
        std.process.exit(1);
    }
}

///
/// Draw a mesh.
///
pub fn draw(name: []const u8) void {
    const currentMesh: *rl.Mesh = database.get(name) orelse {
        std.log.err("[Mesh]: Failed to draw mesh {s}. Does not exist", .{name});
        std.process.exit(1);
    };

    const blah = rl.Vector3.init(0, 0, 0);

    rl.drawModel(currentMesh, blah);

    // gl.BindVertexArray(currentMesh.vao);
    // gl.DrawElements(gl.TRIANGLES, currentMesh.length, gl.UNSIGNED_INT, 0);
}

//* INTERNAL API. ==============================================
