extends "res://Scenes/Levels/level.gd"

## for now it's empty
func _ready():
	Music.play(Music.mystery1)
	$Player.killed.connect(restart_level)
	$finish.body_entered.connect(finish_level)
