class_name StateMachine extends Node

@export var initialStateNode: StateNode

var stateNodes: Dictionary = {}
var currentStateNode: StateNode

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is StateNode:
			stateNodes[child.name] = child
	
	if initialStateNode:
		initialStateNode.enter()
		currentStateNode = initialStateNode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currentStateNode:
		currentStateNode.onProcess(delta)

func _physics_process(delta):
	if currentStateNode:
		currentStateNode.onPhysicProcess(delta)

func transitionTo(newStateNodeName: String):
	if currentStateNode.name == newStateNodeName:
		return
	
	var newStateNode = stateNodes.get(newStateNodeName)
	
	if !newStateNode:
		return
		
	if currentStateNode:
		currentStateNode.exit()
	
	currentStateNode = newStateNode
	currentStateNode.enter()
