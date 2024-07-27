@tool

extends StateNode


@export var checkpoints: PackedVector2Array
@export var useDedicatedDirection: bool = false
@export var dedicatedDirection: PackedVector2Array

var currentTarget: int = 0

var rotationSpeed: float = 2

@export var parent: CharacterBody3D

@export var nav: NavigationAgent3D

# Parameters
@export var neverIdle: bool = false

var speed = 4
var accel = 5
var minTargetDist: float = 1

func findNearestPoint():
	var parent2dPosition := Vector2(parent.global_position.x, parent.global_position.z)
	var nearest: int = 0
	var nearestDist: float = 100000
	for index in checkpoints.size():
		var currentDist = parent2dPosition.distance_squared_to(checkpoints[index])
		if currentDist < nearestDist:
			nearestDist = currentDist
			nearest = index
	
	return nearest

func onPhysicProcess(delta: float):
	# get current target position
	var target2d := checkpoints[currentTarget]
	var currentTargetPosition = Vector3(target2d.x, parent.global_position.y, target2d.y)
	
	# Update the navigation agent target position
	nav.target_position = currentTargetPosition
	
	# Get the current direction
	var direction: Vector3 = nav.get_next_path_position() - parent.global_position
	direction.y = 0.0
	direction = direction.normalized()
	
	var new_transform = parent.global_transform.looking_at(parent.global_position + direction, Vector3.UP)
	parent.global_transform  = parent.global_transform.interpolate_with(new_transform, rotationSpeed * delta)

	parent.velocity = parent.velocity.lerp(direction * speed, accel * delta)
	parent.move_and_slide()
	
	# Verify if we reached our target
	if parent.global_position.distance_to(currentTargetPosition) <= minTargetDist:
		if not neverIdle:
			if useDedicatedDirection:
				get_parent().get_node("Idle").keepOriginalDirection = true
				get_parent().get_node("Idle").originalDirection = dedicatedDirection[currentTarget]
			get_parent().transitionTo("Idle")
		
		currentTarget = (currentTarget+1) % checkpoints.size()
	
func enter():
	var nearestPoint: int = findNearestPoint()
	# If this test is true, the agent is lost and need to go the the nearest checkpoint
	if parent.global_position.distance_to(Vector3(checkpoints[nearestPoint].x, parent.global_position.y, checkpoints[nearestPoint].y)) > minTargetDist * 2.0:
		currentTarget = nearestPoint
	
func exit():
	pass
