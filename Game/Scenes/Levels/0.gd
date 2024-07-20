extends "res://Scenes/Levels/level.gd"

## for now it's empty
func _ready():
	$Player.killed.connect(restart_level)
