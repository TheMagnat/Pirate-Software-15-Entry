extends Node3D

@export var index: int = 0

func level_opened() -> bool:
	return Save.levels[index][0]

func _ready() -> void:
	if not level_opened():
		get_child(0).hide()
