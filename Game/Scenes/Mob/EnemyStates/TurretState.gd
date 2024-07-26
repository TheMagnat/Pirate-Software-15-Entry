@tool

extends StateNode


@export var directions: PackedVector2Array
var currentDirrection: int = 0

var cumulatedTimeSinceLastChange: float = 0.0
var changeDirectionTime: float = 5
var rotationSpeed: float = 2

var decelerationSpeed: float = 5.0

@export var parent: CharacterBody3D

var speed = 4
var accel = 5
var minTargetDist: float = 1

func onPhysicProcess(delta: float):
	cumulatedTimeSinceLastChange += delta
	
	# get current target position
	var targetDirection := directions[currentDirrection]
	var targetDirection3d := Vector3(targetDirection.x, 0.0, targetDirection.y)
	
	var new_transform = parent.transform.looking_at(parent.global_position + targetDirection3d, Vector3.UP)
	parent.transform  = parent.transform.interpolate_with(new_transform, rotationSpeed * delta)

	# We're static, so slow the parent if he's moving
	parent.velocity = parent.velocity.lerp(Vector3.ZERO, decelerationSpeed * delta)
	parent.move_and_slide()
	
	# Verify if we reached our target
	if targetDirection3d.distance_to(-parent.global_transform.basis.z) <= 0.1 and cumulatedTimeSinceLastChange >= changeDirectionTime:
		cumulatedTimeSinceLastChange = 0.0
		currentDirrection = (currentDirrection+1) % directions.size()
		#get_parent().transitionTo("Idle")
	
func enter():
	cumulatedTimeSinceLastChange = 0.0
	
func exit():
	pass
