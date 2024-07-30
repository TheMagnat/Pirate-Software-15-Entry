class_name Player extends CharacterBody3D

enum {
	PotionOfDisturbance,
	IvyWall,
	ShadeCloak,
	CatWalk,
	HardenedMixture,
	CastingSpeed
}

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DEATH_ANIMATION_DELAY = 1.0 # seconds

const catWalkMultiplier: float = 0.2
const mixtureMultiplier: float = 1.0

const sneakMultiplier: float = 0.4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var safePlace: bool = false
@export var lightTreshold: float = 0.25 # Value from which we consider the player is spotted
var spottedValue: float = 0.0 # When 1.0 is reached, the player is spotted
@export var timeForFullSpot: float = 0.6 # Seconds

var isDead: bool = false
var deadTime: float = 0.0

signal killed # emitted when the character dies, after the death animation completes

signal pickup_item(item: String, count: int, object_path: String)

@onready var topViewport: Viewport = $"SubViewport"
@onready var animation: AnimationTree = $AssetsHolder/Potion/AnimationTree
@onready var animationTween: Tween
var state: int = 0
var animationBlendTime: float = 0.25

# Parameters
@onready var waterShaderHandler: WaterShaderHandler = $WaterShaderHandler
@onready var shaderHandler: ShaderHandler = $ShaderHandler

@onready var playerCamera := $CameraHolder/PlayerCamera
@onready var camera := playerCamera

var heightCompensation := Vector3(0.0, 1.0, 0.0)

func set_camera(cam: Camera3D):
	camera.current = false
	camera = cam
	camera.current = true

func _ready():
	$AssetsHolder/CloakEffect.visible = false
	
	shaderHandler.shaderMaterial = $AssetsHolder/Potion/Fiole/BrasGauche.material_override.next_pass.next_pass
	waterShaderHandler.shaderMaterial = $AssetsHolder/Potion/Fiole/Oeuf/RootNode/Int_Potion.material_override
	
	$CameraHolder/PlayerCamera.position = CAMERA_SIDE_POS
	
	$SpellHolder.loadSpellMesh()
	
#var cumulatedTimeSinceLastLightLevelSample: float = 0.0
var lastLightLevel: float = 0.0
func getLightLevel() -> float:
	var img: Image = topViewport.get_texture().get_image()
	var height: int = img.get_height()
	var width: int = img.get_width()
	var maxl_1: float = 0.0
	var maxl_2: float = 0.0
	var maxl_3: float = 0.0
	for y in height:
		for x in width:
			var p = img.get_pixel(x, y)
			var l = 0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b
			if l > maxl_3:
				if l > maxl_2:
					if l > maxl_1:
						maxl_3 = maxl_2
						maxl_2 = maxl_1
						maxl_1 = l
						continue
					maxl_3 = maxl_2
					maxl_2 = l
					continue
				maxl_3 = l
	
	return (maxl_1 + maxl_2 + maxl_3) / 3.0

var actionPossible: bool = false
func setActionPossible(isPossible: bool):
	actionPossible = isPossible
	shaderHandler.setGrowingValue("actionState", int(isPossible))

func dying(instant: bool = false):
	isDead = true
	if instant:
		killed.emit()
	else:
		get_tree().create_timer(DEATH_ANIMATION_DELAY).timeout.connect(func(): killed.emit())

func canBeSeen():
	return spottedValue > lightTreshold

func lightLogic(delta: float):
	if isDead:
		deadTime += delta
		return
	
	if Engine.get_physics_frames() % 5 == 0:
		# Verify light level...
		lastLightLevel = getLightLevel()
		# And if there is a mob at sneak foot range
		for body in $SneakSoundEmission.get_overlapping_bodies():
			if body.is_in_group("Enemy"):
				body.suspiciousActivity(global_position + heightCompensation, 0.0)
				lastLightLevel = 1.0
	
	# If true, player is in the light
	var time : float = timeForFullSpot * (1 + Save.unlockable[HardenedMixture] * mixtureMultiplier)
	if not cloaking and lastLightLevel > lightTreshold:
		spottedValue += ((lastLightLevel - lightTreshold) * delta) / time
	else:
		spottedValue -= (delta * (1.0 + int(cloaking) * 4.0)) / (time * (2.0))
	
	spottedValue = clampf(spottedValue, 0.0, 1.0)
	$Boiling.volume_db = (-1.0 + spottedValue) * 40.0
	$Boiling.pitch_scale = 1.5 - spottedValue * 0.7
	
	if spottedValue == 1.0:
		dying()
	
	waterShaderHandler.shaderMaterial.set_shader_parameter("spottedValue", spottedValue)
	$CanvasLayer/Sprite2D.material.set_shader_parameter("life", spottedValue);

