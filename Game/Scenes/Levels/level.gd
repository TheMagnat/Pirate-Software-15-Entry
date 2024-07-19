extends Node3D


func finish_level():
	get_node("/root/World").load_lobby()
