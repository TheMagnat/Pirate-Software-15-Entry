extends TextureProgressBar

signal skip

var factor := -4.0

func _process(delta: float):
	var v := delta * 50.0 * factor
	value = clampf(value + v, min_value, max_value)
	$Label.modulate.a = sqrt(value * 0.01)
	
	if value >= max_value:
		skip.emit()
		factor = -4.0

func _input(event):
	if event.is_action_pressed("ui_accept"):
		factor = 1.0
	elif event.is_action_released("ui_accept"):
		factor = -4.0
