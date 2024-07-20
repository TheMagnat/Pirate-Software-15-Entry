extends Node

const lobby_level := "res://Scenes/Levels/lobby.tscn"

var current_level := ""

func _ready():
	Save.enable_save = true
	load_lobby()

func load_lobby():
	load_level(lobby_level)
	$Menu.show_menu(false)

func _load_level(path: String, idx : int):
	if !FileAccess.file_exists(path):
		print("File '" + path + "' not found")
		return
	
	for child in $Level.get_children():
		child.queue_free()
	
	current_level = path
	
	$Menu/Control/VBoxContainer/Lobby.visible = path != lobby_level
	
	var level = load(path).instantiate()
	if idx != -1 and path != lobby_level:
		level.init(idx)
	$Level.add_child(level)
	

func load_level(path: String, idx := -1):
	if $Level.get_child_count() == 0:
		_load_level(path, idx)
	else:
		Transition.start(_load_level.bind(path, idx))

func finish_level(idx: int, open_levels: Array, time_spent: float, resources: Dictionary):
	### Open the access to this level
	for idx2 in open_levels:
		print("Opened access to level " + str(idx2))
		Save.levels[idx2][0] = true
	
	### Record time on this level
	print("Level finished in " + str(time_spent) + " seconds")
	if Save.levels[idx][1] <= 0.0 or time_spent < Save.levels[idx][1]:
		print("New record!!")
		Save.levels[idx][1] = time_spent
	
	### Add retrieved resources
	print("Resources gathered:")
	for resource in resources.keys():
		print("- " + resource + ": " + str(resources[resource]))
		Save.resources[resource] += resources[resource]
	
	load_lobby()
