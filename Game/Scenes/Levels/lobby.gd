extends Node3D

@onready var player = $Player

func _ready():
	Music.play(Music.lobby)
	player.set_camera($CameraInside)
	$GoOut.body_entered.connect(check_go_out)
	$Radio.finished.connect($Radio.play)
	$Prototype_Book.enter_craft.connect(enter_craft)

var cam_tween : Tween
func enter_craft(b: bool):
	
	if cam_tween: cam_tween.kill()
	cam_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	cam_tween.tween_property($CameraInside, "position", Vector3(-8.2, 0.9, 6.1) if b else Vector3(9, 7, 8), 0.5)
	cam_tween.tween_property($CameraInside, "rotation", Vector3(-PI/2, PI/2, 0) if b else Vector3(-PI/6, PI/4.5, 0), 0.5)

	if b:
		$Player/CameraLiberator.activated = false
	else:
		cam_tween.tween_callback(func(): $Player/CameraLiberator.activated = true)

var CAMERA_OFFSET := 5.0
func _process(_delta):
	$CameraOutside.global_position.x = player.global_position.x
	$CameraOutside.global_position.z = player.global_position.z + CAMERA_OFFSET

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
	
