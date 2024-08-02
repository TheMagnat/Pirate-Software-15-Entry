extends VBoxContainer

signal back

func _ready():
	set_fullscreen()
	set_camera()
	$Volume/HSlider.value = Save.config.volume
	
	$Fullscreen.pressed.connect(fullscreen)
	$Camera.pressed.connect(camera)
	$Volume/HSlider.value_changed.connect(volume)
	$Back.pressed.connect(func(): back.emit())

func set_fullscreen():
	$Fullscreen.text = "Windowed" if Save.config.fullscreen else "Fullscreen"

func set_camera():
	$Camera.text = "Camera: Inverted" if Save.config.invert > 0.0 else "Camera: Normal"


func fullscreen():
	Save.set_fullscreen(!Save.config.fullscreen)
	set_fullscreen()

func camera():
	Save.config.invert = -Save.config.invert
	set_camera()

func volume(v: float):
	Save.set_volume(v)
