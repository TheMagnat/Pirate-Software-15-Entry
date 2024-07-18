extends CanvasLayer

func _main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main/main_menu.tscn")

func main_menu():
	Transition.start(_main_menu)

func _ready():
	$Control.visible = false
	$Control/VBoxContainer/MainMenu.pressed.connect(main_menu)
	$Control/VBoxContainer/Back.pressed.connect(show_menu.bind(false))

func show_menu(s: bool):
	get_tree().paused = s
	$Control.visible = s

func _input(event):
	if event.is_action_pressed("pause"):
		show_menu(!$Control.visible)
