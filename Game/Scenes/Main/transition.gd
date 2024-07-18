extends CanvasLayer


func start(c: Callable):
	$AnimationPlayer.play("in")
	await $AnimationPlayer.animation_finished
	
	c.call()
	$AnimationPlayer.play("out")
