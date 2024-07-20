extends Node3D

@export var path := ""

func restart_level():
	var main = get_node("/root/Main")
	main.load_level(main.current_level)

func finish_level():
	get_node("/root/World").load_lobby()
