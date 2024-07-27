@tool

extends StateNode


@export var targetPosition: Vector2
var currentTarget: int = 0

var rotationSpeed: float = 2

@export var parent: CharacterBody3D

@export var nav: NavigationAgent3D

var speed = 4
var accel = 5
var minTargetDist: float = 1

# Transition
@export var transitionState: String = "Turret"

func onPhysicProcess(delta: float):
	# get current target position
	var currentTargetPosition = Vector3(targetPosition.x, parent.global_position.y, targetPosition.y)
	
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
		get_parent().transitionTo(transitionState)
	
func enter():
	# If we request a position that is already our, change state instantly
	if parent.global_position.distance_to(Vector3(targetPosition.x, parent.global_position.y, targetPosition.y)) <= minTargetDist:
		get_parent().transitionTo(transitionState)
	
func exit():
	pass
