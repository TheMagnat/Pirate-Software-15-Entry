extends Node3D

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", PI/4, 1.0).as_relative()
	
	var secondTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	secondTween.tween_property(self, "position:y", 0.25, 2.0).as_relative()
	secondTween.tween_property(self, "position:y", -0.25, 2.0).as_relative()
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Player:
		$Area3D.body_entered.disconnect(_on_body_entered)
		var t := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		t.parallel().tween_property(self, "scale", Vector3(0.25, 0.25, 0.25), 0.4).as_relative()
		t.parallel().tween_property(self, "scale", Vector3(0.0001, 0.0001, 0.0001), 0.4)
		t.finished.connect(queue_free)
