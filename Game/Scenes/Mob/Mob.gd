@tool
class_name Mob extends CharacterBody3D

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var view: Area3D
@export var suspiciousDecreaseSpeed: float = 0.25 # Per seconds
var suspicious: float = 0.0
@export var limitSuspiciousLevel: float = 10.0
@export var currentGroundStepSoundIndex: int = 0
@export var imperturbable: bool = false

### State machine param part ###
@export_category("StateMachine")

@export_subgroup("States transition")
@export_enum("Idle", "Turret", "WalkTo") var firstState: String = "Idle"
@export_enum("Patrol", "Turret") var idleTransitionState: String = "Patrol"
@export_enum("Patrol", "Turret", "WalkTo") var suspiciousTransitionState: String = "Patrol"
@export_enum("Turret", "Idle") var walkToTransitionState: String = "Turret"

@export_subgroup("Idle configuration")
@export var idleDuration: float = 5.0
@export var keepOriginalDirection: bool = false

@export_subgroup("Patrol configuration")
@export var patrolSpeed: float = 4.0
@export var startStargetPositionIndex: int = 0
@export var neverIdle: bool = false
@export var useDedicatedDirection: bool = false

@export_subgroup("Suspicious configuration")
@export var suspiciousDuration: float = 5.0
### End state machine param part ###

# Death handling
const RIGID_MOB = preload("res://Scenes/Mob/RigidMob.tscn")

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
@export var dedicatedDirection: PackedVector2Array
@export var addDedicatedDirection: bool:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		var currentDir := -global_transform.basis.z
		dedicatedDirection.push_back(Vector2(currentDir.x, currentDir.z))
		walkToPosition = Vector2(global_position.x, global_position.z)
@export var toDedicatedDirection: int:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		if value < 0 or value >= dedicatedDirection.size(): return
		var targetDirection := dedicatedDirection[value]
		var targetDirection3d := Vector3(targetDirection.x, 0.0, targetDirection.y)
		global_transform = global_transform.looking_at(global_position + targetDirection3d, Vector3.UP)
		toDedicatedDirection = value
@export_subgroup("Turret")
@export var directions: PackedVector2Array
@export var walkToPosition: Vector2
@export var tpToPosition: bool:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		global_position = Vector3(walkToPosition.x, global_position.y, walkToPosition.y) 
@export var addDirection: bool:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		var currentDir := -global_transform.basis.z
		directions.push_back(Vector2(currentDir.x, currentDir.z))
		walkToPosition = Vector2(global_position.x, global_position.z)
@export var toDirection: int:
	set(value):
		if not Engine.is_editor_hint() or not is_inside_tree(): return
		if value < 0 or value >= directions.size(): return
		var targetDirection := directions[value]
		var targetDirection3d := Vector3(targetDirection.x, 0.0, targetDirection.y)
		global_transform = global_transform.looking_at(global_position + targetDirection3d, Vector3.UP)
		toDirection = value
### End debug section ###

func _get_configuration_warnings():
	if view:
		if view.get_parent() != self:
			return ["The current view of the Mob is not one of his child. Becareful in case it get deleted before the mob."]

@onready var waterShaderHandler = $WaterShaderHandler
func _ready():
	if Engine.is_editor_hint(): return
	
	# Handle State Machine
	$StateMachine.setInitialNode(firstState)
	$StateMachine/Idle.transitionState = idleTransitionState
	$StateMachine/Suspicious.transitionState = suspiciousTransitionState
	$StateMachine/WalkTo.transitionState = walkToTransitionState
	
	$StateMachine/Patrol.checkpoints = checkpoints
	$StateMachine/Turret.directions = directions
	$StateMachine/WalkTo.targetPosition = walkToPosition
	
	# Configure Idle
	$StateMachine/Idle.setTimeForTransition(idleDuration)
	$StateMachine/Idle.keepOriginalDirection = keepOriginalDirection
	
	# Configure Patrol
	$StateMachine/Patrol.speed = patrolSpeed
	$StateMachine/Patrol.currentTarget = startStargetPositionIndex
	$StateMachine/Patrol.neverIdle = neverIdle
	$StateMachine/Patrol.useDedicatedDirection = useDedicatedDirection
	if useDedicatedDirection: $StateMachine/Patrol.dedicatedDirection = dedicatedDirection
	
	# Configure Suspicious
	$StateMachine/Suspicious.timeForTransition = suspiciousDuration
	
	# Initialize state machine when every state are setuped
	$StateMachine.initialize()
	
	# Configure View
	if view: view.collision_mask = 0b010
	
	#$Voice.talk()
	
	waterShaderHandler.shaderMaterial = $MobModel/RootNode/Fiole/Liquid.material_override

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	handleAnimation()
	
	# Funnier to never decrease the suspicious level
	#suspicious = max(0.0, suspicious - suspiciousDecreaseSpeed * delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func suspiciousActivity(pos: Vector3, suspiciousLevel: float):
	if imperturbable: return
	
	suspicious += suspiciousLevel
	
	if $StateMachine.getCurrentStateName() == "Chase":
		$StateMachine/Chase.lastTargetPosition = pos
	else:
		if suspicious > limitSuspiciousLevel:
			$StateMachine/Seeking.updateTarget(pos)
			$StateMachine.transitionTo("Seeking")
		else:
			$StateMachine/Suspicious.updateTarget(pos)
			$StateMachine.transitionTo("Suspicious")

