extends "res://Scenes/Levels/level.gd"

## for now it's empty
func _ready():
	Music.play(Music.fairies)
	$Player.killed.connect(restart_level)
	$finish.body_entered.connect(finish_level)
