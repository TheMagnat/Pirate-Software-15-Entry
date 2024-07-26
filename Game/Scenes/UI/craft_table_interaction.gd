extends Node3D

signal enter_craft(s: bool)
var _is_crafting = false

func _ready():
	$Area3D.body_entered.connect(craft_table_enter)
	$Area3D.body_exited.connect(craft_table_exit)

func crafting(s: bool):
	enter_craft.emit(s)
	_is_crafting = s
	$CraftTable.enabled = s

func craft_table_enter(body):
	if body.is_in_group("Player"):
		crafting(true)

func craft_table_exit(body):
	if body.is_in_group("Player"):
		crafting(false)
