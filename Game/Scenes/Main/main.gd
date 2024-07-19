extends Node

const lobby_level := "res://Scenes/Levels/lobby.tscn"

func _ready():
	Save.enable_save = true
	load_lobby()

func load_lobby():
	load_level(lobby_level)
	$Menu.show_menu(false)

func _load_level(path: String):
	if !FileAccess.file_exists(path):
		print("File '" + path + "' not found")
		return
	
	for child in $Level.get_children():
		child.queue_free()
	
	$Menu/Control/VBoxContainer/Lobby.visible = path != lobby_level
	$Level.add_child(load(path).instantiate())

func load_level(path: String):
	if $Level.get_child_count() == 0:
		_load_level(path)
	else:
		Transition.start(_load_level.bind(path))
