extends "res://Scenes/Levels/level.gd"

func _ready():
	$finish.body_entered.connect(finish_level)
