class_name Checkpoints extends Node3D

var lastCheckpoint: Checkpoint = null
var lastResources := {}
var lastCollected := []

func hittedCheckpoint(checkpoint: Checkpoint):
	if checkpoint != lastCheckpoint:
		lastCheckpoint = checkpoint
		lastResources = get_parent().finish_resources
		lastCollected = get_parent().collected_resources

func getLastCheckpointPosition():
	if lastCheckpoint:
		print(lastCheckpoint.respawnCameraOrientation)
		print(lastCheckpoint.respawnCameraOrientation * PI/2.0)
		return SpawnInformation.new(lastCheckpoint.global_position, lastCheckpoint.respawnCameraOrientation * PI/2.0, lastResources, lastCollected)
	
	return null
