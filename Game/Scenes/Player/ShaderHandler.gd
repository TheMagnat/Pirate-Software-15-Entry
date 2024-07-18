class_name ShaderHandler extends Node

# Material to handle
@export var shaderMaterial: ShaderMaterial

# Shader parameters
@export var handledParameters: PackedStringArray
@export var parametersSpeed: PackedFloat32Array # Speed at which the value come back to 0

var parameters: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	for handledParameter in handledParameters:
		parameters[handledParameter] = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in handledParameters.size():
		var handledParameter: String = handledParameters[i]
		
		parameters[handledParameter] -= delta * parametersSpeed[i]
		parameters[handledParameter] = max(0.0, parameters[handledParameter])
		
		shaderMaterial.set_shader_parameter(handledParameter, parameters[handledParameter])

func setValue(param: String, value: float):
	parameters[param] = value

func addValue(param: String, value: float):
	parameters[param] = clamp(parameters[param] + value, 0.0, 1.0)
