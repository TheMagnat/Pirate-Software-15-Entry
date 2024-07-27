shader_type canvas_item;

// Radius that the shader was designed for.
const float DEFAULT_RADIUS = 10.000000;

// Unit vector: (1, 0) or (0, 1)
uniform vec2 step;
// Desired blur radius.
uniform float radius = 10.000000;

uniform float strength: hint_range(0.0, 1.0);

uniform sampler2D screenTexture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec2 s = radius / DEFAULT_RADIUS * step / vec2(textureSize(screenTexture, 0));
	vec3 color =
		0.011194727 * texture(screenTexture, UV - 10.000000000 * s).rgb +
		0.039368696 * texture(screenTexture, UV - 8.415809477 * s).rgb +
		0.071308558 * texture(screenTexture, UV - 6.435363708 * s).rgb +
		0.110237219 * texture(screenTexture, UV - 4.455121108 * s).rgb +
		0.145451038 * texture(screenTexture, UV - 2.475020813 * s).rgb +
		0.163798995 * texture(screenTexture, UV - 0.495000167 * s).rgb +
		0.157439298 * texture(screenTexture, UV + 1.485004498 * s).rgb +
		0.129158204 * texture(screenTexture, UV + 3.465057055 * s).rgb +
		0.090434685 * texture(screenTexture, UV + 5.445220765 * s).rgb +
		0.054043977 * texture(screenTexture, UV + 7.425557483 * s).rgb +
		0.027564604 * texture(screenTexture, UV + 9.406126897 * s).rgb;
	COLOR.rgb = mix(texture(screenTexture, UV).rgb, color, strength);
	COLOR.a = 1.0;
}