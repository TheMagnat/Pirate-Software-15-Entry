extends Node

const END_SCREEN := preload("res://Scenes/Levels/LevelEndScreen.tscn")

### DEBUG ###
var inDebug: bool = false
var debugIndex: int = 2
### END DEBUG ###

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader

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
func _load_level(idx : int, spawnInformation: SpawnInformation = null):
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
	
	$Menu/Control/HBoxContainer/Main/Lobby.visible = idx != -1
	
	currentLevel = resource_preloader.get_resource(str(idx)).instantiate()
	if idx != -1:
		currentLevel.init(idx)
	$Level.add_child(currentLevel)
	
	# To allow the usage of checkpoints
	if spawnInformation:
		currentLevel.get_node("Player").global_position = spawnInformation.position
		currentLevel.get_node("Player").setSpawnOrientation(spawnInformation.cameraAngle)

func load_level(idx := -1, spawnInformation: SpawnInformation = null):
	if $Level.get_child_count() == 0:
		_load_level(idx, spawnInformation)
	else:
		Transition.start(_load_level.bind(idx, spawnInformation))

func escape_level():
	var resources = currentLevel.finish_resources
	### Add retrieved resources
	print("Resources gathered:")
	for resource in resources.keys():
		print("- ", resource, ": ", resources[resource])
		if Save.resources.has(resource):
			Save.resources[resource] += resources[resource]
		else:
			Save.resources[resource] = resources[resource]
	
	var endScreen := END_SCREEN.instantiate()
	endScreen.fillScreen(currentLevel, true)
	endScreen.addCallback(func(): load_lobby())
	add_child(endScreen)
	
func finish_level():
	var new_record := false
	
	### Open the access to this level
	for idx2 in currentLevel.open_levels:
		print("Opened access to level " + str(idx2))
		Save.levels[idx2][0] = true
	
	### Record time on this level
	var idx = currentLevel.idx
	var time_spent = currentLevel.time_spent
	print("Level finished in " + str(time_spent) + " seconds")
	if Save.levels[idx][1] <= 0.0 or time_spent < Save.levels[idx][1]:
		print("New record!!")
		Save.levels[idx][1] = time_spent
		new_record = true
	
	### Add retrieved resources
	var resources = currentLevel.finish_resources
	var artifact = currentLevel.main_ressource
	print("Resources gathered:")
	for resource in resources.keys():
		print("- ", resource, ": ", resources[resource])
		if Save.resources.has(resource):
			Save.resources[resource] += resources[resource]
		else:
			Save.resources[resource] = resources[resource]
	Save.resources[artifact] += 1
	print("Added artifact:", artifact)
	
	var endScreen := END_SCREEN.instantiate()
	endScreen.fillScreen(currentLevel)
	endScreen.new_record = new_record
	endScreen.addCallback(func(): load_lobby())
	add_child(endScreen)
