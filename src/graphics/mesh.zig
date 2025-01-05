const std = @import("std");
const gl = @import("gl");
const allocator = @import("../utility/allocator.zig");
const shader = @import("shader.zig");

const Mesh = struct {
    vao: gl.uint,
    vboPosition: gl.uint,
    vboColor: gl.uint,
    eboIndex: gl.uint,
    length: gl.sizei,
};

var database: std.StringHashMap(*Mesh) = undefined;

pub fn initialize() void {
    database = std.StringHashMap(*Mesh).init(allocator.get());
}

pub fn terminate() void {
    var databaseIterator = database.iterator();
    while (databaseIterator.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        destroyMesh(key, value);

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
pub fn new(name: []const u8, positions: []const f32) void {//, colors: []const f32, indices: []const u32) void {
    // std.debug.print("{any}, {any}\n", .{ positions, colors });

    var mesh = allocator.create(Mesh) catch |err| {
        std.log.err("[Mesh]: Failed to allocate for mesh {s}. {}", .{ name, err });
        std.process.exit(1);
    };

    mesh.vao = createVao();
    mesh.vboPosition = positionUpload(positions);
    // mesh.vboColor = colorUpload(colors);
    // mesh.eboIndex = indexUpload(indices);
    // mesh.length = @intCast(indices.len);

    unbindAndAddToDatabase(name, mesh);
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

    destroyMesh(name, currentMesh);

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
    const currentMesh: *Mesh = database.get(name) orelse {
        std.log.err("[Mesh]: Failed to draw mesh {s}. Does not exist", .{name});
        std.process.exit(1);
    };
    gl.BindVertexArray(currentMesh.vao);
    gl.DrawElements(gl.TRIANGLES, currentMesh.length, gl.UNSIGNED_INT, 0);
}

//* INTERNAL API. ==============================================

///
/// A simpler way to destroy Vertex Buffer Objects.
///
fn unbindAndDestroyVao(vaoId: gl.uint, meshName: []const u8) void {
    gl.BindVertexArray(0);
    var temp = vaoId;
    gl.DeleteVertexArrays(1, (&temp)[0..1]);
    if (gl.IsVertexArray(vaoId) == gl.TRUE) {
        std.log.err("[Mesh]: Failed to destroy vao for mesh {s}.", .{meshName});
        std.process.exit(1);
    }
}

///
/// A simpler way to destroy Element Buffer Objects.
///
fn destroyEbo(eboId: gl.uint, eboName: []const u8, meshName: []const u8) void {
    var temp = eboId;
    gl.DeleteVertexArrays(1, (&temp)[0..1]);
    if (gl.IsVertexArray(eboId) == gl.TRUE) {
        std.log.err("[Mesh]: Failed to destroy ebo {s} for mesh {s}.", .{ eboName, meshName });
        std.process.exit(1);
    }
}

///
/// A simpler way to destroy Vertex Buffer Objects.
///
fn destroyVbo(vboPosition: gl.uint, vboId: gl.uint, vboName: []const u8, meshName: []const u8) void {
    gl.DisableVertexAttribArray(vboPosition);
    var temp = vboId;
    gl.DeleteBuffers(1, (&temp)[0..1]);
    if (gl.IsBuffer(vboId) == gl.TRUE) {
        std.log.err("[Mesh]: Failed to destroy vbo {s} for mesh {s}.", .{ vboName, meshName });
        std.process.exit(1);
    }
}

///
/// Encapsulates the logic flow for destroying an OpenGL mesh.
///
fn destroyMesh(name: []const u8, mesh: *Mesh) void {
    gl.BindVertexArray(mesh.vao);
    destroyVbo(shader.POSITION_VBO_LOCATION, mesh.vboPosition, "position", name);
    destroyVbo(shader.COLOR_VBO_LOCATION, mesh.vboColor, "color", name);
    destroyEbo(mesh.eboIndex, "index", name);
    unbindAndDestroyVao(mesh.vao, name);
}

///
/// Unbinds from the mesh VAO. Then puts it into the database.
///
/// Keep in mind, this will clone the name string. So free it after you run this.
///
fn unbindAndAddToDatabase(name: []const u8, mesh: *Mesh) void {
    gl.BindVertexArray(0);

    const nameClone = allocator.alloc(u8, name.len);
    @memcpy(nameClone, name);

    database.putNoClobber(nameClone, mesh) catch |err| {
        std.log.err("[Mesh]: Failed to store mesh {s} in database. {}", .{ name, err });
        std.process.exit(1);
    };
}

///
/// Creates the initial Vertex Array Object and binds to it.
///
fn createVao() gl.uint {
    var vao: gl.uint = 0;
    gl.GenVertexArrays(1, (&vao)[0..1]);
    gl.BindVertexArray(vao);
    return vao;
}

///
/// Upload array of indices.
///
fn indexUpload(indices: []const u32) gl.uint {
    var eboIndex: gl.uint = 0;
    gl.GenBuffers(1, (&eboIndex)[0..1]);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, eboIndex);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);
    return eboIndex;
}

///
/// Upload an array of colors into the GPU.
///
fn colorUpload(colors: []const f32) gl.uint {
    var vboColor: gl.uint = 0;
    gl.GenBuffers(1, (&vboColor)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vboColor);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * colors.len), colors.ptr, gl.STATIC_DRAW);
    gl.VertexAttribPointer(vboColor, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(shader.COLOR_VBO_LOCATION);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    return vboColor;
}

///
/// Upload an array of positions into the GPU.
///
fn positionUpload(positions: []const f32) gl.uint {
    var vboPosition: gl.uint = 0;
    gl.GenBuffers(1, (&vboPosition)[0..1]);
    gl.BindBuffer(gl.ARRAY_BUFFER, vboPosition);
    gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * positions.len), positions.ptr, gl.STATIC_DRAW);
    gl.VertexAttribPointer(vboPosition, 3, gl.FLOAT, gl.FALSE, 0, 0);
    gl.EnableVertexAttribArray(shader.POSITION_VBO_LOCATION);
    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    return vboPosition;
}
