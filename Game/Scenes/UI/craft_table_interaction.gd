extends Node3D

signal enter_craft(s: bool)
var _is_crafting = false
var tweenAnimation: Tween
func _ready():
	tweenAnimation = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tweenAnimation.tween_property(self, "position:y", 0.2, 3.0).as_relative()
	tweenAnimation.tween_property(self, "position:y", -0.2, 3.0).as_relative()
	
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
