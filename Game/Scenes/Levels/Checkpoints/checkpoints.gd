class_name Checkpoints extends Node3D

var lastCheckpoint: Checkpoint = null

func hittedCheckpoint(checkpoint: Checkpoint):
	lastCheckpoint = checkpoint

func getLastCheckpointPosition():
	if lastCheckpoint:
		print(lastCheckpoint.respawnCameraOrientation)
		print(lastCheckpoint.respawnCameraOrientation * PI/2.0)
		return SpawnInformation.new(lastCheckpoint.global_position, lastCheckpoint.respawnCameraOrientation * PI/2.0)
	
	return null
