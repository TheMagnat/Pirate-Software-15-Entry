extends Spell

const CLOAK_TIME_PER_LEVEL := 2.0
const CLOAK_TIME := 2.0 - CLOAK_TIME_PER_LEVEL

#func tryActivateSpell():
	#if player.cloaking:
		#player.uncloak()
	#else:
		#super()

func activateSpell():
	var level := maxi(1, Save.unlockable[Player.ShadeCloak])
	player.cloak()
	var t := get_tree().create_timer(CLOAK_TIME + CLOAK_TIME_PER_LEVEL * level)
	t.timeout.connect(player.uncloak)
