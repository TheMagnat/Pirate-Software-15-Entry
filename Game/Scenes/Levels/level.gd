class_name Level extends Node3D

@export var open_levels : Array[int] = []

# Level information
@export var level_name: String
@export var main_ressource: String
@export var checkpoints: Checkpoints

var contained_resources : Dictionary
var finish_resources : Dictionary
var collected_resources : PackedStringArray

var nbEnemies: int = 0
var killedEnemies: int = 0

var isFinished: bool = false

var idx := -1

const WAIT_TIME := 10.0
var timer := Timer.new()
var time_spent := 0.0

func remove_already_collected():
	for path in collected_resources:
		# dirty
		var split := path.split('/')
		var localPath := ""
		for i in split.size() - 5:
			localPath += split[5 + i] + '/'
		print("Removing '" + localPath + "'")
		get_node(localPath).queue_free()

func initResources():
	for child in find_children("*", "Pickable"):
		if not contained_resources.has(child.itemKey):
			contained_resources[child.itemKey] = 0
		contained_resources[child.itemKey] += child.itemCount
	for resource in contained_resources:
		finish_resources[resource] = 0

func initPlayerSpells():
	# Load unlocked spells
	var unlockedSpells := PackedInt32Array()
	
	if Save.unlockable[0] > 0: unlockedSpells.push_back(0)
	if Save.unlockable[1] > 0: unlockedSpells.push_back(1)
	if Save.unlockable[2] > 0: unlockedSpells.push_back(2)
	
	$Player/SpellHolder.setAllowedSpells(unlockedSpells)
	
	### DEBUG ###
	#$Player/SpellHolder.setAllowedSpells([0, 1, 2])

func initMobs():
	for child in find_children("*", "Mob"):
		nbEnemies += 1
		child.get_node("DeathActionable").actioned.connect(func (body: Player): killedEnemies += 1)

func init(i: int):
	idx = i
	
	initResources()
	initPlayerSpells()
	initMobs()
	
	if Save.levels[idx][1] <= 0.0:
		print("No record set on this level")
	else:
		print("Record time on this level: " + str(Save.levels[idx][1]))
	
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 10.0
	timer.timeout.connect(func(): time_spent += WAIT_TIME)
	add_child(timer)

func restart_level(death := false):
	var respawnInformation: SpawnInformation = null
	if checkpoints:
		if death:
			respawnInformation = checkpoints.getLastCheckpointPosition()
	else:
		print("WARNING: No Checkpoints set for this level")	
	
	var main = get_node("/root/Main")
	main.load_level(idx, respawnInformation, death)

func escape_level(body):
	if not isFinished and (body.is_in_group("Player") and not body.canBeSeen()):
		body.safePlace = true
		isFinished = true
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").escape_level()

func finish_level(body):
	if not isFinished and (body.is_in_group("Player") and not body.canBeSeen()):
		body.safePlace = true
		isFinished = true
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").finish_level()

func finish_level_by_death(body):
	if not isFinished and body.is_in_group("Player"):
		isFinished = true
		time_spent += timer.wait_time - timer.time_left
		get_node("/root/Main").finish_level()

func add_to_inventory(key: String, count: int, object_path: String):
	finish_resources[key] += count
	collected_resources.append(object_path)
