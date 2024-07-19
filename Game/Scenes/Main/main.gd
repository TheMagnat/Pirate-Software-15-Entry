extends Node

const lobby := preload("res://Scenes/Levels/lobby.tscn")

func _ready():
	Save.enable_save = true
	load_lobby()

func load_lobby():
	$Level.add_child(lobby.instantiate())

func load_level(path: String):
	pass
