const std = @import("std");
const rl = @import("raylib");
const allocator = @import("../utility/allocator.zig");
const shader = @import("shader.zig");

// This looks redundant, but this type is designed like this for a very
// specific reason. It encapsulates the data in such a manor that
// it can easily work with Zig.
pub const Model = struct {
    mesh: *rl.Mesh,
    model: *rl.Model,
    vertices: std.ArrayList(f32),
    textureCoords: std.ArrayList(f32),
    indices: std.ArrayList(u16),
};

var database: std.StringHashMap(*Model) = undefined;

//* ON/OFF SWITCH. ==============================================

pub fn initialize() void {
    database = std.StringHashMap(*Model).init(allocator.get());
}

pub fn terminate() void {
    var databaseIterator = database.iterator();
    while (databaseIterator.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        destroyModel(value);

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
pub fn new(name: []const u8, vertices: std.ArrayList(f32), textureCoords: std.ArrayList(f32), indices: std.ArrayList(u16)) void {
    // var mesh = allocator.create(rl.Mesh);

    var model = allocator.create(Model);

    model.vertices = vertices;
    model.textureCoords = textureCoords;
    model.indices = indices;

    model.mesh = allocator.create(rl.Mesh);

    // Zig does not 0 out anything so we have to do that first.
    model.mesh.vertexCount = 0;
    model.mesh.triangleCount = 0;
    model.mesh.vertices = 0;
    model.mesh.texcoords = 0;
    model.mesh.texcoords2 = 0;
    model.mesh.normals = 0;
    model.mesh.tangents = 0;
    model.mesh.colors = 0;
    model.mesh.indices = 0;
    model.mesh.animVertices = 0;
    model.mesh.animNormals = 0;
    model.mesh.boneIds = 0;
    model.mesh.boneWeights = 0;
    model.mesh.boneMatrices = 0;
    model.mesh.boneCount = 0;
    model.mesh.vaoId = 0;
    model.mesh.vboId = 0;
    // Done.

    model.mesh.vertexCount = @intCast(vertices.items.len / 3);
    model.mesh.triangleCount = @intCast(indices.items.len / 3);

    model.mesh.vertices = vertices.items.ptr;
    model.mesh.texcoords = textureCoords.items.ptr;
    model.mesh.indices = indices.items.ptr;

    rl.uploadMesh(model.mesh, false);

    model.model = allocator.create(rl.Model);

    model.model.* = rl.loadModelFromMesh(model.mesh.*) catch |err| {
        std.log.err("[Model]: Failed to create model {s}. {s}", .{ name, @errorName(err) });
        std.process.exit(1);
    };

    // std.debug.print("hi\n", .{});

    // todo: make this go into the texture library.
    // model.model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = here

    _ = &textureName;
}

///
/// Destroy a mesh from GPU and CPU memory.
///
pub fn destroy(name: []const u8) void {
    const currentMesh = database.get(name) orelse {
        std.log.err("[Model]: Failed to destroy mesh {s}. Does not exist", .{name});
        std.process.exit(1);
    };
    defer allocator.destroy(currentMesh);

    // destroyMesh(name, currentMesh);

    const key: []const u8 = database.getKey(name) orelse {
        std.log.err("[Model]: Failed to free mesh {s} key. Does not exist", .{name});
        std.process.exit(1);
    };
    defer allocator.free(key);

    if (!database.remove(name)) {
        std.log.err("[Model]: Failed to remove mesh {s} from database. Does not exist", .{name});
        std.process.exit(1);
    }
}

///
/// Draw a mesh.
///
pub fn draw(name: []const u8) void {
    const currentMesh: *rl.Mesh = database.get(name) orelse {
        std.log.err("[Model]: Failed to draw mesh {s}. Does not exist", .{name});
        std.process.exit(1);
    };

    const blah = rl.Vector3.init(0, 0, 0);

    rl.drawModel(currentMesh, blah);

    // gl.BindVertexArray(currentMesh.vao);
    // gl.DrawElements(gl.TRIANGLES, currentMesh.length, gl.UNSIGNED_INT, 0);
}

//* INTERNAL API. ==============================================

fn destroyModel(model: *Model) void {
    _ = &model;
}

fn destroyMesh(mesh: *rl.Mesh) void {
    // Overriding the destruction method for a mesh.

    // First, set this thing to all null pointers so libc doesn't explode.
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

    rl.unloadMesh(mesh.*);
    allocator.destroy(mesh);
}
