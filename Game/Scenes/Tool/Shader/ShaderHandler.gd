class_name ShaderHandler extends Node

# Material to handle
@export var shaderMaterial: ShaderMaterial

# Shader parameters
@export var handledParameters: PackedStringArray
@export var parametersSpeed: PackedFloat32Array # Speed at which the value come back to 0
var parametersState: PackedInt32Array # Grow to 1 when equal to 1

var parameters: Dictionary = {}
var parametersIndex: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in handledParameters.size():
		var handledParameter: String = handledParameters[i]
		parametersIndex[handledParameter] = i
		parameters[handledParameter] = 0.0
		parametersState.push_back(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in handledParameters.size():
		var handledParameter: String = handledParameters[i]
		
		if parametersState[i] > 0:
			parameters[handledParameter] += delta * parametersSpeed[i]
			parameters[handledParameter] = min(1.0, parameters[handledParameter])
		else:
			parameters[handledParameter] -= delta * parametersSpeed[i]
			parameters[handledParameter] = max(0.0, parameters[handledParameter])
		
		shaderMaterial.set_shader_parameter(handledParameter, parameters[handledParameter])

func setValue(param: String, value: float):
	parameters[param] = value

func addValue(param: String, value: float):
	parameters[param] = clamp(parameters[param] + value, 0.0, 1.0)

func setGrowingValue(param: String, state: int):
	var i = parametersIndex[param]
	parametersState[i] = state
