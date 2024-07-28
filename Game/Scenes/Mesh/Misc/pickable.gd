class_name Pickable
extends Node3D

@export var itemKey: String
@export var itemCount := 1

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if(body is Player):
		body.pickup_item.emit(itemKey, itemCount)
		queue_free()
