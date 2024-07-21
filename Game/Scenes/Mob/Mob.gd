extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var suspicionsDecreaseSpeed: float = 0.5 # Per seconds
var suspicions: float = 0.0

func _physics_process(delta):
	suspicions = max(0.0, suspicions - suspicionsDecreaseSpeed * delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func suspiciousActivity(position: Vector3, suspiciousLevel: float):
	suspicions += suspiciousLevel
	
	$StateMachine/Suspicious.updateTarget(position)
	$StateMachine.transitionTo("Suspicious")