@onready var animation: AnimationTree = $MobModel/AnimationTree
var animationBlendTime: float = 0.25
var animationTween: Tween
func handleAnimation():
	if animationTween:
			animationTween.kill()
	if not velocity.length() < 0.5:
		animationTween = create_tween()
		animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 1.0, animationBlendTime)
	else:
		animationTween = create_tween()
		animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 0.0, animationBlendTime)

@onready var currentGroundStepSound: AudioStreamPlayer3D = getGroundSound()

var leftPlay: bool = false
var rightPlay: bool = false
func getGroundSound():
	if currentGroundStepSoundIndex == 0:
		return $GrassStepPlayer
	elif currentGroundStepSoundIndex == 1:
		return $ConcreteStepPlayer
	else:
		return $MetalStepPlayer

func changeGroundSound(value):
	if value == 0:
		currentGroundStepSound = $GrassStepPlayer
	elif value == 1:
		currentGroundStepSound = $ConcreteStepPlayer
	else:
		currentGroundStepSound = $MetalStepPlayer

func _process(_delta):
	if Engine.is_editor_hint(): return
	
	# To prevent using nil value in Walking/time
	var safeAnimationTime = animation["parameters/Walking/current_position"]
	var animationTime: float = safeAnimationTime if safeAnimationTime else 0.0
	
	#Play walking sound every time the time hit 0.25 and 0.75
	if animation["parameters/Blend2/blend_amount"] > 0.4:
		# Left foot
		if animationTime > 0.15 and animationTime < 0.4:
			if not leftPlay:
				currentGroundStepSound.play()
				leftPlay = true
		else:
			leftPlay = false
		
		# Right foot
		if animationTime > 0.65 and animationTime < 0.9:
			if not rightPlay:
				currentGroundStepSound.play()
				rightPlay = true
		else:
			rightPlay = false
	
	# To prevent moving liquid if the animation is too slow
	if animation["parameters/Blend2/blend_amount"] > 0.4:
		if animationTime > 0.2 and animationTime < 0.3:
			waterShaderHandler.xIsTilted(1.0)
		elif animationTime > 0.7 and animationTime < 0.8:
			waterShaderHandler.xIsTilted(-1.0)

func backstabbed(backstabber: Player):
	backstabber.slash()
	var rigidMobInstance = RIGID_MOB.instantiate()
	rigidMobInstance.global_transform = global_transform
	rigidMobInstance.apply_central_impulse(backstabber.global_position.direction_to(global_position) * 5.0)
	add_sibling(rigidMobInstance)
	queue_free()

var eyeLevel := Vector3(0.0, 1.0, 0.0) 
func checkBodyCanBeSeen(body: CharacterBody3D):
	var space_state = get_world_3d().direct_space_state
	
	var query =  PhysicsRayQueryParameters3D.create(global_position + eyeLevel, body.global_position + eyeLevel, 0b11011)
	query.hit_from_inside = false
	var result = space_state.intersect_ray(query)
	
	if not result:
		#DebugDraw.draw_line(global_position + eyeLevel, body.global_position + eyeLevel, 10.0, Color.GREEN)
		return true
	#else:
		#if result.collider == body:
			#DebugDraw.draw_line(global_position + eyeLevel, body.global_position + eyeLevel, 10.0, Color.GREEN)
		#else:
			#DebugDraw.draw_line(global_position + eyeLevel, body.global_position + eyeLevel, 10.0)
	
	return result.collider == body

func _on_death_actionable_actioned(backstabber: Player):
	backstabbed(backstabber)

func _on_state_machine_controller_spotted():
	$SpottedSoung.play()
