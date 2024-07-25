shader_type spatial;

render_mode cull_front, unshaded, depth_draw_never;

global uniform vec4 outline_color;
global uniform float outline_width;

uniform int forestType: hint_range(0, 4, 1);
uniform sampler2D noise;

void vertex() {
	
	if (forestType == 1) {
		float scaledTime = TIME * 0.75;
		float topValue = clamp((VERTEX.z + 220.0) / 320.0, 0.0, 1.0);
		float randValue = texture(noise, NODE_POSITION_WORLD.xz).r;
		VERTEX.x += cos(scaledTime + randValue * 15454.1541) * 10.0 * pow(topValue, 1.5);
		VERTEX.y += sin(scaledTime*0.959 + randValue * 2145.1541) * 10.0 * pow(topValue, 1.5);
	}
	else if (forestType == 2) {
		float scaledTime = TIME * 0.75;
		float topValue = clamp((VERTEX.y+100.0) / 320.0, 0.0, 1.0);
		float randValue = texture(noise, NODE_POSITION_WORLD.xz).r;
		VERTEX.x += cos(scaledTime + randValue * 15454.1541) * 30.0 * pow(topValue, 1.5);
		VERTEX.z += sin(scaledTime*0.959 + randValue * 2145.1541) * 20.0 * pow(topValue, 1.5);
	}
	else if (forestType == 3) {
		float scaledTime = TIME * 0.75;
		float topValue = clamp((VERTEX.y + 100.0) / 320.0, 0.0, 1.0);
		float randValue = texture(noise, NODE_POSITION_WORLD.xz).r;
		VERTEX.x += cos(scaledTime + randValue * 15454.1541) * 20.0 * pow(topValue, 1.5);
		VERTEX.z += sin(scaledTime*0.959 + randValue * 2145.1541) * 20.0 * pow(topValue, 1.5);
	}
	
	vec4 clip_position = 
			PROJECTION_MATRIX *
			(MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal =
			mat3(PROJECTION_MATRIX) *
			(mat3(MODELVIEW_MATRIX) * NORMAL);
	clip_position.xy +=
			normalize(clip_normal.xy) /
			VIEWPORT_SIZE *
			clip_position.w *
			outline_width;
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
