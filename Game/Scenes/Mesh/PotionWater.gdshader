shader_type spatial;

uniform sampler2D noise : repeat_enable;
uniform sampler2D noiseXOffset : repeat_enable;
uniform sampler2D noiseYOffset : repeat_enable;

uniform float delta;

uniform float liquidLevel;
uniform float removeValue;

uniform float xTilt : hint_range(-1.0, 1.0);
uniform float yTilt : hint_range(-1.0, 1.0);

const float VERTEX_SCALER = 0.0003125;

void vertex() {
	float scaledTime = TIME * 2.0;

	float oldValue = VERTEX.z;
	VERTEX.z *= 0.0;
	
	VERTEX.z += (
		cos(VERTEX.y + scaledTime * 1.2458) * 0.5 + VERTEX.y * yTilt * 500.0 +
		sin(VERTEX.x * 500.0 + scaledTime) * 0.45 + VERTEX.x * xTilt * 500.0
	) * VERTEX_SCALER;
	
	VERTEX.z = min(VERTEX.z, oldValue);
	
}

void fragment() {
	
	// Convert the X to the range [1 -> -1 -> 1]
	float loopX = abs(UV.x - 0.5);
	loopX = -(loopX - 0.25) * 4.0;
	
    // Sample the texture with the new UV coordinates
	vec2 tiltOffset = (vec2(0.0, yTilt) + loopX * vec2(0.0, xTilt * 1.0)) * 0.1;
	
	vec2 finalUv = UV + tiltOffset;
	
	vec2 uvOffset = vec2(texture(noiseXOffset, finalUv).r, texture(noiseYOffset, finalUv).r) * delta;
	vec2 offset = vec2(cos(TIME * 0.06245), sin(TIME * 0.05875));
	
	
	float noiseValue = texture(noise, finalUv + offset + uvOffset).r;
	
	ALBEDO = mix(vec3(0.25, 0.25, 0.9), vec3(0.25, 0.6, 0.9), noiseValue);
	// Called for every pixel the material is visible on.
	//ALPHA = 0.8;
	
	//ALBEDO = vec3(centredUvX, 0.0, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
