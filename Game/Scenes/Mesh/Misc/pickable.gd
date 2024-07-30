class_name Pickable
extends Node3D

@export var itemKey: String
@export var itemCount := 1
var collector: Player = null

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", PI/4, 1.0).as_relative()
	
	var secondTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	secondTween.tween_property(self, "position:y", 0.25, 2.0).as_relative()
	secondTween.tween_property(self, "position:y", -0.25, 2.0).as_relative()

	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if(body is Player):
		$Area3D.body_entered.disconnect(_on_body_entered)
		
		body.pickup_item.emit(itemKey, itemCount)
		collector = body
		$AudioStreamPlayer3D.play()
		
		global_position = body.global_position + Vector3.UP * 1.5
		
		var t := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

		t.tween_property(self, "position:y", 1.5, 0.4).as_relative()
		t.parallel().tween_property(self, "scale", Vector3(0.25, 0.25, 0.25), 0.4).as_relative()
		
		t.tween_property(self, "position:y", -1.5, 0.4).as_relative()
		t.parallel().tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 0.4)
		
		$AudioStreamPlayer3D.finished.connect(queue_free)
		#t.finished.connect(queue_free)

func _physics_process(delta):
	if collector:
		global_position.x = collector.global_position.x
		global_position.z = collector.global_position.z
