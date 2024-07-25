shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 fireColor : source_color = vec4(1.0);
uniform sampler2D fireTexture;
uniform sampler2D distortionTexture : repeat_enable;
uniform sampler2D distortionMaskTexture : repeat_disable;
uniform vec2 speed = vec2(0.0, 1.0);

void vertex() {
	//MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	//MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	
	vec2 movingUv = UV + speed * TIME;
	
	float distortion = texture(distortionTexture, movingUv).r;
	float distortionMask = texture(distortionMaskTexture, vec2(1.0-UV.y, 0)).r;
	vec2 distordedUv = UV + (distortion * distortionMask) * 0.25;
	
	
	float col = texture(fireTexture, distordedUv).r;

	
	float alpha = col;
	vec4 res = fireColor * col;
	
	ALBEDO = res.rgb;
	ALPHA = COLOR.a * alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
