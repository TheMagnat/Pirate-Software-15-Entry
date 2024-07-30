extends SpotLight3D

@export var tween_angle: float
@export var tween_duration:float
@export var trigger:Area3D

func _ready():
	trigger.body_entered.connect(_end_level)

func _end_level(body: Node3D):
	if body is Player:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "spot_angle", tween_angle, tween_duration)
