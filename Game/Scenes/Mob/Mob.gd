extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var suspiciousDecreaseSpeed: float = 0.25 # Per seconds
var suspicious: float = 0.0
@export var limitSuspiciousLevel: float = 10.0

func _ready():
	#$Voice.talk()
	pass

func _physics_process(delta):
	suspicious = max(0.0, suspicious - suspiciousDecreaseSpeed * delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func suspiciousActivity(position: Vector3, suspiciousLevel: float):
	suspicious += suspiciousLevel
		
	if suspicious > limitSuspiciousLevel:
		$StateMachine/Seeking.updateTarget(position)
		$StateMachine.transitionTo("Seeking")
	else:
		$StateMachine/Suspicious.updateTarget(position)
		$StateMachine.transitionTo("Suspicious")

func backstabbed():
	queue_free()

func _on_death_actionable_actioned():
	backstabbed()

func _on_state_machine_controller_spotted():
	$AudioStreamPlayer3D.play()
