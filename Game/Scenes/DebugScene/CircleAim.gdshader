shader_type spatial;
render_mode unshaded;

uniform float can : hint_range(0.0, 1.0) = 1.0;

const float nbLines = 1.5;
const float speed = 1.0;
const float threshold = 0.2;
const float size = 0.3;

void fragment() {
	vec2 centredUv = ((UV - 0.5) * 2.0) * nbLines;
	float dist = max(abs(centredUv.x), abs(centredUv.y));

	if (!(fract(-dist + TIME * speed) < size)) {
		ALPHA = 0.0;
	}
	else {
		ALPHA = max(0.0, (1.25 - pow(dist, 2.0) * 0.75));
	}

	ALBEDO = mix(vec3(1.0, 0.0, 0.0), vec3(97.0/255.0, 167.0/255.0, 186.0/255.0), can);

}
