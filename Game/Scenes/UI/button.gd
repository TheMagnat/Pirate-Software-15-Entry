extends Button

func _ready():
	mouse_entered.connect(_play)
	pressed.connect($click.play)

func _play():
	if visible:
		$hover.play()
