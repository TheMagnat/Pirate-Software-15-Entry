extends Spell

@export var item: PackedScene

func _process(delta):
	if aiming:
		showPreview()
	else:
		$Sprite3D.hide()

func showPreview():
	$Sprite3D.show()
	
	var pos = getSpawnPosition()
	
	if not pos:
		$Sprite3D.material_override.set_shader_parameter("can", 0.0)
	else:
		$Sprite3D.rotation.y = getRotationAngle(pos)
		$Sprite3D.global_position = pos + Vector3.UP * 0.1
		
		if player.global_position.distance_to(pos) < 3 or on_cooldown:
			$Sprite3D.material_override.set_shader_parameter("can", 0.0)
		else:
			$Sprite3D.material_override.set_shader_parameter("can", 1.0)
	
func getSpawnPosition():
	var mousePosition: Vector2 = get_viewport().get_mouse_position()
	
	var sceneCamera: Camera3D = get_viewport().get_camera_3d()
	var origin = sceneCamera.project_ray_origin(mousePosition)
	var direction =  sceneCamera.project_ray_normal(mousePosition)
	
	var space_state = get_world_3d().direct_space_state
	var query =  PhysicsRayQueryParameters3D.create(origin, origin + direction * 20.0, 0b001)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	
	return null

func getRotationAngle(spawnPosition: Vector3):
	# Relative to Player :
	#var spawnDirection: Vector3 = player.global_position.direction_to(spawnPosition)
	
	# Relative to Camera :
	var spawnDirection: Vector3 = -get_viewport().get_camera_3d().global_transform.basis.z
	return -Vector2(spawnDirection.x, spawnDirection.z).angle() + PI / 2
	
func activateSpell():	
	var spawnPosition = getSpawnPosition()
	if not spawnPosition:
		return false
		
	if player.global_position.distance_to(spawnPosition) < 3:
		return false
	
	var newItem = item.instantiate()
	add_child(newItem)

	newItem.global_position = spawnPosition
	newItem.rotate_y(getRotationAngle(spawnPosition))
	newItem.startGrowing()
	
	return true
