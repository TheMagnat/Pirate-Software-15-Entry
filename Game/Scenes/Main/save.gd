extends Node

const RESOURCES := {
	"amethyst": 3,
	"diamond": 0,
	"jade": 98,
	"ruby": 99,
	"sapphire": 0,
	"topaz": 0,
	"artefact1": 0,
	"artefact2": 0,
	"artefact3": 0,
}

const UNLOCKABLES := [
	0, #cat walk
	0, #hardened mixture
	0, #potion of disturbance
	0, #ivy wall
	0 #shade cloak
]

const LEVELS := [ [true, 0.0], [true, 0.0], [false, 0.0], [false, 0.0] ]


const SAVE_FILE := "user://save.dat"
const CONFIG_FILE := "user://config.dat"

var resources := {}
var unlockable := []
var levels := []

const DEFAULT_CONFIG := {
	"fullscreen": false,
	"volume": 1.0
}

var config := {}

var enable_save := false

func _ready():
	load_game()

func _exit_tree():
	save_game(enable_save)

func get_var(file: FileAccess, default):
	if file == null:
		return default.duplicate()
	var v = file.get_var()
	if typeof(v) != typeof(default):
		return default.duplicate()
	return v

func _add_missing_dict(dict: Dictionary, basis: Dictionary):
	for key in basis.keys():
		if !(key in dict):
			dict[key] = basis[key]

func _add_missing_arr(arr: Array, basis: Array):
	if arr.size() < basis.size():
		for i in basis.size() - arr.size():
			arr.append(basis[arr.size() + i ])
	elif arr.size() > basis.size():
		for i in arr.size() - basis.size():
			arr.pop_back()

func _save_set_data(file: FileAccess):
	resources = get_var(file, RESOURCES.duplicate())
	unlockable = get_var(file, UNLOCKABLES.duplicate())
	levels = get_var(file, LEVELS.duplicate())
	
	_add_missing_dict(resources, RESOURCES)
	_add_missing_arr(unlockable, UNLOCKABLES)
	_add_missing_arr(levels, LEVELS)
	
	if typeof(LEVELS[0]) != typeof(levels[0]):
		levels = LEVELS.duplicate()
	
	# avoid reference to const value the dirty way
	for i in levels.size():
		levels[i] = levels[i].duplicate()

func save_erase():
	_save_set_data(null)

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func save_game(save_progress: bool):
	var file := FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	file.store_var(config)
	file.close()
	
	if save_progress:
		file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		file.store_var(resources)
		file.store_var(unlockable)
		file.store_var(levels)
		file.close()

func load_game():
	if FileAccess.file_exists(CONFIG_FILE):
		var file := FileAccess.open(CONFIG_FILE, FileAccess.READ)
		config = file.get_var()
		for key in DEFAULT_CONFIG.keys():
			if !(key in config):
				config[key] = DEFAULT_CONFIG[key]
		
		file.close()
	else:
		config = DEFAULT_CONFIG.duplicate()
	
	set_fullscreen(config.fullscreen)
	set_volume(config.volume)
	
	if !save_exists():
		save_erase()
	else:
		var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
		_save_set_data(file)
		file.close()

func set_fullscreen(f: bool):
	config.fullscreen = f
	get_window().mode = Window.MODE_FULLSCREEN if f else Window.MODE_WINDOWED

func set_volume(v: float):
	config.volume = v
	AudioServer.set_bus_mute(0, v <= 0.0)
	AudioServer.set_bus_volume_db(0, -(1.0 - v) * 30.0)
