// #version 460

// layout (location = 0) in vec3 position;
// // layout (location = 1) in vec2 texture_coordinate;
// // layout (location = 1) in vec3 color;

// // layout (location = 0) uniform mat4 camera_matrix;
// // layout (location = 1) uniform mat4 object_matrix;

// // out vec3 pixel_color;
// // out vec3 rgb;
// // out vec2 output_texture_coordinate;

// void main() {
//   gl_Position = vec4(position.x, position.y, 0.0, 1.0f);
// }

#version 330 core
layout (location = 0) in vec3 aPos;

out vec3 pixel_color;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);

    pixel_color = vec3(1);
}

