extends StateNode

@export var parent: CharacterBody3D
@export var parentVoice: Voice

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

func onPhysicProcess(delta: float):
	
	# Update timers
	timeSinceLastReset += delta
	
	if timeSinceLastReset > timeForDirectionReset:
		timeSinceLastReset = 0.0
		var angle = Vector2(currentDirection.x, currentDirection.z).angle()
		angle += randf_range(-maxDirectionAngleChange, maxDirectionAngleChange)
		var new2dDirection = Vector2.from_angle(angle)
		
		currentDirection = Vector3(new2dDirection.x, 0.0, new2dDirection.y)
	
	if currentDirection != Vector3.ZERO:	
		var new_transform = parent.global_transform.looking_at(parent.global_position + currentDirection, Vector3.UP)
		parent.global_transform  = parent.global_transform.interpolate_with(new_transform, rotationSpeed * delta)
	
	parent.velocity = parent.velocity.lerp(Vector3.ZERO, decelerationSpeed * delta)
	parent.move_and_slide()

func enter():
	if parentVoice: parentVoice.word()
	timeSinceLastReset = 0.0
	timeForDirectionReset = randf_range(timeRangeForDirectionReset.x, timeRangeForDirectionReset.y)
	timeSinceStart.start()
	
func exit():
	timeSinceStart.stop()
	
func updateTarget(target):
	target.y -= 1.0 # To compensate the position on the feet of the mobs
	currentDirection = target - parent.global_position
	currentDirection.y = clamp(currentDirection.y, -0.5, 0.5)
	timeSinceLastReset = 0.0
	timeForDirectionReset = randf_range(timeRangeForDirectionReset.x, timeRangeForDirectionReset.y)
	if not timeSinceStart.is_stopped():
		timeSinceStart.start()
