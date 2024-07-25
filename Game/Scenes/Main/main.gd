extends Node

### DEBUG ###
var inDebug: bool = false
### END DEBUG ###

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader

var current_level_idx: int = -2
func _ready():
	Save.enable_save = true
	load_lobby()

func load_lobby():
	# DEBUG
	if inDebug:
		load_level(1)
	else:
		load_level(-1)
	
	$Menu.show_menu(false)

func _load_level(idx : int):
	if not resource_preloader.has_resource(str(idx)):
		print("Ressource '", idx, "' not found")
		return
	
	for child in $Level.get_children():
		child.queue_free()
	
	current_level_idx = idx
	$Menu/Control/VBoxContainer/Lobby.visible = idx != -1
	
	var level = resource_preloader.get_resource(str(idx)).instantiate()
	if idx != -1:
		level.init(idx)
	$Level.add_child(level)
	

func load_level(idx := -1):
	if $Level.get_child_count() == 0:
		_load_level(idx)
	else:
		Transition.start(_load_level.bind(idx))

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
