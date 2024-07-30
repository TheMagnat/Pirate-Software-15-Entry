extends Area3D

@export var sound_index := 0

func _ready():
	body_entered.connect(_set_sound)

func _set_sound(body: Node3D):
	if body is Player or body is Mob:
		body.changeGroundSound(sound_index)
