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

const LEVELS := {
	1: true,
	2: false,
	3: false,
}


const SAVE_FILE := "user://save.dat"

var resources := {}
var unlockable := {}
var levels := {}

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


func load_game():
	if !save_exists():
		save_erase()
	else:
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		resources = file.get_var()
		unlockable = file.get_var()
		levels = file.get_var()
		file.close()

