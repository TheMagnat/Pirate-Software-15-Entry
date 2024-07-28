extends SpotLight3D

var distanceToHide: float = 50

func _physics_process(delta):
	if Engine.get_physics_frames() % 20 == 0:
		if get_viewport().get_camera_3d().global_position.distance_to(global_position) > distanceToHide:
			#hide()
			shadow_enabled = false
		else:
			#show()
			shadow_enabled = true
