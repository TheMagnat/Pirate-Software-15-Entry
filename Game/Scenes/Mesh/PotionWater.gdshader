shader_type spatial;

uniform sampler2D noise : repeat_enable;
uniform sampler2D noiseXOffset : repeat_enable;
uniform sampler2D noiseYOffset : repeat_enable;

uniform float delta;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uvOffset = vec2(texture(noiseXOffset, UV).r, texture(noiseYOffset, UV).r) * delta;
	
	
	vec2 offset = vec2(cos(TIME * 0.06245), sin(TIME * 0.05875));
	
	float noiseValue = texture(noise, UV + offset + uvOffset).r;
	
	ALBEDO = mix(vec3(0.25, 0.25, 0.9), vec3(0.25, 0.6, 0.9), noiseValue);
	// Called for every pixel the material is visible on.
	//ALPHA = 0.8;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
