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

const LEVELS := [ [true, 0.0], [false, 0.0], [false, 0.0] ]


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

func save_erase():
	resources = RESOURCES.duplicate()
	unlockable = UNLOCKABLES.duplicate()
	levels = LEVELS.duplicate()

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func save_game():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(resources)
	file.store_var(unlockable)
	file.store_var(levels)
	file.close()


func get_var(file: FileAccess, default):
	var v = file.get_var()
	if typeof(v) != typeof(default):
		return default.duplicate()
	return v

func load_game():
	if !save_exists():
		save_erase()
	else:
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		resources = get_var(file, RESOURCES)
		unlockable = get_var(file, UNLOCKABLES)
		levels = get_var(file, LEVELS)
		if typeof(LEVELS[0]) != typeof(levels[0]):
			levels = LEVELS.duplicate()
		
		# avoid reference to const value the dirty way
		for i in levels.size():
			levels[i] = levels[i].duplicate()
		file.close()
