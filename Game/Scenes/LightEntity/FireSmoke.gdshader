shader_type spatial;
//render_mode cull_disabled;
render_mode depth_draw_always;
render_mode unshaded;

uniform float alpha = 1.0;
uniform vec3 baseColor : source_color;
uniform vec3 emissionColor : source_color;
uniform float emissionStr = 4.0;
uniform sampler2D displacementMap;
uniform float displacementStr = 1.0;
uniform sampler2D alphaMask;

void vertex() {
	
	vec2 animatedUv = UV + vec2(0.0, -0.25) * TIME;
	
	float displacement = texture(displacementMap, animatedUv).r;
	VERTEX += NORMAL * (displacement * displacementStr);
}

void fragment() {
	float animationTime = COLOR.a;
	float alphaMaskValue = texture(alphaMask, UV).r;
	
	//EMISSION = emissionColor * max(0.0, animationTime - 0.5) * emissionStr;
	ALBEDO = mix(baseColor, emissionColor, animationTime);
	ALPHA = round((animationTime * 1.75 + 0.5) * alphaMaskValue);
}
