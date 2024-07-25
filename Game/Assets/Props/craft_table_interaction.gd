extends Node3D

var _is_crafting = false

func trigger_action(_player: Player):
	if(_is_crafting):
		craft_table_exit()
		$"./CraftTable".enabled = false
	else:
		craft_table_enter()
		$"./CraftTable".enabled = true
	_is_crafting = !_is_crafting

func craft_table_enter():
	$"./Camera3D".make_current()

func craft_table_exit():
	$"../CameraInside".make_current()
