#version 460

in vec3 pixel_color;
in vec3 rgb;

// Wobbly
// noperspective in vec3 pixel_color;
// noperspective in vec3 rgb;

// in vec2 output_texture_coordinate;

// uniform sampler2D texture_sampler;

out vec4 frag_color;

void main() {
   frag_color = vec4(rgb, 1.0f);//texture(texture_sampler, output_texture_coordinate) * vec4(pixel_color, 1.0);
}