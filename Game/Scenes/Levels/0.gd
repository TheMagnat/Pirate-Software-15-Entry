extends Level

## for now it's empty
func _ready():
	Music.play(Music.fairies)
	$Player.changeGroundSound(0)
	$Player.killed.connect(restart_level.bind(true))
	$finish.body_entered.connect(finish_level)
	$Player.pickup_item.connect(add_to_inventory)
