extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/SpellHolder.setAllowedSpells([0, 1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
