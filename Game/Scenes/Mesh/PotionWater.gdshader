shader_type spatial;


uniform sampler2D noise : repeat_enable;
uniform sampler2D noiseXOffset : repeat_enable;
uniform sampler2D noiseYOffset : repeat_enable;

uniform float delta;

uniform float waterLevel : hint_range(0.0, 1.0);

uniform float spottedValue;
uniform float deadTime;

uniform float xTilt : hint_range(-10.0, 10.0);
uniform float yTilt : hint_range(-10.0, 10.0);

const float VERTEX_SCALER = 0.0003125;

void vertex() {
	float scaledTime = TIME * 2.0;

	float oldValue = VERTEX.z;
	vec3 oldNormal = NORMAL;
	
	VERTEX.z = waterLevel * 0.21; 
	
	//VERTEX.z *= 0.0;
	//if ()
	
	//vec2 offset = vec2(0.25, 0.25);
	//
	float center = (
		cos(VERTEX.y + scaledTime * 1.2458) * 5.0 + VERTEX.y * yTilt * 500.0 +
		sin(VERTEX.x * 25.0 + scaledTime) * 20.0 + VERTEX.x * xTilt * 500.0
	) * VERTEX_SCALER;
	VERTEX.z += center;
	//
	VERTEX.z = min(VERTEX.z, oldValue);
	//// 1 -> 0 donc (1 - 0) / 1 = 1
	//// -0.1 -> -0.2 donc (-0.1 - -0.2) / 0.1 = -0.1 + 0.2 = 0.1
	
	//VERTEX.z = oldValue;
	float level = 0.0;
	if (oldValue == 0.0) {
		level = 0.0;
	}
	else {
		level = abs((oldValue - VERTEX.z) / oldValue);
	}
		
	NORMAL = normalize(mix(oldNormal, vec3(0.0, 0.0, 1.0), level));
	//NORMAL = oldNormal;
	//NORMAL = vec3(0.0, 0.0, 1.0);
	//NORMAL = vec3(xTilt, 0.0, 1.0);
	
	//if (VERTEX.z >= -0.1) {
		//NORMAL = vec3(0.0, 1.0, 0.0);
	//}
	
}

vec4 toLinear(vec4 sRGB)
{
    bvec3 cutoff = lessThan(sRGB.rgb, vec3(0.04045));
    vec3 higher = pow((sRGB.rgb + vec3(0.055))/vec3(1.055), vec3(2.4));
    vec3 lower = sRGB.rgb/vec3(12.92);

    return vec4(mix(higher, lower, cutoff), sRGB.a);
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
	
	vec3 mainColor = vec3(0.25, 0.25, 0.9);
	vec3 subColor = vec3(0.25, 0.6, 0.9);
	
	vec3 deathColor = vec3(1.0, 0.0, 0.0);
	vec3 subDeathColor = vec3(1.0, 0.0, 0.0);
	
	vec3 color = mix(
		mix(mainColor, deathColor, spottedValue),
		mix(subColor, subDeathColor, spottedValue),
	noiseValue);
	
	ALBEDO = toLinear(vec4(color, 1.0)).rgb;
	
	ALBEDO *= 1.5;
	
	// Called for every pixel the material is visible on.
	//ALPHA = 0.9;
	//ALBEDO = vec3(0.0, UV.x, 0.0);
}
