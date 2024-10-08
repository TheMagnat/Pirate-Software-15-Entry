extends Node3D


@onready var player: Player = get_parent()

var allowedSpells: PackedInt32Array
var spellList: Array
var currentSpellIndex: int = -1
@export var currentSpell: Node3D = null

#var aiming: bool = false
@export var action: String = "main_action"
@export var changeSpell: String = "secondary_action"
var currentSpellModel = null

func setAllowedSpells(allowedSpellsParam: PackedInt32Array):
	allowedSpells = allowedSpellsParam
	if allowedSpells:
		currentSpellIndex = 0
		for idx in allowedSpells:
			match idx:
				0:
					spellList.push_back( $Thrower )
				1:
					spellList.push_back( $Spawner )
				2:
					spellList.push_back( $Cloak )
		
		currentSpell = spellList[currentSpellIndex]
		if player: loadSpellMesh()
		
func loadSpellMesh():
	if not currentSpell: return
	
	if currentSpellModel:
		currentSpellModel.queue_free()
	
	currentSpellModel = currentSpell.model.instantiate()
	player.get_node("AssetsHolder/Potion/Fiole/BrasDroit").add_child(currentSpellModel)
	currentSpellModel.scale = Vector3(17.0, 17.0, 17.0)
	#currentSpellModel.position += Vector3(0.35, -0.1, 0.0)
	currentSpellModel.position += Vector3(36.5, 4.5, 10.5)
	
func changeCurrentSpell(forward: bool = true):
	if not spellList: return
	if currentSpell: currentSpell.aiming = false
		
	currentSpellIndex += 1 if forward else -1
	currentSpellIndex %= allowedSpells.size()
	
	currentSpell = spellList[currentSpellIndex]
	loadSpellMesh()
	

func _input(event):
	if event.is_action_pressed(action):
		if currentSpell: currentSpell.aiming = true
	elif event.is_action_released(action):
		if currentSpell and currentSpell.aiming: currentSpell.tryActivateSpell()
	
	elif event.is_action_pressed(changeSpell):
		changeCurrentSpell()
