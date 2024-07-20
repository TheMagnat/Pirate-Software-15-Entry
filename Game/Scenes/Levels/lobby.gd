extends Node3D

@onready var player = $Player

func _ready():
	player.set_camera($CameraInside)
	$GoOut.body_entered.connect(check_go_out)

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
	
