extends Spell

const CLOAK_TIME_PER_LEVEL := 2.0
const CLOAK_TIME := 3.0 - CLOAK_TIME_PER_LEVEL

#func tryActivateSpell():
	#if player.cloaking:
		#player.uncloak()
	#else:
		#super()

func activateSpell():
	player.cloak()
	var t := get_tree().create_timer(CLOAK_TIME + CLOAK_TIME_PER_LEVEL * Save.unlockable[Player.ShadeCloak])
	t.timeout.connect(player.uncloak)
