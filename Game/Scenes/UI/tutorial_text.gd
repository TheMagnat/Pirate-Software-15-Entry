extends Label3D

func _ready():
	$AnimationPlayer.speed_scale = randf_range(0.5, 2.0)
