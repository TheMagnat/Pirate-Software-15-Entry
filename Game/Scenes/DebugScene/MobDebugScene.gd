extends Node3D


func _ready():
	$Player/SpellHolder.setAllowedSpells([0, 1, 2])
