class_name Spell extends Node3D

@onready var player: Player = get_parent().get_parent()
@export var action: String = "main_action"
@export var model: PackedScene
@export var cooldown := 5.0
@export var cooldown_decrease_per_level := 1.0
var aiming := false

var on_cooldown := false
func tryActivateSpell():
	aiming = false
	if !on_cooldown:
		on_cooldown = true
		var t := get_tree().create_timer(cooldown - cooldown_decrease_per_level * Save.unlockable[Player.CastingSpeed])
		t.timeout.connect(func(): on_cooldown = false)
		activateSpell()

func activateSpell():
	print("activateSpell not implemented")
