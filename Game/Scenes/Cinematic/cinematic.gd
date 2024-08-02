extends Node2D

const skip_button := preload("res://Scenes/Cinematic/skip.tscn")

@export var next_scene : PackedScene
@export var play_music := true
@onready var skip := skip_button.instantiate()


func _ready():
	if DebugHelper.debug and DebugHelper.loadLevelOnRun:
		get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")
		return
	
	skip.position = Vector2(1280 - 128, 720 - 128)
	skip.skip.connect(go_next)
	add_child(skip)
	
	$AnimationPlayer.animation_finished.connect(func(_anim_name : String): go_next())
	if play_music:
		Music.play(Music.mystery1)

func stop_music():
	Music.stop()

func play_menu_music():
	Music.play(Music.menu)

func go_next():
	skip.skip.disconnect(go_next)
	Transition.start(get_tree().change_scene_to_packed.bind(next_scene))
