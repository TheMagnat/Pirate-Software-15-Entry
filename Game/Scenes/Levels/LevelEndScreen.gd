class_name LevelEndScreen extends CanvasLayer


var ressourceAnimationOrder = []
func fillScreen(level: Level):
	$ScreenContainer/TitleContainer/LevelName.text = level.level_name
	$ScreenContainer/RessourcesSection/MainRessource/MainRessource.text = level.main_ressource
	
	for ressource in level.contained_resources:
		var count: int = level.finish_resources[ressource]
		var total: int = level.contained_resources[ressource]
		
		# Create the ressource control
		var ressourceLabel := Label.new()
		ressourceLabel.text = ressource
		
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
func prepareNodeAndAnimation(toAnimate: Control, animationTime: float = 0.5):
	toAnimate.modulate.a = 0.0
	animationTween.tween_property(toAnimate, "modulate:a", 1.0, animationTime)

func startAnimation():
	if animationTween:
		animationTween.kill()
		
	animationTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	prepareNodeAndAnimation($ScreenContainer/TitleContainer)
	prepareNodeAndAnimation($ScreenContainer/RessourcesSection/MainRessource)

	for ressource in ressourceAnimationOrder:
		prepareNodeAndAnimation(ressource)

	prepareNodeAndAnimation($ScreenContainer/EnemyKilled)
	prepareNodeAndAnimation($ScreenContainer/KillNote)
	prepareNodeAndAnimation($ScreenContainer/TimeText)
	
	#TODO: Get condition to show
	prepareNodeAndAnimation($ScreenContainer/Record)
	
	# Sleep time
	animationTween.tween_interval(2.0)
	animationTween.tween_callback(animationFinished)

# Called when the node enters the scene tree for the first time.
func _ready():
	startAnimation()
	$ScreenContainer.modulate.a = 1.0
