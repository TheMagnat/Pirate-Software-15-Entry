shader_type spatial;

void vertex() {
	VERTEX.x += cos(TIME) * 10.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
