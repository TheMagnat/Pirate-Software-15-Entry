
extends Node3D

@export var offset: bool = true
@export var inverseY: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speedOffset1: float = randf_range(-0.2, 0.2)
	var speedOffset2: float = randf_range(-0.2, 0.2)
	
	if offset:
		var randomStartOffset: float = randf_range(0.0, 6.0)
		await get_tree().create_timer(randomStartOffset).timeout
	
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_speed_scale(1.0 + speedOffset1)
	
	var direction: float = -1.0 if inverseY else 1.0
	tween.tween_property(self, "position:y", 0.5 * direction, 2.5).as_relative()
	tween.tween_property(self, "position:y", -0.5 * direction, 2.5).as_relative()
	
	
	var rotaTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	rotaTween.set_speed_scale(1.0 + speedOffset2)
	rotaTween.tween_property(self, "rotation:y", PI/8, 4.0).as_relative()
	rotaTween.tween_property(self, "rotation:y", -PI/8, 4.0).as_relative()
