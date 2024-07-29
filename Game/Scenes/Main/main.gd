extends Node

### DEBUG ###
var inDebug: bool = false
var debugIndex: int = 2
### END DEBUG ###

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader

var current_level_idx: int = -2
var currentLevel = null

func _ready():
	#get_viewport().debug_draw = 9
	Save.enable_save = true
	load_lobby()

func load_lobby():
	# DEBUG
	if inDebug:
		load_level(debugIndex)
	else:
		load_level(-1)
	
	$Menu.show_menu(false)

var shadowAtlasIndex: int = 1
func _load_level(idx : int):
	if not resource_preloader.has_resource(str(idx)):
		print("Ressource '", idx, "' not found")
		return
	
	for child in $Level.get_children():
		child.queue_free()
	
	# Don't ask question, this fix some shadow atlas bugs...
	get_viewport().set_positional_shadow_atlas_quadrant_subdiv((shadowAtlasIndex)%4, Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4)
	get_viewport().set_positional_shadow_atlas_quadrant_subdiv((shadowAtlasIndex+1)%4, Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_16)
	get_viewport().set_positional_shadow_atlas_quadrant_subdiv((shadowAtlasIndex+2)%4, Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4)
	get_viewport().set_positional_shadow_atlas_quadrant_subdiv((shadowAtlasIndex+3)%4, Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_16)
	shadowAtlasIndex += 1
	
	current_level_idx = idx
	$Menu/Control/HBoxContainer/Main/Lobby.visible = idx != -1
	
	currentLevel = resource_preloader.get_resource(str(idx)).instantiate()
	if idx != -1:
		currentLevel.init(idx)
	$Level.add_child(currentLevel)

func load_level(idx := -1):
	if $Level.get_child_count() == 0:
		_load_level(idx)
	else:
		Transition.start(_load_level.bind(idx))

func escape_level(idx: int, open_levels: Array, time_spent: float, resources: Dictionary):
	### Add retrieved resources
	print("Resources gathered:")
	for resource in resources.keys():
		print("- ", resource, ": ", resources[resource])
		if Save.resources.has(resource):
			Save.resources[resource] += resources[resource]
		else:
			Save.resources[resource] = resources[resource]
	
	var endScreen := preload("res://Scenes/Levels/LevelEndScreen.tscn").instantiate()
	endScreen.fillScreen(currentLevel, true)
	endScreen.addCallback(func(): load_lobby())
	add_child(endScreen)
	
func finish_level(idx: int, open_levels: Array, time_spent: float, resources: Dictionary, artifact: String):
		
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
		print("- ", resource, ": ", resources[resource])
		if Save.resources.has(resource):
			Save.resources[resource] += resources[resource]
		else:
			Save.resources[resource] = resources[resource]
	Save.resources[artifact] += 1
	print("Added artifact:", artifact)
	
	var endScreen := preload("res://Scenes/Levels/LevelEndScreen.tscn").instantiate()
	endScreen.fillScreen(currentLevel)
	endScreen.addCallback(func(): load_lobby())
	add_child(endScreen)
