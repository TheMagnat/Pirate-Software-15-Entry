extends Node2D

const skip_button := preload("res://Scenes/Cinematic/skip.tscn")

@export var next_scene : PackedScene
@onready var skip := skip_button.instantiate()

func _ready():
	skip.position = Vector2(1280 - 128, 720 - 128)
	skip.skip.connect(go_next)
	add_child(skip)
	
	$AnimationPlayer.animation_finished.connect(func(_anim_name : String): go_next())

func go_next():
	skip.skip.disconnect(go_next)
	Transition.start(get_tree().change_scene_to_packed.bind(next_scene))
