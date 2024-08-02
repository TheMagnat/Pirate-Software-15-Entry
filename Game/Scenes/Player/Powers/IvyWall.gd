extends StaticBody3D

const BASE_DURATION := 3.0
const DURATION_PER_LEVEL := 3.0
const BASE_SIZE_Y := 0.5
const SIZE_PER_LEVEL := 0.25

var goalY: float

func startGrowing():
	var level := maxi(1, Save.unlockable[Player.IvyWall])
	
	$Mesh.scale.y = BASE_SIZE_Y + SIZE_PER_LEVEL * level
	$CubeCollision.shape = $CubeCollision.shape.duplicate()
	$CubeCollision.shape.size.y *= $Mesh.scale.y
	
	var objectHeight: float = ($Mesh.scale.y * 3.0)

	global_position.y -= objectHeight
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", objectHeight, 1.0).as_relative()
	tween.tween_interval(BASE_DURATION + DURATION_PER_LEVEL * level - 2.0)
	tween.tween_property(self, "global_position:y", -objectHeight, 1.0).set_trans(Tween.TRANS_SINE).as_relative()
	tween.tween_callback(queue_free)