var base_direction := Vector3()
var input_dir := Vector2()
var sneaking: bool = false

func getTilt(goal: Vector2):
	var playerDirection: Vector3 = -$AssetsHolder.basis.z
	
	var goalAngle: float = Vector2(playerDirection.x, playerDirection.z).angle_to(Vector2(goal.x, goal.y)) / PI
	var absGoalAngle: float = abs(goalAngle)
	
	var xTilt: int = absGoalAngle < 4.0/5.0
	var yTilt: int = absGoalAngle > 1.0/5.0
	
	return Vector3(xTilt, yTilt, goalAngle)

var leftPlay: bool = false
var rightPlay: bool = false

var footEmissionSuspiciousLevel: float = 3.0
func emitSuspiciousSound():
	for body in $FootSoundEmission.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.suspiciousActivity(global_position + heightCompensation, footEmissionSuspiciousLevel)

var sneakEmissionSuspiciousLevel: float = 0.5
func emitSuspiciousSneakSound():
	for body in $SneakSoundEmission.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.suspiciousActivity(global_position + heightCompensation, sneakEmissionSuspiciousLevel)

#TODO: Selectionner en fonction du niveau ou du type de sol ?
@onready var currentGroundStepSound: AudioStreamPlayer3D = $ConcreteStepPlayer
func changeGroundSound(value):
	if value == 0:
		currentGroundStepSound = $GrassStepPlayer
	elif value == 1:
		currentGroundStepSound = $ConcreteStepPlayer
	else:
		currentGroundStepSound = $MetalStepPlayer
	
func playFootStep():
	var volumeValue: float
	var pitchScale: float

	if sneaking || cloaking:
		volumeValue = -27.0
		pitchScale = 1.25
		emitSuspiciousSneakSound()
	else:
		volumeValue = -17.0
		pitchScale = 1.0
		emitSuspiciousSound()

	currentGroundStepSound.volume_db = volumeValue
	currentGroundStepSound.pitch_scale = pitchScale
	
	currentGroundStepSound.play()

func _process(_delta: float):
	# Handle water tilt and waliking sound
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
		
		# To prevent using nil value in Walking/time
		var safeAnimationTime = animation["parameters/Walking/current_position"]
		var animationTime: float = safeAnimationTime if safeAnimationTime else 0.0
		
		#Play walking sound every time the time hit 0.25 and 0.75
		if animation["parameters/Blend2/blend_amount"] > 0.4:
			# Left foot
			if animationTime > 0.15 and animationTime < 0.4:
				if not leftPlay:
					playFootStep()
					leftPlay = true
			else:
				leftPlay = false
			
			# Right foot
			if animationTime > 0.65 and animationTime < 0.9:
				if not rightPlay:
					playFootStep()
					rightPlay = true
			else:
				rightPlay = false
		
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
	
	# Handler animation blend
	if input_dir:
		var animSpeed : float = 1.0 + catWalkMultiplier * Save.unlockable[CatWalk]
		if sneaking and state != 2:
			if animationTween: animationTween.kill()
			animationTween = create_tween()
			animationTween.set_parallel(true)
			animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 0.5, animationBlendTime)
			animationTween.tween_property(animation, "parameters/WalkingTime/scale", 1.5 * animSpeed, animationBlendTime)
			state = 2
			
		elif not sneaking and state != 1:
			if animationTween: animationTween.kill()
			animationTween = create_tween()
			animationTween.set_parallel(true)
			animationTween.tween_property(animation, "parameters/Blend2/blend_amount", 1.0, animationBlendTime)
			animationTween.tween_property(animation, "parameters/WalkingTime/scale", animSpeed, animationBlendTime)
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
	$SubViewport/TopView.global_position.y = global_position.y + 1.5

