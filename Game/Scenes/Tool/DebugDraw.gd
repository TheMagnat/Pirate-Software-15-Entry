extends Node

@onready var draw_debug = $MeshInstance3D

func _physics_process(_delta):
	draw_debug.mesh.clear_surfaces()
	
func draw_line(point_a: Vector3, point_b: Vector3, thickness: float = 10.0, color: Color = Color.RED):
	if point_a.is_equal_approx(point_b):
		return
	
	draw_debug.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	draw_debug.mesh.surface_set_color(color)
	
	var scale_factor: float = 100.0;
	var dir: Vector3 = point_a.direction_to(point_b);
	var EPSILON: float = 0.00001
	
	# Draw truncated pyramid
	var normal: Vector3 = Vector3(-dir.y, dir.x, 0).normalized() \
		if (abs(dir.x) + abs(dir.y) > EPSILON) \
		else Vector3(0, -dir.z, dir.y).normalized()
	
	normal *= thickness / scale_factor;
	
	var vertices_strip_order: PackedInt32Array = [4, 5, 0, 1, 2, 5, 6, 4, 7, 0, 3, 2, 7, 6]
	var target_position: Vector3 = (point_b - point_a)
	
	# Compute line mesh
	for v in range(14):
		var vertex: Vector3 = normal \
		if vertices_strip_order[v] < 4 \
		else normal + target_position
		
		var final_vert = vertex.rotated(dir, PI * (0.5 * (vertices_strip_order[v] % 4) + 0.25))
		
		# Offset
		final_vert += point_a

		draw_debug.mesh.surface_add_vertex(final_vert)
	
	#draw_debug.mesh.surface_add_vertex(point_a)
	#draw_debug.mesh.surface_add_vertex(point_b)
	
	draw_debug.mesh.surface_end()
