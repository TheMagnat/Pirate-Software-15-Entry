extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Boss/DeathActionable/Area3D.collision_mask = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scale = Vector3(8.0, 8.0, 8.0)
	$Boss.scale = Vector3.ONE
