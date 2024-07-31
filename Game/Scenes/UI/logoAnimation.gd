extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", 0.1, 4.0)
	tween.tween_property(self, "rotation", -0.1, 4.0)
	
	var posTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	posTween.tween_property(self, "position:y", 5, 1.0).as_relative()
	posTween.tween_property(self, "position:y", -5, 1.0).as_relative()
