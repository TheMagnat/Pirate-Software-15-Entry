shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D noiseTexture;
uniform sampler2D noiseTexture2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = TIME * 0.1;
	vec2 moveDirection = vec2(1.0, -0.25);
	vec2 moveDirection2 = vec2(1.0, 0.25);
	
	float noise1 = texture(noiseTexture, UV + moveDirection * t).r;
	float noise2 = texture(noiseTexture2, UV + moveDirection2 * t * 0.55).r;
	
	ALBEDO = vec3(1.0, 0.0, 0.5) * (noise1 * noise2 * 0.5);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
