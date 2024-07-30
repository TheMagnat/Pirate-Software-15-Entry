extends StaticBody3D

@export var tween_duration:float
@export var trigger:Area3D

func _ready():
	trigger.body_entered.connect(_close)

func _close(body: Node3D):
	if body is Player:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:y", 0, tween_duration)
