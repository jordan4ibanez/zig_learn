#version 460

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texturePos;
// layout (location = 1) in vec3 color;

layout (location = 0) uniform mat4 camera_matrix;
layout (location = 1) uniform mat4 object_matrix;
// The lower this value is, the blockier the graphics get.
layout (location = 2) uniform float ps1_blockiness;

// out vec3 pixel_color;
// out vec3 rgb;

// wobbly
// noperspective out vec3 rgb;

// wobbly
noperspective out vec2 textureCoordinate;

// out vec2 textureCoordinate;

const float fogStart = 3.0;
const float fogEnd = 4.0;
out vec4 fogColor;
out float fogAmount;

// Gives ps1 style fog.
float fogginess(const float dist) {
  return 1.0 - clamp((fogEnd - dist) / (fogEnd - fogStart), 0.0, 1.0);
}


void main() {
  gl_Position = camera_matrix * object_matrix * vec4(position.x, position.y, position.z, 1.0f);

  // gl_Position = (ceil(gl_Position * ps1_blockiness)) / ps1_blockiness;
  
  // fogAmount = fogginess(length(gl_Position.xyz));
  fogAmount = 0.0;

  textureCoordinate = texturePos;

  fogColor = vec4(0.2, 0.3, 0.3, 1.0); 
}

