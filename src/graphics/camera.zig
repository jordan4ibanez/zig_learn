const std = @import("std");
const za = @import("zalgebra");
const shader = @import("shader.zig");
const gl = @import("gl");
const window = @import("window.zig");

const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

var clearColor: Vec3 = Vec3.new(0, 0, 0);
var cameraPosition: Vec3 = Vec3.new(0, 0, 0);
var cameraPitch: f32 = 0;
var cameraYaw: f32 = 0;
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
/// No Z component, will get to that if needed.
///
pub fn setCameraRotation(pitch: f32, yaw: f32) void {
    cameraPitch = pitch;
    cameraYaw = yaw;
}

///
/// Flushes the matrix into the shader's uniform.
///
pub fn updateCameraMatrix() void {
    // Long story short, the world moves around the camera.
    var cameraMatrix = Mat4.perspective(65.0, window.getAspectRatio(), 0.1, 100.0);

    // Note: This is first rotated into +z so I can debug this as I go.
    cameraMatrix = cameraMatrix.rotate(180.0, Vec3.new(0, 1, 0));

    cameraMatrix = cameraMatrix.rotate(cameraYaw, Vec3.new(1, 0, 0));
    cameraMatrix = cameraMatrix.rotate(cameraPitch, Vec3.new(0, 1, 0));

    shader.setMat4Uniform(shader.CAMERA_MATRIX_UNIFORM_LOCATION, cameraMatrix);
}

pub fn updateObjectMatrix(x: f32, y: f32, z: f32, pitch: f32, yaw: f32) void {
    var objectMatrix = Mat4.identity();

    objectMatrix = objectMatrix.translate(Vec3.new(x, y, z).sub(cameraPosition));

    objectMatrix = objectMatrix.rotate(yaw, Vec3.new(1, 0, 0));
    objectMatrix = objectMatrix.rotate(pitch, Vec3.new(0, 1, 0));

    objectMatrix = objectMatrix.scale(Vec3.new(1, 1, 1));
    shader.setMat4Uniform(shader.OBJECT_MATRIX_UNIFORM_LOCATION, objectMatrix);
}

// todo: maybe make a lookat function :)

//* INTERNAL API. ==============================================
