extends Control


func _process(_delta):
	$Label.set_text("FPS %d" % Engine.get_frames_per_second())
