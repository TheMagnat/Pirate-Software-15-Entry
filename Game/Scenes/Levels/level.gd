extends Node3D

@export var open_levels : Array[int] = []
@export var finish_resources := {}
var idx := -1

const WAIT_TIME := 10.0
var timer := Timer.new()
var time_spent := 0.0

func init(i: int):
	idx = i
	
	if Save.levels[idx][1] <= 0.0:
		print("No record set on this level")
	else:
		print("Record time on this level: " + str(Save.levels[idx][1]))
	
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 10.0
	timer.timeout.connect(func(): time_spent += WAIT_TIME)
	add_child(timer)

func finish_level(body = null):
	if body.is_in_group("Player") or body == null:
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").finish_level(idx, open_levels, time_spent, finish_resources)
