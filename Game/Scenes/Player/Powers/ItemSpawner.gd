extends Node3D

@export var item: PackedScene
@onready var player: Player = get_parent().get_parent()

var aiming: bool = false
@export var action: String = "secondary_action"

var model: PackedScene = preload("res://Scenes/Player/Powers/IvyMesh.tscn")

func _process(delta):
	if aiming:
		showPreview()
	else:
		$Sprite3D.hide()

func showPreview():
	$Sprite3D.show()
	
	var position = getSpawnPosition()
	
	if not position:
		$Sprite3D.material_override.set_shader_parameter("can", 0.0)
	else:
		$Sprite3D.rotation.y = getRotationAngle(position)
		$Sprite3D.global_position = position + Vector3.UP * 0.1
		
		if player.global_position.distance_to(position) < 3:
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
	aiming = false
	
	var spawnPosition = getSpawnPosition()
	if not spawnPosition:
		return
		
	if player.global_position.distance_to(spawnPosition) < 3:
		return
	
	var newItem = item.instantiate()
	add_child(newItem)

	newItem.global_position = spawnPosition
	newItem.rotate_y(getRotationAngle(spawnPosition))
	newItem.startGrowing()
