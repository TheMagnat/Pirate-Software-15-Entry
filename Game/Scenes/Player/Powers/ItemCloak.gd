extends Spell

const CLOAK_TIME_PER_LEVEL := 2.0
const CLOAK_TIME := 2.0 - CLOAK_TIME_PER_LEVEL

#func tryActivateSpell():
	#if player.cloaking:
		#player.uncloak()
	#else:
		#super()

func _process(_delta):
	if aiming:
		showPreview()
	else:
		$Sprite3D.hide()

func showPreview():
	if on_cooldown:
		$Sprite3D.material_override.set_shader_parameter("can", 0.0)
	else:
		$Sprite3D.material_override.set_shader_parameter("can", 1.0)
	
	$Sprite3D.global_position = player.global_position + Vector3.UP * 0.3
	$Sprite3D.show()

func activateSpell():
	var level := maxi(1, Save.unlockable[Player.ShadeCloak])
	player.cloak()
	var t := get_tree().create_timer(CLOAK_TIME + CLOAK_TIME_PER_LEVEL * level)
	t.timeout.connect(player.uncloak)
	return true
