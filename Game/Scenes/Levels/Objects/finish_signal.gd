extends Area3D

@export_enum("Escape", "Finish") var type : int

@export var player: Player
var material: ShaderMaterial

@onready var color : Color = Color(0, 1, 0, 0.25) if type == 0 else Color(1, 0.9, 0, 0.25)

func _ready():
	$MeshInstance3D2.set_surface_override_material(0, $MeshInstance3D2.get_active_material(0).duplicate())
	$MeshInstance3D2.get_active_material(0).albedo_color = color
	
	material = $MeshInstance3D.get_active_material(0).duplicate()
	$MeshInstance3D.set_surface_override_material(0, material)
	material.set_shader_parameter("color", color)

func _process(_delta: float):
	var v := Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(global_position.x, global_position.z)) * 0.03
	material.set_shader_parameter("dist", clampf(sqrt(v) - 0.5, 0.0, 1.0))
