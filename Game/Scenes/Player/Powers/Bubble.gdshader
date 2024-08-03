shader_type spatial;

uniform sampler2D noiseTexture;
uniform sampler2D colorNoiseTexture;
uniform float smoothness : hint_range(0.0, 1.0);

varying vec3 worldPosition;

void vertex() {
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float height = texture(noiseTexture, VERTEX.xz * smoothness + vec2(TIME * 0.1)).r;
	VERTEX += NORMAL * height; 
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	float fresnelValue = fresnel(2.0, NORMAL, VIEW);
	ALBEDO = texture(colorNoiseTexture, worldPosition.xz + vec2(TIME * 0.1)).rgb;
	ALPHA = COLOR.a * fresnelValue;
	
	ROUGHNESS = 0.0;
}
