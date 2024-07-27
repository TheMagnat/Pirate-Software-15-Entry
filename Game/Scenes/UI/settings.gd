extends VBoxContainer

signal back

func _ready():
	set_fullscreen()
	$Volume/HSlider.value = Save.config.volume
	
	$Fullscreen.pressed.connect(fullscreen)
	$Volume/HSlider.value_changed.connect(volume)
	$Back.pressed.connect(func(): back.emit())

func set_fullscreen():
	$Fullscreen.text = "Windowed" if Save.config.fullscreen else "Fullscreen"

func fullscreen():
	Save.set_fullscreen(!Save.config.fullscreen)
	set_fullscreen()

func volume(v: float):
	Save.set_volume(v)
