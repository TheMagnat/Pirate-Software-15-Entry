extends Node3D

@onready var player : Player = $Player
@onready var playerSpawn := player.position

func _ready():
	Music.play(Music.lobby)
	player.set_camera($CameraInside)
	$GoOut.body_entered.connect(check_go_out)
	$Radio.finished.connect($Radio.play)
	$Prototype_Book.enter_craft.connect(enter_craft)

func go_back_to_spawn():
	set_process(false)
	Transition.start(
		func():
			gone(true)
			player.position = playerSpawn
			set_process(true))

var cam_tween : Tween
func enter_craft(b: bool):
	if cam_tween: cam_tween.kill()
	cam_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	cam_tween.tween_property($CameraInside, "position", $Prototype_Book/CamPos.global_position if b else Vector3(5.7, 5.7, 6.1), 0.5)
	cam_tween.tween_property($CameraInside, "rotation", Vector3(-PI/2, 0, 0) if b else Vector3(-PI/6, PI/4.5, 0), 0.5)

	if b:
		$Prototype_Book.tweenAnimation.pause()
		$Player/CameraLiberator.activated = false
	else:
		$Prototype_Book.tweenAnimation.play()
		cam_tween.tween_callback(func(): $Player/CameraLiberator.activated = true)

var CAMERA_OFFSET := 5.0
func _process(_delta):
	$CameraOutside.global_position.x = player.global_position.x
	$CameraOutside.global_position.z = player.global_position.z + CAMERA_OFFSET
	
	### lobby bounds check
	$CanvasLayer/Line2D.modulate.a = maxf(0.0, player.position.distance_to($CenterPoint.position) * 0.03 - 1.0)
	if $CanvasLayer/Line2D.modulate.a >= 0.75:
		go_back_to_spawn() 

func check_go_in(body):
	if body == player:
		go(true)

func check_go_out(body):
	if body == player:
		go(false)

func go(inside: bool):
	player.set_physics_process(false)
	if inside:
		$GoIn.body_entered.disconnect(check_go_in)
		$GoOut.body_entered.connect(check_go_out)
	else:
		$GoOut.body_entered.disconnect(check_go_out)
		$GoIn.body_entered.connect(check_go_in)
	Transition.start(gone.bind(inside))
	player.set_physics_process(true)

func gone(inside: bool):
	player.set_camera($CameraInside if inside else $CameraOutside)
