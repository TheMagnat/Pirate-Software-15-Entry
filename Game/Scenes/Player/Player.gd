extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@export var lightTreshold: float = 0.75 # Value from which we consider the player is spotted
var spottedValue: float = 0.0 # When 1.0 is reached, the player is spotted
@export var timeForFullSpot: float = 0.25 # Seconds

var isDead: bool = false
var deadTime: float = 0.0

@onready var topViewport: Viewport = $"SubViewport"


# Parameters
@onready var waterShaderHandler: WaterShaderHandler = $WaterShaderHandler
@onready var spottedSprite := $CameraHolder/SpottedSprite

@onready var playerCamera := $CameraHolder/PlayerCamera
@onready var camera := playerCamera

func set_camera(cam: Camera3D):
	camera.current = false
	camera = cam
	camera.current = true

func _ready():
	waterShaderHandler.shaderMaterial = $CameraHolder/Potion/RootNode/ree.material_override
	$CameraHolder/PlayerCamera.position = CAMERA_SIDE_POS

func getLightLevel(top : bool = true) -> float:
	var img = null
	if top:
		img = topViewport.get_texture().get_image()

	#TODO: Ajouter le ELSE si besoin
	#else:
		#img = _viewport_bottom.get_texture().get_data()
	
	var sum: float = 0
	var height: int = img.get_height()
	var width: int = img.get_width()
	for y in height:
		for x in width:
			var p = img.get_pixel(x, y)
			var l = 0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b
			sum += l
	
	return sum / (width * height)

func lightLogic(delta: float):
	if isDead:
		deadTime += delta
		spottedSprite.material_override.set_shader_parameter("deadTime", deadTime)
		return

	var topLightLevel: float = getLightLevel()
	
	# If true, player is in the light
	if topLightLevel > lightTreshold:
		spottedValue += ((topLightLevel - lightTreshold) * delta) / timeForFullSpot
	else:
		spottedValue -= delta / timeForFullSpot
	
	spottedValue = clamp(spottedValue, 0.0, 1.0)
	
	if spottedValue == 1.0:
		isDead = true
	
	spottedSprite.material_override.set_shader_parameter("spottedValue", spottedValue)

var base_direction := Vector3()
var input_dir := Vector2()
func _process(_delta: float):
	if base_direction.x != 0:
		waterShaderHandler.xIsTilted(sign(base_direction.x))
	if base_direction.z != 0:
		waterShaderHandler.zIsTilted(-sign(base_direction.z))
	
	if camera != playerCamera and input_dir:
		$CameraHolder.global_rotation.y = 3.0 * PI/2 - input_dir.angle()
	
	$SubViewport/TopView.global_position.x = global_position.x
	$SubViewport/TopView.global_position.z = global_position.z

func _physics_process(delta: float):
	### Light computation Logic ###
	lightLogic(delta)
	
	### Movement Logic ###
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var base_input_dir := Input.get_vector("left", "right", "up", "down")
	input_dir = base_input_dir.rotated(-camera.global_rotation.y)
	base_direction = (transform.basis * Vector3(base_input_dir.x, 0, base_input_dir.y)).normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#TODO: Handle y position if player y can change

const CAMERA_SIDE_POS := Vector3(0, 2, 4)
const CAMERA_UP_POS := Vector3(0, 6, 0)

var cam_up_tween : Tween
var is_up := false
func camera_up(up: bool):
	if camera != playerCamera || up == is_up: return
	
	is_up = up
	if cam_up_tween: cam_up_tween.kill()
	cam_up_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	cam_up_tween.tween_property($CameraHolder/PlayerCamera, "rotation:x", -PI/2 if up else -PI/12, 0.3)
	cam_up_tween.tween_property($CameraHolder/PlayerCamera, "position", CAMERA_UP_POS if up else CAMERA_SIDE_POS, 0.3)
	cam_up_tween.tween_property(spottedSprite, "rotation:x", -PI/2 if up else 0.0, 0.3)

var cam_side_tween : Tween
var goal_rot_side := 0.0
func camera_side(side: float):
	if camera != playerCamera: return
	
	if cam_side_tween: cam_side_tween.kill()
	
	goal_rot_side += side * PI/2
	cam_side_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	cam_side_tween.tween_property($CameraHolder, "rotation:y", goal_rot_side, 0.25)

func _input(event):
	if event.is_action_pressed("cam_left"):
		camera_side(-1.0)
	if event.is_action_pressed("cam_right"):
		camera_side(1.0)
	if event.is_action_pressed("cam_up"):
		camera_up(true)
	if event.is_action_pressed("cam_down"):
		camera_up(false)
