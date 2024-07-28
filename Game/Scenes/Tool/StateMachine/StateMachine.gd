class_name StateMachine extends Node

@export var initialStateNode: StateNode

var stateNodes: Dictionary = {}
var currentStateNode: StateNode

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is StateNode:
			stateNodes[child.name] = child

func setInitialNode(initialNodeString: String):
	var newStateNode = stateNodes.get(initialNodeString)
	if newStateNode:
		initialStateNode = newStateNode

# This need to be called when every state are setuped and before the node run (in the parent node ready for example)
func initialize():
	if initialStateNode:
		initialStateNode.enter()
		currentStateNode = initialStateNode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentStateNode.onProcess(delta)

func _physics_process(delta):
	#if Engine.get_physics_frames() % 2 == 0:
	currentStateNode.onPhysicProcess(delta)

func transitionTo(newStateNodeName: String):
	if currentStateNode.name == newStateNodeName:
		return
	
	var newStateNode = stateNodes.get(newStateNodeName)
	
	if not newStateNode:
		return
	
	if currentStateNode:
		currentStateNode.exit()
	
	currentStateNode = newStateNode
	currentStateNode.enter()

func getCurrentStateName():
	return currentStateNode.name
