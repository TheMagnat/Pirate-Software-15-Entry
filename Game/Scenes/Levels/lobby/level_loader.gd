extends Area3D

@export var index := 0

func level_opened() -> bool:
	return Save.levels[index][0]

# Called when the node enters the scene tree for the first time.
func _ready():
	if index < 0 or index >= Save.levels.size():
		print("Invalid level index")
		queue_free()
		return
	
	body_entered.connect(load_level)

func load_level(body):
	if body.is_in_group("Player"):
		if level_opened():
			body_entered.disconnect(load_level)
			get_node("/root/Main").load_level(index)
		else:
			print("You cannot access this level yet")
