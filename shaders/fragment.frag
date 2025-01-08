#version 460

// in vec3 pixel_color;
// in vec3 rgb;

// Wobbly
// noperspective in vec3 pixel_color;
// noperspective in vec3 rgb;

in vec2 textureCoordinate;

uniform sampler2D textureSampler;

out vec4 frag_color;

void main() {
   frag_color = texture(textureSampler, textureCoordinate); //* vec4(pixel_color, 1.0);
}