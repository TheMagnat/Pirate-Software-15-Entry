extends Node3D

@export var player: Player
var activated: bool = true

func findFirstMeshInstance(node: Node) -> Node:
	# Check if the current node is MeshInstance3D
	if node is MeshInstance3D:
		return node
	
	# If not, search through its children
	for child in node.get_children():
		var result = findFirstMeshInstance(child)
		if result:
			return result
	
	# If no child of the specified type is found, return null
	return null

var last_obstructing_objects = []
func _physics_process(_delta):
	if not activated: return
	
	if Engine.get_physics_frames() % 10 != 0:
		return
	
	var currentCamera: Camera3D = get_viewport().get_camera_3d()
	if not currentCamera:
		return
	
	var obstructing_objects = []
	var space_state = get_world_3d().direct_space_state
	while true:
		var parameters := PhysicsRayQueryParameters3D.create(player.global_position, currentCamera.global_position, 0x001, obstructing_objects)
		var collision_result = space_state.intersect_ray(parameters)
		if collision_result.has("collider"):
			if not collision_result.collider.is_in_group("Player"):
				obstructing_objects.push_back(collision_result.collider)
		else:
			break # No more collisions/collided with player
	
	for elem in last_obstructing_objects:
		var instance := findFirstMeshInstance(elem)
		if instance:
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	for elem in obstructing_objects:
		var instance := findFirstMeshInstance(elem)
		if instance:
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		
	last_obstructing_objects = obstructing_objects
