extends "res://Scenes/Levels/level.gd"

## for now it's empty
func _ready():
	Music.play(Music.action1)
	$Player.changeGroundSound(1)
	$Player.killed.connect(restart_level)
	$Player.pickup_item.connect(add_to_inventory)
	$finish.body_entered.connect(finish_level)
	$escape.body_entered.connect(escape_level)
