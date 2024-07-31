
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var randomStartOffset: float = randf_range(0.0, 6.0)
	var speedOffset1: float = randf_range(-0.2, 0.2)
	var speedOffset2: float = randf_range(-0.2, 0.2)

	await get_tree().create_timer(randomStartOffset).timeout
	
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_speed_scale(1.0 + speedOffset1)
	tween.tween_property(self, "position:y", 0.5, 2.5).as_relative()
	tween.tween_property(self, "position:y", -0.5, 2.5).as_relative()
	
	
	var rotaTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	rotaTween.set_speed_scale(1.0 + speedOffset2)
	rotaTween.tween_property(self, "rotation:y", PI/8, 4.0).as_relative()
	rotaTween.tween_property(self, "rotation:y", -PI/8, 4.0).as_relative()
