extends Node

### just for easier access
@onready var lobby := $Lobby
@onready var menu := $Menu
@onready var mystery1 := $Mystery1
@onready var action1 := $Action1
@onready var fairies := $Fairies

var current : AudioStreamPlayer = null
var base_volume := {}

func stop_playing():
	if current != null:
		var t_out := create_tween()
		t_out.tween_property(current, "volume_db", -20, 1.0)
		t_out.finished.connect(current.stop)

func play(stream: AudioStreamPlayer):
	if current == stream:
		return
	
	if !base_volume.has(stream):
		base_volume[stream] = stream.volume_db
	
	stop_playing()
	
	if current != null:
		stream.volume_db = -15 + base_volume[stream]
		var t_in := create_tween()
		t_in.tween_property(stream, "volume_db", base_volume[stream], 1.0)
	stream.volume_db = base_volume[stream]
	stream.play()
	current = stream

func stop():
	stop_playing()
	current = null
