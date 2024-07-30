class_name LevelEndScreen extends CanvasLayer

const ESCAPE_TEXTS := [
	"I escaped from %s",
	"I ran away from %s",
	"I came back from %s",
	"%s was no good, I left",
	"I left %s",
]

const FINISH_TEXTS := [
	"%s wasn't as dangerous as I thought",
	"I went through %s smoothly",
	"I triumphed over %s",
	"%s: DONE!!",
	"%s was easy in the end",
]

const MAIN_RESSOURCE_TEXTS := [
	"I could even lay hands on a ",
	"I could borrow a ",
	"I found the ",
	"I found what I came for: the "
]

const NEW_LEVEL_TEXT := [
	"I found another place to visit...",
	"I found a way to my next location",
	"A map I found told me where to go next",
	"There's a new location I need to go to",
	"I found a new location to go to"
]

var escape := false
var new_record := false
var opened_level := false
var no_ressources := true

var ressourceAnimationOrder = []
func fillScreen(level: Level, escapeParam: bool = false):
	escape = escapeParam
	if escape:
		$ScreenContainer/Level.text = ESCAPE_TEXTS.pick_random() % level.level_name
	else:
		$ScreenContainer/Level.text = FINISH_TEXTS.pick_random() % level.level_name
		$ScreenContainer/RessourcesSection/MainRessource/Text.text = MAIN_RESSOURCE_TEXTS.pick_random()
		$ScreenContainer/RessourcesSection/MainRessource/Name.text = level.main_ressource.capitalize()
	
	var label_settings : LabelSettings = $ScreenContainer/Level.label_settings.duplicate()
	label_settings.font_size *= 0.75
	
	no_ressources = true
	for ressource in level.contained_resources:
		var count: int = level.finish_resources[ressource]
		var total: int = level.contained_resources[ressource]
		no_ressources = no_ressources && count == 0
		
		# Create the ressource control
		var ressourceLabel := Label.new()
		ressourceLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ressourceLabel.text = ressource.capitalize()
		ressourceLabel.label_settings = label_settings
		
		var margin := MarginContainer.new()
		margin.custom_minimum_size.x = 16
		
		var nbRessource := Label.new()
		nbRessource.text = "%d / %d" % [count, total]
		nbRessource.label_settings = label_settings
		
		var hBoxContainer := HBoxContainer.new()
		hBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		hBoxContainer.add_child(ressourceLabel)
		hBoxContainer.add_child(margin)
		hBoxContainer.add_child(nbRessource)
		
		$ScreenContainer/RessourcesSection.add_child(hBoxContainer)
		
		ressourceAnimationOrder.push_back(hBoxContainer)
	
	$ScreenContainer/RessourcesSection/IAlsoFound.text = "I could have found:" if no_ressources else "I also found:"
	
	$ScreenContainer/EnemyKilled/NbEnemies.text = "%d / %d" % [level.killedEnemies, level.nbEnemies]
	if level.killedEnemies == 0:
		$ScreenContainer/KillNote.text = "TRUE SHADOW"
		$ScreenContainer/KillNote.modulate = Color(0.5, 0.0, 1.0)
		$ScreenContainer/TimeText/TimeText.text = "INFILTRATION completed smoothly in"
	elif level.killedEnemies == level.nbEnemies:
		$ScreenContainer/KillNote.text = "BLOODSHED"
		$ScreenContainer/KillNote.modulate = Color(1.0, 0.0, 0.0)
		$ScreenContainer/TimeText/TimeText.text = "CARNAGE carried out in"
	else:
		$ScreenContainer/KillNote.text = "BOTCHED WORK"
		$ScreenContainer/KillNote.modulate = Color(0.2, 0.1, 0.0)
		$ScreenContainer/TimeText/TimeText.text = "Managed to sneak in in"
	
	$ScreenContainer/TimeText/Time.text = "%02d:%02d" % [int(level.time_spent / 60), int(int(level.time_spent) % 60)]
	$ScreenContainer/OpenedLevel.text = NEW_LEVEL_TEXT.pick_random()

var callback: Callable
func addCallback(newCallback: Callable):
	callback = newCallback

func animationFinished():
	if animationTween: animationTween.kill()
	
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

var sleep_time := false
func startAnimation():
	if animationTween:
		animationTween.kill()
	
	animationTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Add the blur transition to the tween
	createBlurTransition()
	
	prepareNodeAndAnimation($ScreenContainer/Level, true, 1.5)
	prepareNodeAndAnimation($ScreenContainer/RessourcesSection/MainRessource, not escape, 1.5)
	prepareNodeAndAnimation($ScreenContainer/RessourcesSection/IAlsoFound, true, 0.75)

	for i in ressourceAnimationOrder.size():
		prepareNodeAndAnimation(ressourceAnimationOrder[i], true, 1.0 if i == (ressourceAnimationOrder.size() - 1) else 0.25)

	prepareNodeAndAnimation($ScreenContainer/EnemyKilled, not escape)
	prepareNodeAndAnimation($ScreenContainer/KillNote, not escape)
	prepareNodeAndAnimation($ScreenContainer/TimeText, not escape, 0.75)
	
	#TODO: Get condition to show
	prepareNodeAndAnimation($ScreenContainer/Record, not escape and new_record, 1.5)
	prepareNodeAndAnimation($ScreenContainer/OpenedLevel, not escape and opened_level)
	
	# Sleep time
	animationTween.tween_callback(func(): sleep_time = true)
	animationTween.tween_interval(7.0)
	animationTween.tween_callback(animationFinished)

# Called when the node enters the scene tree for the first time.
func _ready():
	startAnimation()
	$ScreenContainer.modulate.a = 1.0

func _input(event):
	if event.is_action_pressed("interact") and sleep_time:
		animationFinished()
