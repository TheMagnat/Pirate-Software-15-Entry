class_name LevelEndScreen extends CanvasLayer


var escape: bool = false

var ressourceAnimationOrder = []
func fillScreen(level: Level, escapeParam: bool = false):
	escape = escapeParam
	if escape:
		$ScreenContainer/TitleContainer/LevelName.text = "Escaped from %s" % level.level_name
	else:
		$ScreenContainer/TitleContainer/LevelName.text = "%s Finished" % level.level_name
	
	$ScreenContainer/RessourcesSection/MainRessource/MainRessource.text = level.main_ressource.capitalize()
	
	for ressource in level.contained_resources:
		var count: int = level.finish_resources[ressource]
		var total: int = level.contained_resources[ressource]
		
		# Create the ressource control
		var ressourceLabel := Label.new()
		ressourceLabel.text = ressource.capitalize()
		
		var margin := MarginContainer.new()
		margin.size_flags_horizontal = Control.SIZE_EXPAND
		
		var nbRessource := Label.new()
		nbRessource.text = "%d / %d" % [count, total]
		
		var hBoxContainer := HBoxContainer.new()
		hBoxContainer.add_child(ressourceLabel)
		hBoxContainer.add_child(margin)
		hBoxContainer.add_child(nbRessource)
		
		$ScreenContainer/RessourcesSection.add_child(hBoxContainer)
		
		ressourceAnimationOrder.push_back(hBoxContainer)
	
	$ScreenContainer/EnemyKilled/NbEnemies.text = "%d / %d" % [level.killedEnemies, level.nbEnemies]
	if level.killedEnemies == level.nbEnemies:
		$ScreenContainer/KillNote.text = "BLOODSHED"
		$ScreenContainer/TimeText/TimeText.text = "CARNAGE carried out in"
	elif level.killedEnemies == 0:
		$ScreenContainer/KillNote.text = "TRUE SHADOW"
		$ScreenContainer/TimeText/TimeText.text = "INFILTRATION completed smoothly in"
	else:
		$ScreenContainer/KillNote.text = "BOTCHED WORK"
		$ScreenContainer/TimeText/TimeText.text = "Managed to sneak in in"
		
	$ScreenContainer/TimeText/Time.text = "%02d:%02d" % [int(level.time_spent / 60), int(int(level.time_spent) % 60)]

var callback: Callable
func addCallback(newCallback: Callable):
	callback = newCallback

func animationFinished():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($ScreenContainer, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
	
	callback.call()

var animationTween: Tween
func prepareNodeAndAnimation(toAnimate: Control, show: bool = true, animationTime: float = 0.5):
	toAnimate.modulate.a = 0.0
	if show:
		animationTween.tween_callback(func(): $AudioStreamPlayer.play())
		animationTween.tween_property(toAnimate, "modulate:a", 1.0, animationTime)

func createBlurTransition(transitionTime: float = 2.0):
	$BlurV/Renderer.material.set_shader_parameter("strength", 0.0)
	$BlurH/Renderer.material.set_shader_parameter("strength", 0.0)
	animationTween.tween_property($BlurV/Renderer.material, "shader_parameter/strength", 1.0, transitionTime)
	animationTween.parallel().tween_property($BlurH/Renderer.material, "shader_parameter/strength", 1.0, transitionTime)

func startAnimation():
	if animationTween:
		animationTween.kill()
	
	animationTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Add the blur transition to the tween
	createBlurTransition()
	
	prepareNodeAndAnimation($ScreenContainer/TitleContainer)
	prepareNodeAndAnimation($ScreenContainer/RessourcesSection/MainRessource)

	for ressource in ressourceAnimationOrder:
		prepareNodeAndAnimation(ressource)

	prepareNodeAndAnimation($ScreenContainer/EnemyKilled, not escape)
	prepareNodeAndAnimation($ScreenContainer/KillNote, not escape)
	prepareNodeAndAnimation($ScreenContainer/TimeText, not escape)
	
	#TODO: Get condition to show
	prepareNodeAndAnimation($ScreenContainer/Record, not escape)
	
	# Sleep time
	animationTween.tween_interval(2.0)
	animationTween.tween_callback(animationFinished)

# Called when the node enters the scene tree for the first time.
func _ready():
	startAnimation()
	$ScreenContainer.modulate.a = 1.0
