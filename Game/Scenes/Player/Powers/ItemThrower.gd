extends Node3D

@export var item: PackedScene
@onready var player: Player = get_parent().get_parent()

var throwImpulse: float = 10.0
var aiming: bool = false
@export var action: String = "main_action"

var model: PackedScene = preload("res://Scenes/Player/Powers/PotionMesh.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if aiming:
		showPreview()
	else:
		$Sprite3D.hide()
	
func showPreview():
	var dir: Vector3 = getThrowDirection(-1.0)
	var vel: Vector3 = dir * getThrowImpulse()
	
	var timeStep: float = 0.1
	var startPosition: Vector3 = getThrowStartPosition(dir)
	var g: float = -ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	g = g * 1.0 # Gravity scale
	var drag: float = -ProjectSettings.get_setting("physics/3d/default_linear_damp", 0.0) 
	
	var lineStart: Vector3 = startPosition
	var lineEnd: Vector3 = startPosition
	
	var colors: Array
	if dir.y < 0.0:
		colors = [Color(1.0, 0.0, 0.0, 1.0), Color(1.0, 0.0, 0.0, 1.0)]
	else:
		colors = [Color(97.0/255.0, 167.0/255.0, 186.0/255.0, 1.0), Color(97.0/255.0, 167.0/255.0, 186.0/255.0, 1.0)]
	
	var lineWidth: float = 10.0
	for i in range(1, 50):
		vel.y += g * timeStep
		lineEnd = lineStart
		lineEnd += vel * timeStep
		
		vel *= clamp(1.0 - drag * timeStep, 0, 1) # Drag
		
		var ray := raycastQuery(lineStart, lineEnd)
		if not ray.is_empty():
			DebugDraw.draw_line(lineStart, ray.position, lineWidth, colors[i%2])
			$Sprite3D.show()
			$Sprite3D.global_position = ray.position + ray.normal * 0.1
			
			if Vector3.LEFT.is_equal_approx(-ray.normal):
				$Sprite3D.rotation = Vector3(0.0, PI / 2.0, 0.0)
			else:
				$Sprite3D.global_transform = $Sprite3D.global_transform.looking_at($Sprite3D.global_position + ray.normal, Vector3.LEFT)
			return
		
		DebugDraw.draw_line(lineStart, lineEnd, lineWidth, colors[i%2])
		
		lineStart = lineEnd
	
	# Probably aiming the void, hide the sprite
	$Sprite3D.hide()
	
func raycastQuery(pointA: Vector3, pointB: Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	
	var query =  PhysicsRayQueryParameters3D.create(pointA, pointB, 0b101)
	query.hit_from_inside = false
	
	var result = space_state.intersect_ray(query)
	return result

func getThrowImpulse():
	var direction: Vector2 = get_viewport().get_mouse_position() / Vector2(get_viewport().get_visible_rect().size)
	direction.y = 1.0 - direction.y
	return throwImpulse + direction.y * 0.0

func getThrowStartPosition(dir: Vector3):
	return player.global_position + Vector3.UP * 1.0 + dir * 1.0

func getThrowDirection(depth: float):
	var direction: Vector2 = get_viewport().get_mouse_position() / Vector2(get_viewport().get_visible_rect().size)
	direction.y = 1.0 - direction.y
	direction = (direction - Vector2(0.5, 0.15))
	direction.x *= 6.0
	direction.y *= 2.0
	
	var resultDir := Vector3(direction.x, direction.y, depth).normalized()
	
	return get_viewport().get_camera_3d().get_global_transform().basis * resultDir

func activateSpell():
	aiming = false
	
	var newItem: RigidBody3D = item.instantiate()
	
	var direction = getThrowDirection(-1.0)
	if direction.y < 0.0:
		return
	
	var target = to_global(direction)
	var globalDirection = (target - global_position).normalized()
	
	add_child(newItem)
	newItem.global_position = getThrowStartPosition(direction)
	newItem.apply_central_impulse(globalDirection * getThrowImpulse())