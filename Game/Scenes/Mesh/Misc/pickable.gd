class_name Pickable
extends Node3D

@export var itemKey: String
@export var itemCount := 1

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation:y", PI/4, 1.0).as_relative()
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if(body is Player):
		$Area3D.body_entered.disconnect(_on_body_entered)
		body.pickup_item.emit(itemKey, itemCount)
		var t := create_tween()
		t.tween_property(self, "scale", Vector3(0, 0, 0), 1)
		t.finished.connect(queue_free)
