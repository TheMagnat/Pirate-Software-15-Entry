class_name WaterShaderHandler extends Node

# Material to handle
@export var shaderMaterial: ShaderMaterial

var tilt := Vector2.ZERO
var growing := Vector2i.ZERO

@export var growingSpeed: float = 10.0

@onready var limit: float = getTiltFunctionResult(1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func xIsTilted(xSign):
	# Tilt correction to prevent brutal change
	if growing.x == 0 and tilt.x != 0:
		var currentValue: float = getTiltFunctionResult(tilt.x)
		tilt.x = currentValue / limit
	
	growing.x = xSign
	
func zIsTilted(zSign):
	# Tilt correction to prevent brutal change
	if growing.y == 0 and tilt.y != 0:
		var currentValue: float = getTiltFunctionResult(tilt.y)
		tilt.y = currentValue / limit
		
	growing.y = zSign

func getTiltFunctionResult(x: float):
	return -x * cos(9.5 * x) * exp(0.002 * abs(x));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# X part
	if growing.x == 0:
		var currentSignX = sign(tilt.x)
		tilt.x -= sign(tilt.x) * delta
		if currentSignX != sign(tilt.x):
			tilt.x = 0.0
	else:
		tilt.x += growing.x * growingSpeed * delta
		if abs(tilt.x) > 1.0:
			growing.x = 0
			tilt.x = clamp(tilt.x, -1.0, 1.0)
	
	# Y part
	if growing.y == 0:
		var currentSignY = sign(tilt.y)
		tilt.y -= sign(tilt.y) * delta
		if currentSignY != sign(tilt.y):
			tilt.y = 0.0
	else:
		tilt.y += growing.y * growingSpeed * delta
		if abs(tilt.y) > 1.0:
			growing.y = 0
			tilt.y = clamp(tilt.y, -1.0, 1.0)
	
	# Set shader part
	var xTiltValue: float = 0.0
	var yTiltValue: float = 0.0
	
	if growing.x != 0:
		xTiltValue = tilt.x * limit
	else:
		xTiltValue = getTiltFunctionResult(tilt.x)
		
	if growing.y != 0:
		yTiltValue = tilt.y * limit
	else:
		yTiltValue = getTiltFunctionResult(tilt.y)
	
	shaderMaterial.set_shader_parameter("xTilt", xTiltValue)
	shaderMaterial.set_shader_parameter("yTilt", yTiltValue)