const CLOAK_ANIM_TIME := 0.5
const BASE_CLOAK_SCALE := Vector3(0.5, 0.0, 0.5)
const BASE_CLOAK_VOLUME := -20.0
var cloaking := false
var cloak_tween : Tween
func cloak_tween_finish():
	if cloaking:
		$AssetsHolder/Potion.visible = false
	else:
		$AssetsHolder/CloakEffect.visible = false
		$Cloaking.stop()

func cloak_do_tween():
	if cloak_tween: cloak_tween.kill()
	cloak_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	cloak_tween.tween_property($AssetsHolder/Potion, "scale:y", 0.0 if cloaking else 1.0, CLOAK_ANIM_TIME)
	cloak_tween.tween_property($AssetsHolder/CloakEffect, "scale", Vector3(1, 1, 1) if cloaking else BASE_CLOAK_SCALE, CLOAK_ANIM_TIME)
	cloak_tween.tween_property($Cloaking, "pitch_scale", 0.4 if cloaking else 1.0, CLOAK_ANIM_TIME)
	cloak_tween.tween_property($Cloaking, "volume_db", -2 if cloaking else BASE_CLOAK_VOLUME, CLOAK_ANIM_TIME)
	cloak_tween.finished.connect(cloak_tween_finish)

func cloak(): 
	cloaking = true
	$AssetsHolder/CloakEffect.visible = true
	$AssetsHolder/CloakEffect.scale = BASE_CLOAK_SCALE
	$Cloaking.volume_db = BASE_CLOAK_VOLUME
	$Cloaking.play()
	cloak_do_tween()

func uncloak():
	cloaking = false
	$AssetsHolder/Potion.visible = true
	cloak_do_tween()

var slashAnimationTween: Tween
func slash():
	$SlashPlayer.play()
	
	if slashAnimationTween: slashAnimationTween.kill()
	animationTween = create_tween()
	#animationTween.set_parallel(true)
	animationTween.tween_property(animation, "parameters/SlashBlend/blend_amount", 1.0, 0.01)
	animationTween.tween_property(animation, "parameters/SlashBlend/blend_amount", 0.0, 1.0)
	animation.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _physics_process(delta: float):
	### Light computation Logic ###
	if not safePlace: lightLogic(delta)
	else: $CanvasLayer/Sprite2D.material.set_shader_parameter("life", 0.0);
	
	### Movement Logic ###
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var base_input_dir := Input.get_vector("left", "right", "up", "down") if not isDead else Vector2.ZERO
	input_dir = base_input_dir.rotated(-camera.global_rotation.y)
	base_direction = (transform.basis * Vector3(base_input_dir.x, 0, base_input_dir.y)).normalized()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	sneaking = Input.is_action_pressed("sneak")
	var speedMultiplier: float = (sneakMultiplier if sneaking and not cloaking else 1.0) + catWalkMultiplier * Save.unlockable[CatWalk]
	
	if direction:
		velocity.x = direction.x * SPEED * speedMultiplier
		velocity.z = direction.z * SPEED * speedMultiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#TODO: Handle y position if player y can change

func setSpawnOrientation(angle: float):
	goal_rot_side = angle
	$CameraHolder.rotation.y = angle
	var targetDir2d := Vector2.from_angle(-angle - PI/2.0)
	var target: Vector3 = global_position + Vector3(targetDir2d.x, 0.0, targetDir2d.y)
	$AssetsHolder.look_at(target)
	
const CAMERA_SIDE_POS := Vector3(0, 2, 4)

var cam_side_tween : Tween
var goal_rot_side := 0.0
func camera_side(side: float):
	if camera != playerCamera: return
	
	if cam_side_tween: cam_side_tween.kill()
	
	goal_rot_side += side * PI/4
	cam_side_tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	cam_side_tween.tween_property($CameraHolder, "rotation:y", goal_rot_side, 0.25)
	#cam_side_tween.tween_property($AssetsHolder, "rotation:y", goal_rot_side, 0.25)

func _input(event):
	if event.is_action_pressed("cam_left"):
		camera_side(-1.0)
	if event.is_action_pressed("cam_right"):
		camera_side(1.0)

func _on_world_edge_2_body_entered(body):
	dying(true)
