#version 460

// in vec3 pixel_color;
// in vec3 rgb;

// Wobbly
// noperspective in vec3 pixel_color;
// noperspective in vec3 rgb;

noperspective in vec2 textureCoordinate;

// in vec2 textureCoordinate;

in vec4 fogColor;
in float fogAmount;

uniform sampler2D textureSampler;

out vec4 frag_color;

void main() {
   frag_color = texture(textureSampler, textureCoordinate);
   if (frag_color.a == 0.0) {
      discard;
   }
   frag_color = mix(frag_color, fogColor, fogAmount); 
   frag_color.rgb /= frag_color.a;
}