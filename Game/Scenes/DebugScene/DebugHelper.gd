extends Node

var debug: bool = false

var loadLevelOnRun: bool = false
var debugStartLevel: int = 1
var unlockAllSpells: bool = false

# Level player start position. It will be used if debug is false and ignoreSpawnPosition is true
var ignoreSpawnPosition: bool = false
var playerStartPosition: PackedVector3Array = [
	Vector3(0.0, 0.0, 0.0), #0 - Debug
	Vector3(-12.5, 0.0, 11.4), #1 - Forest
	Vector3(0.0, 0.4, 8.0), #2 - Dungeon
	Vector3(0.0, 0.0, 0.0), # 3 - Hill
	Vector3(0.0, 0.0, 35.0) # 4 - Manor
]

"""
Extra checks :
	- Be sure to hide the light texture sprite in the Player scene
"""
