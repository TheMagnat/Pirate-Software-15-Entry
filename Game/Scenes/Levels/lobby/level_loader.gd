extends Area3D

const TUTORIAL_TEXT := preload("res://Scenes/UI/tutorial_text.tscn")

@export var index := 0

func level_opened() -> bool:
	return Save.levels[index][0]

# Called when the node enters the scene tree for the first time.
func _ready():
	if index < 0 or index >= Save.levels.size():
		print("Invalid level index")
		queue_free()
		return
	
	if level_opened():
		body_entered.connect(load_level)
	else:
		var msg := TUTORIAL_TEXT.instantiate()
		msg.useRenderDistance = true
		msg.player = get_node("/root/Main/Level/lobby/Player")
		msg.position.y = 2.0
		msg.position.z = 3.0
		msg.rotation.x += PI/2
		msg.font_size = 192
		msg.text = "You can't access\n this land\n for now"
		add_child(msg)

func load_level(body):
	if body.is_in_group("Player"):
		if level_opened():
			body_entered.disconnect(load_level)
			get_node("/root/Main").load_level(index)
		else:
			print("You cannot access this level yet")
