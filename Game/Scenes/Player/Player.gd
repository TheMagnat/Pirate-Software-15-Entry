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


func _ready():
	waterShaderHandler.shaderMaterial = $CameraHolder/Potion/RootNode/ree.material_override

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
	var input_dir := base_input_dir.rotated(-$CameraHolder.rotation.y)
	var base_direction := (transform.basis * Vector3(base_input_dir.x, 0, base_input_dir.y)).normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if base_direction.x != 0:
		waterShaderHandler.xIsTilted(sign(base_direction.x))
	if base_direction.z != 0:
		waterShaderHandler.zIsTilted(-sign(base_direction.z))
	
	$SubViewport/TopView.global_position.x = global_position.x
	$SubViewport/TopView.global_position.z = global_position.z
	#TODO: Handle y position if player y can change

var cam_tween : Tween
var goal_rot_side := 0.0

func camera_side(side: float):
	if cam_tween: cam_tween.kill()
	
	goal_rot_side += side * PI/2
	cam_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	cam_tween.tween_property($CameraHolder, "rotation", Vector3(0.0, goal_rot_side, 0.0), 0.25)

func _input(event):
	if event.is_action_pressed("cam_left"):
		camera_side(-1.0)
	if event.is_action_pressed("cam_right"):
		camera_side(1.0)
