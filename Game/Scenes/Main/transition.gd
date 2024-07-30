extends CanvasLayer


func start(c: Callable, anim_in := "in", anim_out := "out"):
	$AnimationPlayer.play(anim_in)
	await $AnimationPlayer.animation_finished
	
	c.call()
	$AnimationPlayer.play(anim_out)
