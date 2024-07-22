extends StateNode


var rotationSpeed: float = 2
var minTargetDist: float = 1

var speed = 4
var accel = 5

@export var parent: CharacterBody3D
@export var target: Vector3

@export var nav: NavigationAgent3D

# Transition parameters
# Security in case the mob is locked in this state
@onready var timeSinceStart: Timer = Timer.new()

func _ready():
	timeSinceStart.timeout.connect(func (): get_parent().transitionTo("Suspicious"))
	timeSinceStart.wait_time = 10.0
	add_child(timeSinceStart)

func onPhysicProcess(delta: float):

	# Update the navigation agent target position
	nav.target_position = target
	
	# Get the current direction
	var direction: Vector3 = nav.get_next_path_position() - parent.global_position
	direction.y = 0.0
	direction = direction.normalized()
	
	var new_transform = parent.transform.looking_at(parent.global_position + direction, Vector3.UP)
	parent.transform  = parent.transform.interpolate_with(new_transform, rotationSpeed * delta)

	parent.velocity = parent.velocity.lerp(direction * speed, accel * delta)
	parent.move_and_slide()
	
	# Verify if we reached our target
	if parent.global_position.distance_to(target) <= minTargetDist:
		get_parent().get_node("Suspicious").updateTarget(Vector3(target.x, parent.global_position.y, target.z))
		get_parent().transitionTo("Suspicious")
	
func updateTarget(targetParam: Vector3):
	target = targetParam
	if not timeSinceStart.is_stopped():
		timeSinceStart.start()

func enter():
	timeSinceStart.start()
	
func exit():
	timeSinceStart.stop()
