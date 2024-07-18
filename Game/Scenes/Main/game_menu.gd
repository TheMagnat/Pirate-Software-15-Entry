extends CanvasLayer

func main_menu():
	get_tree().change_scene_to_file("res://Scenes/Main/main_menu.tscn")

func _ready():
	$Control.visible = false
	$Control/VBoxContainer/MainMenu.pressed.connect(main_menu)
	$Control/VBoxContainer/Back.pressed.connect(show_menu.bind(false))

func show_menu(show: bool):
	get_tree().paused = show
	$Control.visible = show

func _input(event):
	if event.is_action_pressed("pause"):
		show_menu(!$Control.visible)
