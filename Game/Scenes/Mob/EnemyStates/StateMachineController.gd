extends Node

@onready var view: Area3D = get_parent().view
@export var stateMachine: StateMachine
@onready var mob: Mob = get_parent()
@onready var imperturbable: bool = get_parent().imperturbable

signal spotted
var spottedValue: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if imperturbable: return
	
	if Engine.get_physics_frames() % 2 == 0:
		for body in view.get_overlapping_bodies():
			if body.is_in_group("Player") and body.canBeSeen():
				
				if not mob.checkBodyCanBeSeen(body):
					continue
				
				if not spottedValue:
					spottedValue = true
					if stateMachine.getCurrentStateName() != "Chase":
						spotted.emit()
				
				stateMachine.get_node("Chase").target = body
				stateMachine.transitionTo("Chase")
				
				return
		
		spottedValue = false
