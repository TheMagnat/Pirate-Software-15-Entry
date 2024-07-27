extends StaticBody3D

@export var duration: float = 3.0

var goalY: float

func startGrowing():
	
	var objectHeight: float = ($Cube.mesh.size.y)
	var offset: float = 0.3
	global_position.y -= objectHeight
	
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", (objectHeight - offset), 1.0).as_relative()
	tween.tween_interval(duration)
	tween.tween_property(self, "global_position:y", -(objectHeight), 1.0).set_trans(Tween.TRANS_SINE).as_relative()
	tween.tween_callback(queue_free)
