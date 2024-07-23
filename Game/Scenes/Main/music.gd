extends Node

### just for easier access
@onready var lobby := $Lobby
@onready var menu := $Menu
@onready var mystery1 := $Mystery1
@onready var action1 := $Action1
@onready var fairies := $Fairies

var current : AudioStreamPlayer = null


func stop_playing():
	if current != null:
		var t_out := create_tween()
		t_out.tween_property(current, "volume_db", -20, 1.0)
		t_out.finished.connect(current.stop)

func play(stream: AudioStreamPlayer):
	if current == stream:
		return
	
	stop_playing()
	
	if current != null:
		stream.volume_db = -15
		var t_in := create_tween()
		t_in.tween_property(stream, "volume_db", 0.0, 1.0)
	stream.play()
	current = stream

func stop():
	stop_playing()
	current = null
