extends CanvasLayer

@onready var MUSIC_BUS := AudioServer.get_bus_index("Music")

func _main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

const TWEEN_TIME := 0.5
var menu_tween : Tween
func menu_tween_func(s : bool):
	if menu_tween: menu_tween.kill()
	menu_tween = create_tween().set_parallel(true).bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	menu_tween.tween_property(AudioServer.get_bus_effect(MUSIC_BUS, 0), "cutoff_hz", 500.0 if s else 20500.0, TWEEN_TIME)
	menu_tween.tween_property(AudioServer.get_bus_effect(MUSIC_BUS, 1), "wet", 0.25 if s else 0.0, TWEEN_TIME)
	menu_tween.tween_method(func(v: float): AudioServer.set_bus_volume_db(MUSIC_BUS, v), AudioServer.get_bus_volume_db(MUSIC_BUS), -11.0 if s else -8.0, TWEEN_TIME)

func main_menu():
	set_process_input(false)
	menu_tween_func(false)
	Transition.start(_main_menu)

func _ready():
	$Control.visible = false
	$Control/HBoxContainer/Main/Restart.pressed.connect(get_parent().restart_level)
	$Control/HBoxContainer/Main/Lobby.pressed.connect(get_parent().load_lobby)
	$Control/HBoxContainer/Main/MainMenu.pressed.connect(main_menu)
	$Control/HBoxContainer/Main/Settings.pressed.connect(show_settings.bind(true))
	$Control/HBoxContainer/Settings.back.connect(show_settings.bind(false))
	$Control/HBoxContainer/Main/Back.pressed.connect(show_menu.bind(false))

func show_settings(s: bool):
	$Control/HBoxContainer/Main.visible = !s
	$Control/HBoxContainer/Settings.visible = s

func show_menu(s: bool):
	menu_tween_func(s)
	
	get_tree().paused = s
	$Control.visible = s

func _input(event):
	if event.is_action_pressed("pause"):
		show_menu(!$Control.visible)
