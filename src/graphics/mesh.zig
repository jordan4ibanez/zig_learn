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
pub fn new(name: []const u8, vertices: []f32, textureCoords: []f32, indices: []u16) void {
    // var mesh = allocator.create(rl.Mesh);

    var mesh = allocator.create(rl.Mesh);

    // Zig does not 0 out anything so we have to do that first.
    mesh.vertexCount = 0;
    mesh.triangleCount = 0;
    mesh.vertices = 0;
    mesh.texcoords = 0;
    mesh.texcoords2 = 0;
    mesh.normals = 0;
    mesh.tangents = 0;
    mesh.colors = 0;
    mesh.indices = 0;
    mesh.animVertices = 0;
    mesh.animNormals = 0;
    mesh.boneIds = 0;
    mesh.boneWeights = 0;
    mesh.boneMatrices = 0;
    mesh.boneCount = 0;
    mesh.vaoId = 0;
    mesh.vboId = 0;
    // Done.

    // const verticesMutable = vertices.ptr;
    // const textureCoordsMutable = textureCoords.ptr;
    // var indicesMutable = indices;

    mesh.vertexCount = @intCast(vertices.len);
    mesh.triangleCount = @intCast(indices.len / 3);

    std.debug.print("Mesh count: {}\nindices tris: {}\n", .{ mesh.vertexCount, mesh.triangleCount });

    mesh.vertices = vertices.ptr;
    mesh.texcoords = textureCoords.ptr;
    mesh.indices = indices.ptr;

    rl.uploadMesh(mesh, false);

    const model = rl.loadModelFromMesh(mesh.*) catch |err| {
        std.log.err("[Mesh]: Failed to create model {s}. {s}", .{ name, @errorName(err) });
        std.process.exit(1);
    };

    // todo: set a texture somehow.

    _ = &model;
    // _ = &name;
    // _ = &vertices;
    // _ = &textureCoords;
    // _ = &indices;

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
