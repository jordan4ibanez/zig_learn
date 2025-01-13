const std = @import("std");
const za = @import("zalgebra");
const shader = @import("shader.zig");
const gl = @import("gl");
const window = @import("window.zig");

const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

var clearColor: Vec3 = Vec3.new(0, 0, 0);
var cameraPosition: Vec3 = Vec3.new(0, 0, 0);
var cameraRotation: Vec3 = Vec3.new(0, 0, 0);
var cameraFOV: f32 = 65.0;

//* PUBLIC API. ===========================================================

///
/// Set the clear color for the camera.
///
pub fn setClearColor(r: f32, g: f32, b: f32) void {
    clearColor = Vec3.new(r, g, b);
    gl.ClearColor(r, g, b, 1.0);
}

///
/// Get the current camera clear color.
///
pub fn getClearColor() Vec3 {
    return Vec3.new(clearColor);
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

///
/// Set the camera's position.
///
pub fn setCameraPosition(x: f32, y: f32, z: f32) void {
    cameraPosition = Vec3.new(x, y, z);
}

///
/// Set the camera's rotation.
///
pub fn setCameraRotation(x: f32, y: f32, z: f32) void {
    cameraRotation = Vec3.new(x, y, z);
}

///
/// Flushes the matrix into the shader's uniform.
///
pub fn updateCameraMatrix() void {
    var cameraMatrix = Mat4.perspective(65.0, window.getAspectRatio(), 0.1, 100.0);

    // Note: This is first rotated into +z so I can debug this as I go.
    // todo: remove this, and probably switch this to lookAt()
    cameraMatrix = cameraMatrix.rotate(180.0, Vec3.new(0, 1, 0));

    cameraMatrix = cameraMatrix.rotate(cameraRotation.y(), Vec3.new(1, 0, 0));
    cameraMatrix = cameraMatrix.rotate(cameraRotation.x(), Vec3.new(0, 1, 0));

    shader.setMat4Uniform(shader.CAMERA_MATRIX_UNIFORM_LOCATION, cameraMatrix);
}

//* INTERNAL API. ==============================================