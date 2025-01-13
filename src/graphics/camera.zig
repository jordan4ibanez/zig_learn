const std = @import("std");
const za = @import("zalgebra");
const shader = @import("shader.zig");
const gl = @import("gl");

const Vec3 = za.Vec3;

var cameraPosition: Vec3 = Vec3.new(0, 0, 0);

//* PUBLIC API. ===========================================================

///
/// Set the clear color for the camera.
///
pub fn setClearColor(r: f32, g: f32, b: f32) void {
    gl.ClearColor(r, g, b, 1.0);
}

///
/// Clear the camera's color buffer.
///
pub fn clearColorBuffer() void {
    gl.Clear(gl.COLOR_BUFFER_BIT);
}

///
/// Clear the camera's depth buffer.
///
pub fn clearDepthBuffer() void {
    gl.Clear(gl.DEPTH_BUFFER_BIT);
}
