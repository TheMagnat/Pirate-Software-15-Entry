extends Node3D

@onready var player: Player = get_parent().get_node("Player")

func _ready():
	if not player.get_node("SpellHolder").spellList:
		$TutorialSpellText.hide()
	else:
		$TutorialNoSpellText.hide()
