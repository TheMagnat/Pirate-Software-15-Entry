class_name Checkpoint extends Node3D

@export_enum("Front", "Left", "Back", "Right") var respawnCameraOrientation: int = 0

var area: Area3D
@onready var checkpoints: Checkpoints = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area = get_child(0)
	
	area.collision_layer = 0
	area.collision_mask = 0b010
	area.body_entered.connect(hitCheckpoint)

func hitCheckpoint(body):
	if body.is_in_group("Player") and not body.canBeSeen():
		checkpoints.hittedCheckpoint(self)
