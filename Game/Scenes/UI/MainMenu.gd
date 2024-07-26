extends Node2D

const GAME_SCENE := preload("res://Scenes/Main/main.tscn")
const INTRO_SCENE := preload("res://Scenes/Cinematic/intro.tscn")

func play_continue():
	print("starting game")
	Transition.start(get_tree().change_scene_to_packed.bind(GAME_SCENE))

func play_new_game():
	if Save.save_exists(): #game already exists
		Save.save_erase()
	
	print("starting intro")
	Transition.start(get_tree().change_scene_to_packed.bind(INTRO_SCENE))

func settings():
	$Main.hide()
	$Settings.show()

func you_sure():
	if Save.save_exists(): #game already exists
		$YouSure.show()
		$Main.hide()
	else:
		play_new_game()

func back():
	$Main.show()
	$Settings.hide()
	$YouSure.hide()

func quit():
	get_tree().quit()

func _ready():
	Music.play(Music.menu)
	
	$Main/Continue.pressed.connect(play_continue)
	$Main/NewGame.pressed.connect(you_sure)
	$Main/Settings.pressed.connect(settings)
	$Main/Quit.pressed.connect(quit)

	$Settings/Back.pressed.connect(back)
	
	$YouSure/Yes.pressed.connect(play_new_game)
	$YouSure/No.pressed.connect(back)
	
	if !Save.save_exists():
		$Main/Continue.disabled = true
	$Settings.hide()
	$YouSure.hide()
