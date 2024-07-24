extends Button

func _ready():
	mouse_entered.connect($hover.play)
	pressed.connect($click.play)
