extends Spell

@export var item: PackedScene
var throwImpulse: float = 10.0

func _process(_delta):
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
	if dir.y < 0.0 or on_cooldown:
		$Sprite3D/Sprite3D.material_override.set_shader_parameter("can", 0.0)
		colors = [Color(1.0, 0.0, 0.0, 1.0), Color(1.0, 0.0, 0.0, 1.0)]
	else:
		$Sprite3D/Sprite3D.material_override.set_shader_parameter("can", 1.0)
		colors = [Color(97.0/255.0, 167.0/255.0, 186.0/255.0, 1.0), Color(97.0/255.0, 167.0/255.0, 186.0/255.0, 1.0)]
	
	var lineWidth: float = 10.0
	for i in range(1, 25):
		vel.y += g * timeStep
		lineEnd = lineStart
		lineEnd += vel * timeStep
		
		vel *= clamp(1.0 - drag * timeStep, 0, 1) # Drag
		
		var ray := raycastQuery(lineStart, lineEnd, true)
		if not ray.is_empty():
			DebugDraw.draw_line(lineStart, ray.position, lineWidth, colors[i%2])
			$Sprite3D.show()
			$Sprite3D.global_position = ray.position + ray.normal * 0.1
			
			if Vector3.LEFT.is_equal_approx(-ray.normal):
				$Sprite3D.rotation = Vector3(0.0, PI / 2.0, 0.0)
			elif Vector3.RIGHT.is_equal_approx(-ray.normal):
				$Sprite3D.rotation = Vector3(0.0, -PI / 2.0, 0.0)
			else:
				$Sprite3D.global_transform = $Sprite3D.global_transform.looking_at($Sprite3D.global_position + ray.normal, Vector3.LEFT)
			return
		
		DebugDraw.draw_line(lineStart, lineEnd, lineWidth, colors[i%2])
		
		lineStart = lineEnd
	
	# Probably aiming the void, hide the sprite
	$Sprite3D.hide()

var projectileShape = preload("res://Scenes/Player/Powers/PotionProjectileShape.tres")
func raycastQuery(pointA: Vector3, pointB: Vector3, testOrigin: bool = false) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	
	var query =  PhysicsShapeQueryParameters3D.new()
	query.collision_mask = 0b101
	query.shape = projectileShape
	
	var trans := Transform3D()
	trans.origin = pointA
	
	query.transform = trans # From
	query.motion = pointB - pointA # Direction
	
	var collisionEncountered: bool = false
	if testOrigin:
		collisionEncountered = not space_state.intersect_shape(query).is_empty()
	
	if not collisionEncountered:
		collisionEncountered = space_state.cast_motion(query)[1] < 1.0
		
	if collisionEncountered:
		var rayQuery = PhysicsRayQueryParameters3D.create(pointA, pointB + pointA.direction_to(pointB) * 1.0)
		rayQuery.collision_mask = 0b101
		var rayResult = space_state.intersect_ray(rayQuery)
		
		if not rayResult:
			rayResult.position = pointB
			rayResult.normal = pointB.direction_to(pointA)
		
		return rayResult
		
	return {}
	
func getThrowImpulse():
	var level := maxi(1, Save.unlockable[Player.IvyWall])
	var direction: Vector2 = get_viewport().get_mouse_position() / Vector2(get_viewport().get_visible_rect().size)
	direction.y = 1.0 - direction.y
	return throwImpulse + ((direction.y * direction.y) * (level - 1))

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
	var newItem: RigidBody3D = item.instantiate()
	
	var direction = getThrowDirection(-1.0)
	
	if direction.y < 0.0:
		return false
	
	var target = to_global(direction)
	var globalDirection = (target - global_position).normalized()
	
	get_node("../../../").add_child(newItem)
	newItem.global_position = getThrowStartPosition(direction)
	newItem.apply_central_impulse(globalDirection * getThrowImpulse())
	var randValue: float = randf_range(-0.25, 0.25)
	
	newItem.apply_torque_impulse(Vector3(direction.z + randValue, 0.0, (-direction.x) + randValue) * 10.0)
	
	return true
