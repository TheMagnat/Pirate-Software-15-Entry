extends StateNode

@export var parent: CharacterBody3D

var keepOriginalDirection: bool = false
var originalDirection: Vector2
var currentDirection: Vector3
var timeSinceLastReset: float = 0.0
var timeRangeForDirectionReset: Vector2 = Vector2(1.0, 3.0)
var timeForDirectionReset: float = 1.0

var decelerationSpeed: float = 5.0

# Difficulty parameters
@export var rotationSpeed: float = 3.0
@export var maxDirectionAngleChange: float = 0.5

# Transition parameters
@onready var timeSinceStart: Timer = Timer.new()
@export var timeForTransition: float = 5.0
@export var transitionState: String = "Patrol"

func _ready():
	var direction3d: Vector3 = -parent.global_transform.basis.z
	originalDirection = Vector2(direction3d.x, direction3d.z)
	timeSinceStart.timeout.connect(func (): get_parent().transitionTo(transitionState))
	timeSinceStart.wait_time = timeForTransition
	add_child(timeSinceStart)

func onPhysicProcess(delta: float):
	# Update timers
	timeSinceLastReset += delta
	
	if timeSinceLastReset > timeForDirectionReset:
		timeSinceLastReset = 0.0
		var angle: float
		if keepOriginalDirection:
			angle = originalDirection.angle()
		else:
			angle = Vector2(currentDirection.x, currentDirection.z).angle()
		angle += randf_range(-maxDirectionAngleChange, maxDirectionAngleChange)
		var new2dDirection = Vector2.from_angle(angle)
		
		currentDirection = Vector3(new2dDirection.x, 0.0, new2dDirection.y)

	var new_transform = parent.global_transform.looking_at(parent.global_position + currentDirection, Vector3.UP)
	parent.global_transform  = parent.global_transform.interpolate_with(new_transform, rotationSpeed * delta)
	
	# We're static, so slow the parent if he's moving
	parent.velocity = parent.velocity.lerp(Vector3.ZERO, decelerationSpeed * delta)
	parent.move_and_slide()

func enter():
	currentDirection = -parent.global_transform.basis.z if not keepOriginalDirection else Vector3(originalDirection.x, 0.0, originalDirection.y)
	timeSinceLastReset = 0.0
	timeForDirectionReset = randf_range(timeRangeForDirectionReset.x, timeRangeForDirectionReset.y)
	
	if timeForTransition > 0.0:
		timeSinceStart.start()

func setTimeForTransition(newTime):
	timeForTransition = newTime
	if timeForTransition > 0.0:
		timeSinceStart.wait_time = timeForTransition
		if not timeSinceStart.is_stopped():
			timeSinceStart.start()
	else:
		timeSinceStart.stop()

func exit():
	timeSinceStart.stop()
