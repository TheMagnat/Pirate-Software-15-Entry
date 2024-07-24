extends Node

@onready var view: Area3D = get_parent().view
@export var stateMachine: StateMachine

signal spotted
var spottedValue: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for body in view.get_overlapping_bodies():
		if body.is_in_group("Player") and body.canBeSeen():
			
			if not spottedValue:
				spottedValue = true
				if stateMachine.getCurrentStateName() != "Chase":
					spotted.emit()
			
			stateMachine.get_node("Chase").target = body
			stateMachine.transitionTo("Chase")
			
			return
	
	spottedValue = false
