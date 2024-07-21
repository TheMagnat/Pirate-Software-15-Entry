extends StateNode

@export var parent: CharacterBody3D

@onready var currentDirection: Vector3
var timeSinceLastReset: float = 0.0
var timeRangeForDirectionReset: Vector2 = Vector2(0.75, 1.5)
var timeForDirectionReset: float = 0.5

var decelerationSpeed: float = 5.0

# Difficulty parameters
@export var rotationSpeed: float = 6.0
@export var maxDirectionAngleChange: float = 0.5

# Transition parameters
@onready var timeSinceStart: Timer = Timer.new()
@export var timeForTransition: float = 5.0
@export var transitionState: String = "Patrol"

func _ready():
	timeSinceStart.timeout.connect(func (): get_parent().transitionTo(transitionState))
	timeSinceStart.wait_time = timeForTransition
	add_child(timeSinceStart)

func onProcess(delta: float):
	pass

func onPhysicProcess(delta: float):
	
	# Update timers
	timeSinceLastReset += delta
	
	if timeSinceLastReset > timeForDirectionReset:
		timeSinceLastReset = 0.0
		var angle = Vector2(currentDirection.x, currentDirection.z).angle()
		angle += randf_range(-maxDirectionAngleChange, maxDirectionAngleChange)
		var new2dDirection = Vector2.from_angle(angle)
		
		currentDirection = Vector3(new2dDirection.x, 0.0, new2dDirection.y)
		#currentDirection = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
		
	var new_transform = parent.transform.looking_at(parent.global_position + currentDirection, Vector3.UP)
	parent.transform  = parent.transform.interpolate_with(new_transform, rotationSpeed * delta)
	
	parent.velocity = parent.velocity.lerp(Vector3.ZERO, decelerationSpeed * delta)
	parent.move_and_slide()

func enter():
	timeSinceLastReset = 0.0
	timeForDirectionReset = randf_range(timeRangeForDirectionReset.x, timeRangeForDirectionReset.y)
	timeSinceStart.start()
	
func exit():
	pass
	
func updateTarget(target):
	currentDirection = target - parent.global_position
	timeSinceLastReset = 0.0
	timeForDirectionReset = randf_range(timeRangeForDirectionReset.x, timeRangeForDirectionReset.y)
	if not timeSinceStart.is_stopped():
		timeSinceStart.start()