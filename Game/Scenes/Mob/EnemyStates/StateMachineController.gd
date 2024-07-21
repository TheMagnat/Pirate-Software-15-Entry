extends Node

@export var view: Area3D
@export var stateMachine: StateMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for body in view.get_overlapping_bodies():
		if body.is_in_group("Player") and body.canBeSeen():
			stateMachine.get_node("Chase").target = body
			stateMachine.transitionTo("Chase")
