class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DEATH_ANIMATION_DELAY = 3 # seconds

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@export var lightTreshold: float = 0.1 # Value from which we consider the player is spotted
var spottedValue: float = 0.0 # When 1.0 is reached, the player is spotted
@export var timeForFullSpot: float = 1.0 # Seconds

var isDead: bool = false
var deadTime: float = 0.0

signal killed # emitted when the character dies, after the death animation completes

@onready var topViewport: Viewport = $"SubViewport"
@onready var animation: AnimationTree = $AssetsHolder/Potion/AnimationTree
@onready var animationTween: Tween
var state: int = 0
var animationBlendTime: float = 0.25

# Parameters
@onready var waterShaderHandler: WaterShaderHandler = $WaterShaderHandler
@onready var spottedSprite := $AssetsHolder/SpottedSprite

@onready var playerCamera := $CameraHolder/PlayerCamera
@onready var camera := playerCamera

func set_camera(cam: Camera3D):
	camera.current = false
	camera = cam
	camera.current = true

func _ready():
	#waterShaderHandler.shaderMaterial = $AssetsHolder/Potion/RootNode/Fiole/InterieurFiole/RootNode/Int_Fiole.material_override
	waterShaderHandler.shaderMaterial = $AssetsHolder/Potion/RootNode/Fiole/Oeuf/RootNode/Int_Potion.material_override
	#waterShaderHandler.shaderMaterial = $AssetsHolder/Potion/RootNode/Fiole/Interieur2/RootNode/Sphere001.material_override
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


func dying():
	isDead = true
	# Afficher le menu

func canBeSeen():
	return spottedValue > 0.0

func lightLogic(delta: float):
	if isDead:
		deadTime += delta
		spottedSprite.material_override.set_shader_parameter("deadTime", deadTime)
		
		if deadTime > DEATH_ANIMATION_DELAY:
			killed.emit()
		
		return

	var topLightLevel: float = getLightLevel()
	
	# If true, player is in the light
	if topLightLevel > lightTreshold:
		spottedValue += ((topLightLevel - lightTreshold) * delta) / timeForFullSpot
	else:
		spottedValue -= delta / timeForFullSpot
	
	spottedValue = clamp(spottedValue, 0.0, 1.0)
	
	if spottedValue == 1.0:
		dying()
	
	waterShaderHandler.shaderMaterial.set_shader_parameter("spottedValue", spottedValue)

var base_direction := Vector3()
var input_dir := Vector2()

func getTilt(goal: Vector2):
	var playerDirection: Vector3 = -$AssetsHolder.basis.z
	
	var goalAngle: float = Vector2(playerDirection.x, playerDirection.z).angle_to(Vector2(goal.x, goal.y)) / PI
	var absGoalAngle: float = abs(goalAngle)
	
	var xTilt: int = absGoalAngle < 4.0/5.0
	var yTilt: int = absGoalAngle > 1.0/5.0
	
	return Vector3(xTilt, yTilt, goalAngle)
	
func _process(_delta: float):
	# Handle water tilt
	if velocity.x != 0 or velocity.z != 0:
		var goal: Vector3 = (-velocity).normalized()
		var tilt: Vector3 = getTilt(Vector2(goal.x, goal.z))
		if tilt.x:
			waterShaderHandler.xIsTilted(-sign(tilt.z))
		if tilt.y:
			waterShaderHandler.zIsTilted(1.0)
		
		### Do the same but for the animation ###
		# 0.0 gauche 0.2 gauche 0.5 droite 0.8 droite 0.0
		# 0.2 gauche 0.3 et 0.7 droite 0.8
		var goal2d: Vector2
		var animationTime: float = animation["parameters/Walking/time"]
		var anyAnim: bool = true
		if animationTime > 0.2 and animationTime < 0.3:
			var front = -$AssetsHolder.basis.z
			var front2d = Vector2(front.x, front.z)
			var frontAngle: float = front2d.angle()
			goal2d = Vector2.from_angle(frontAngle + PI/2)
			
		elif animationTime > 0.7 and animationTime < 0.8:
			var front = -$AssetsHolder.basis.z
			var front2d = Vector2(front.x, front.z)
			var frontAngle: float = front2d.angle()
			goal2d = Vector2.from_angle(frontAngle - PI/2)
		
		else:
			anyAnim = false
		
		if anyAnim:
			tilt = getTilt(goal2d)
			if tilt.x:
				waterShaderHandler.xIsTilted(-sign(tilt.z))
			if tilt.y:
				waterShaderHandler.zIsTilted(1.0)
	
	if input_dir:
		if state != 1:
			if animationTween: animationTween.kill()
			animationTween = create_tween()
			animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 1.0, animationBlendTime)
			state = 1
		
		var newAngle = 3.0 * PI/2 - input_dir.angle()
		$AssetsHolder.global_rotation.y = lerp_angle($AssetsHolder.global_rotation.y, newAngle, 10.0 * _delta)
	else:
		if state != 0:
			if animationTween: animationTween.kill()
			animationTween = create_tween()
			animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 0.0, animationBlendTime)
			state = 0
			
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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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
	#cam_side_tween.tween_property($AssetsHolder, "rotation:y", goal_rot_side, 0.25)
func _input(event):
	if event.is_action_pressed("cam_left"):
		camera_side(-1.0)
	if event.is_action_pressed("cam_right"):
		camera_side(1.0)
	if event.is_action_pressed("cam_up"):
		camera_up(true)
	if event.is_action_pressed("cam_down"):
		camera_up(false)
