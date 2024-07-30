@tool
extends Node3D

@export var content: CompressedTexture2D:
	set(value):
		content = value
		$Sprite3D.material_override.albedo_texture = value

func _ready():
	var material = StandardMaterial3D.new()
	material.albedo_texture = content
	$Sprite3D.material_override = material
