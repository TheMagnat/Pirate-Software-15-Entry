shader_type spatial;

uniform sampler2D tex: source_color,filter_linear_mipmap,repeat_disable;

uniform float spottedValue : hint_range(0.0, 1.0);
uniform float deadTime;

render_mode unshaded;

void vertex() {
	
	float value = sin(min(1.0, deadTime) * PI);
	
	VERTEX *= (1.0 + value);
}

void fragment() {
	
	float beforeMid = min(1.0, spottedValue * 2.0);
	float afterMid = max(0.0, (spottedValue - 0.5) * 2.0);
	
	float alphaValue = float((1.0 - UV.y) < beforeMid);
	
	ALBEDO = vec3(1.0, 0.75 - afterMid * 0.75, 0.0);
	
	ALPHA = alphaValue;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
