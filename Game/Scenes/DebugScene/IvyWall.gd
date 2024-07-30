extends StaticBody3D

const BASE_DURATION := 5.0
const DURATION_PER_LEVEL := 3.0
const BASE_SIZE_Y := 0.5
const SIZE_PER_LEVEL := 0.5

var goalY: float

func startGrowing():
	var level := maxi(1, Save.unlockable[Player.IvyWall])
	
	$Cube.scale.y = BASE_SIZE_Y + SIZE_PER_LEVEL * level
	$CubeCollision.shape = $CubeCollision.shape.duplicate()
	$CubeCollision.shape.size.y *= $Cube.scale.y
	
	var objectHeight: float = $Cube.mesh.size.y * $Cube.scale.y
	var offset: float = 0.3 * $Cube.scale.y
	
	global_position.y -= objectHeight
	
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", (objectHeight - offset), 1.0).as_relative()
	tween.tween_interval(BASE_DURATION + DURATION_PER_LEVEL * level)
	tween.tween_property(self, "global_position:y", -(objectHeight), 1.0).set_trans(Tween.TRANS_SINE).as_relative()
	tween.tween_callback(queue_free)
