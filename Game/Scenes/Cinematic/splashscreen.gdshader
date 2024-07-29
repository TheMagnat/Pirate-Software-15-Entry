shader_type canvas_item;

uniform sampler2D noise;
uniform float offset : hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec2 p = UV - vec2(0.5, 0.5);
	float nx = texture(noise, UV + vec2(cos(4.4135 + p.x), sin(2.59135 + p.y))).r - 0.5;
	float ny = texture(noise, UV + vec2(sin(3.2135 + p.y), cos(3.849135 + p.x))).r - 0.5;
	if (length(p + vec2(nx, ny)) > offset) {
		COLOR.a = 0.0;
	}

	COLOR.gb *= 0.5 + offset * 0.5;
}
