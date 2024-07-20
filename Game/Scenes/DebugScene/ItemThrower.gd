extends Node3D

@export var item: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func getThrowDirection(depth: float):
	var direction: Vector2 = get_viewport().get_mouse_position() / Vector2(get_viewport().get_visible_rect().size)
	direction.y = 1.0 - direction.y
	direction = (direction - Vector2(0.5, 0.5)) * 2.0
	
	return Vector3(direction.x, direction.y, depth).normalized()

func throwItem():
	var newItem: RigidBody3D = item.instantiate()
	
	var direction = getThrowDirection(-1.0)
	
	var target = to_global(direction)
	var globalDirection = (target - global_position).normalized()
	
	get_parent().get_parent().add_child(newItem)
	newItem.global_position = global_position + globalDirection * 3.0
	newItem.apply_central_impulse(globalDirection * 10.0)

func _input(event):
	if event.is_action_pressed("main_action"):
		throwItem()
