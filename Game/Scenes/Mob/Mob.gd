@tool
class_name Mob extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var view: Area3D
@export var suspiciousDecreaseSpeed: float = 0.25 # Per seconds
var suspicious: float = 0.0
@export var limitSuspiciousLevel: float = 10.0

@export_category("StateMachine")
@export_subgroup("States transition")
@export_enum("Idle", "Turret", "WalkTo") var firstState: String = "Idle"
@export_enum("Patrol", "Turret") var idleTransitionState: String = "Patrol"
@export_enum("Patrol", "Turret", "WalkTo") var suspiciousTransitionState: String = "Patrol"
@export_enum("Turret", "Idle") var walkToTransitionState: String = "Turret"
@export_subgroup("idle configuration")
@export var idleDuration: float = 5.0
@export var keepOriginalDirection: bool = false

### Edit pattern section ###
@export_category("Edit pattern")
@export_subgroup("Patrol")
@export var checkpoints: PackedVector2Array
@export var addPosition: bool:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		checkpoints.push_back(Vector2(global_position.x, global_position.z))
@export var toPosition: int:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		if value < 0 or value >= checkpoints.size(): return
		global_position.x = checkpoints[value].x
		global_position.z = checkpoints[value].y
		toPosition = value
@export_subgroup("Turret")
@export var directions: PackedVector2Array
@export var walkToPosition: Vector2
@export var addDirection: bool:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		var currentDir := -global_transform.basis.z
		directions.push_back(Vector2(currentDir.x, currentDir.z))
		walkToPosition = Vector2(global_position.x, global_position.z)
@export var toDirection: int:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		print("Value: ", value)
		if value < 0 or value >= directions.size(): return
		var targetDirection := directions[value]
		var targetDirection3d := Vector3(targetDirection.x, 0.0, targetDirection.y)
		transform = transform.looking_at(global_position + targetDirection3d, Vector3.UP)
		toDirection = value
### End debug section ###

func _ready():
	if Engine.is_editor_hint(): return
	
	# Handle State Machine
	$StateMachine.transitionTo(firstState)
	$StateMachine/Idle.transitionState = idleTransitionState
	$StateMachine/Suspicious.transitionState = suspiciousTransitionState
	$StateMachine/WalkTo.transitionState = walkToTransitionState
	
	$StateMachine/Patrol.checkpoints = checkpoints
	$StateMachine/Turret.directions = directions
	$StateMachine/WalkTo.targetPosition = walkToPosition
	
	# Configure Idle
	$StateMachine/Idle.setTimeForTransition(idleDuration)
	$StateMachine/Idle.keepOriginalDirection = keepOriginalDirection
	# Configure View
	view.collision_mask = 0b111
	
	#$Voice.talk()

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
