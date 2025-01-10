#version 460

// in vec3 pixel_color;
// in vec3 rgb;

// Wobbly
// noperspective in vec3 pixel_color;
// noperspective in vec3 rgb;

in vec2 textureCoordinate;
in vec4 fogColor;
in float fogAmount;

uniform sampler2D textureSampler;

out vec4 frag_color;

void main() {
   frag_color = texture(textureSampler, textureCoordinate), 
   frag_color = mix(frag_color, fogColor, fogAmount); 
   frag_color.rgb /= frag_color.a;
}