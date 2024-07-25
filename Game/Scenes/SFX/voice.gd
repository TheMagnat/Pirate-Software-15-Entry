class_name Voice extends AudioStreamPlayer3D

@export var pitch_random := 0.25
@export var voice_speed_min := 0.1
@export var voice_speed_max := 0.3

@onready var base_pitch := pitch_scale
@onready var timer := $Timer

func _talking():
	word()
	timer.wait_time = randf_range(voice_speed_min, voice_speed_max)
	timer.start()

func word():
	pitch_scale = base_pitch + randf_range(-pitch_random, pitch_random)
	play()
	
func talk():
	if !timer.timeout.is_connected(_talking):
		timer.timeout.connect(_talking)
		_talking()

func shutup():
	if timer.timeout.is_connected(_talking):
		timer.timeout.disconnect(_talking)
