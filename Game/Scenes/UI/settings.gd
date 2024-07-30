extends VBoxContainer

signal back

func _ready():
	set_fullscreen()
	$Volume/HSlider.value = Save.config.volume
	$CamSpeed/HSlider.value = Save.config.camera_speed
	
	$Fullscreen.pressed.connect(fullscreen)
	$Volume/HSlider.value_changed.connect(volume)
	$CamSpeed/HSlider.value_changed.connect(cam_speed)
	$Back.pressed.connect(func(): back.emit())

func set_fullscreen():
	$Fullscreen.text = "Windowed" if Save.config.fullscreen else "Fullscreen"

func fullscreen():
	Save.set_fullscreen(!Save.config.fullscreen)
	set_fullscreen()

func volume(v: float):
	Save.set_volume(v)

func cam_speed(v: float):
	Save.config.camera_speed = v
