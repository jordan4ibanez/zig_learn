const std = @import("std");
const gl = @import("gl");
const allocator = @import("../utility/allocator.zig");
const shader = @import("shader.zig");

pub const Mesh = struct {
    vao: gl.uint,
    vboPosition: gl.uint,
    vboColor: gl.uint,
    eboIndex: gl.uint,
    length: usize,
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

        // todo: make this thing clean the GPU memory.

        allocator.free(key);
        allocator.destroy(value);
    }

    database.clearAndFree();
}

//* PUBLIC API. ==============================================

pub fn new(name: []const u8, positions: []const f32, colors: []const f32, indices: []const u32) void {
    std.debug.print("{any}, {any}\n", .{ positions, colors });

    var mesh = allocator.create(Mesh) catch |err| {
        std.log.err("[Mesh]: Failed to allocate for mesh {s}. {}", .{ name, err });
        std.process.exit(1);
    };

    mesh.vao = createVao();
    mesh.vboPosition = positionUpload(positions);
    mesh.vboColor = colorUpload(colors);
    mesh.eboIndex = indexUpload(indices);
    mesh.length = indices.len;

    unbindAndAddToDatabase(name, mesh);
}

//* INTERNAL API. ==============================================

// todo: mesh destroyer function.

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
