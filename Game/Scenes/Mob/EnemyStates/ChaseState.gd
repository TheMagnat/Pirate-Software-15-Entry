extends StateNode


var rotationSpeed: float = 2

@export var parent: CharacterBody3D
@export var target: Player
@export var parentView: Area3D

@export var nav: NavigationAgent3D

var speed = 4
var accel = 5

func onPhysicProcess(delta: float):
	
	if not target.canBeSeen() or target not in parentView.get_overlapping_bodies():
		get_parent().transitionTo("Idle")
	
	# get current target position
	var currentTargetPosition = target.global_position
	
	# Update the navigation agent target position
	nav.target_position = currentTargetPosition
	
	# Get the current direction
	var direction: Vector3 = nav.get_next_path_position() - parent.global_position
	direction.y = 0.0
	direction = direction.normalized()
	
	var new_transform = parent.transform.looking_at(parent.global_position + direction, Vector3.UP)
	parent.transform  = parent.transform.interpolate_with(new_transform, rotationSpeed * delta)

	parent.velocity = parent.velocity.lerp(direction * speed, accel * delta)
	parent.move_and_slide()
	
func enter():
	pass
	
func exit():
	pass