extends StateNode


var rotationSpeed: float = 20

@export var parent: CharacterBody3D
@export var target: Player
var lastTargetPosition: Vector3
@onready var parentView: Area3D = parent.view

@export var nav: NavigationAgent3D

var speed = 4
var accel = 5
var minTargetDist: float = 1

func onPhysicProcess(delta: float):
	
	# If we reached the last target position and we can't see it anymore, go back to Idle
	if lastTargetPosition.distance_to(parent.global_position) < minTargetDist and (not target.canBeSeen() or target not in parentView.get_overlapping_bodies()):
		get_parent().transitionTo("Idle")
	else:
		# get current target position
		lastTargetPosition = target.global_position
	
	
	# Update the navigation agent target position
	nav.target_position = lastTargetPosition
	
	# Get the current direction
	var direction: Vector3 = nav.get_next_path_position() - parent.global_position
	direction.y = 0.0
	direction = direction.normalized()
	
	var new_transform = parent.transform.looking_at(parent.global_position + direction, Vector3.UP)
	parent.transform  = parent.transform.interpolate_with(new_transform, rotationSpeed * delta)

	parent.velocity = parent.velocity.lerp(direction * speed, accel * delta)
	parent.move_and_slide()
	
func enter():
	lastTargetPosition = target.global_position
	
func exit():
	pass
