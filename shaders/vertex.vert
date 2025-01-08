#version 460

layout (location = 0) in vec3 position;
// layout (location = 1) in vec2 texture_coordinate;
layout (location = 1) in vec3 color;

layout (location = 0) uniform mat4 camera_matrix;
layout (location = 1) uniform mat4 object_matrix;

// out vec3 pixel_color;
noperspective out vec3 rgb;
// out vec2 output_texture_coordinate;


// The lower this value is, the blockier the graphics get.
// todo: make this a uniform lol.
// todo: make a separate shader that doesn't have this at all for performance.
const float ps1Blockiness = 100.0;

void main() {
  gl_Position = camera_matrix * object_matrix * vec4(position.x, position.y, position.z, 1.0f);
  // vec3 pos = gl_Position.xyz / gl_Position.w;
  // vec2 xy = (pos.xy + (1.0, 1.0)) * (320.0, 240.0) * 0.5;

  // gl_Position.xy = xy;

  gl_Position = (floor(gl_Position * ps1Blockiness)) / ps1Blockiness;

  rgb = color;
}

