extends Node

const RESOURCES := {
	"water": 0,
	"stone": 0,
	"lead": 0,
}

const UNLOCKABLES := {
	"TELEKINEZIS": 0,
	"DASH": 0,
	"SMOKE": 0,
}

const LEVELS := [ [true, 0.0], [true, 0.0], [false, 0.0] ]


const SAVE_FILE := "user://save.dat"

var resources := {}
var unlockable := {}
var levels := []

var enable_save := false

func _ready():
	load_game()

func _exit_tree():
	if enable_save:
		save_game()

func get_var(file: FileAccess, default):
	if file == null:
		return default.duplicate()
	var v = file.get_var()
	if typeof(v) != typeof(default):
		return default.duplicate()
	return v

func _save_set_data(file: FileAccess):
	resources = get_var(file, RESOURCES.duplicate())
	unlockable = get_var(file, UNLOCKABLES.duplicate())
	levels = get_var(file, LEVELS.duplicate())
	if typeof(LEVELS[0]) != typeof(levels[0]):
		levels = LEVELS.duplicate()
	
	# avoid reference to const value the dirty way
	for i in levels.size():
		levels[i] = levels[i].duplicate()

func save_erase():
	_save_set_data(null)

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func save_game():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(resources)
	file.store_var(unlockable)
	file.store_var(levels)
	file.close()

func load_game():
	if !save_exists():
		save_erase()
	else:
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		_save_set_data(file)
		file.close()
