shader_type canvas_item;

uniform sampler2D screenTexture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 5.0;

void fragment(){
	vec4 color = textureLod(screenTexture, SCREEN_UV, 5.0);
	COLOR = color;
}
