extends Area3D

@export var level:Level

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Player:
		if body.killed.is_connected(level.restart_level):
			body.killed.disconnect(level.restart_level)
			body.killed.connect(level.finish_level_by_death.bind(body))
