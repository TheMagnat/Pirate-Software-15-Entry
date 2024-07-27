class_name Level extends Node3D

@export var open_levels : Array[int] = []

# Level information
@export var level_name: String

@export var main_ressource: String

@export var contained_resources := {}
var finish_resources := {}

@export var nbEnemies: int = 0
var killedEnemies: int = 0

var isFinished: bool = false


var idx := -1

const WAIT_TIME := 10.0
var timer := Timer.new()
var time_spent := 0.0

func initFinishRessources():
	for ressource in contained_resources:
		finish_resources[ressource] = 0

func init(i: int):
	idx = i
	
	initFinishRessources()
	
	if Save.levels[idx][1] <= 0.0:
		print("No record set on this level")
	else:
		print("Record time on this level: " + str(Save.levels[idx][1]))
	
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 10.0
	timer.timeout.connect(func(): time_spent += WAIT_TIME)
	add_child(timer)
 
func restart_level():
	var main = get_node("/root/Main")
	main.load_level(main.current_level_idx)

func escape_level(body = null):
	if not isFinished and (body.is_in_group("Player") and not body.canBeSeen()) or body == null:
		body.safePlace = true
		isFinished = true
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").escape_level(idx, open_levels, time_spent, finish_resources)

func finish_level(body = null):
	if not isFinished and (body.is_in_group("Player") and not body.canBeSeen()) or body == null:
		body.safePlace = true
		isFinished = true
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").finish_level(idx, open_levels, time_spent, finish_resources)
