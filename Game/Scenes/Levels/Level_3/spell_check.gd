extends Node3D

@export var player: Player
var requestedSpell: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if requestedSpell in player.get_node("SpellHolder").allowedSpells:
		hide()
