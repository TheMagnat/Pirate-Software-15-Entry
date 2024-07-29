extends Label3D

# Render distance part
@export var player: Player
@export var distance: float = 5.0

var isShowing: bool = false
var fadingTween: Tween
func startFadeAnimation():
	if fadingTween:
		fadingTween.kill()
	
	fadingTween = create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	fadingTween.tween_property(self, "modulate:a", int(isShowing), 2.0)
	fadingTween.tween_property(self, "outline_modulate:a", int(isShowing), 2.0)

func _process(delta):
	var newIsShowing = false
	if player.global_position.distance_to(global_position) < distance:
		newIsShowing = true
	
	if isShowing != newIsShowing:
		isShowing = newIsShowing
		startFadeAnimation()

# Animation part
var initialScale: Vector3
var speedScale: float
var tween: Tween
func startAnimation():
	if tween: tween.kill()
	tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale:x", -0.1 * initialScale.x, 5.0 / speedScale).as_relative()
	tween.tween_property(self, "scale:x", 0.1 * initialScale.x, 5.0 / speedScale).as_relative()
	tween.tween_property(self, "scale:y", -0.1 * initialScale.y, 5.0 / speedScale).as_relative()
	tween.tween_property(self, "scale:y", 0.1 * initialScale.y, 5.0 / speedScale).as_relative()

func _ready():
	# Start hidden
	modulate.a = 0.0
	outline_modulate.a = 0.0
	
	initialScale = scale
	speedScale = randf_range(1.0, 2.0)
	startAnimation()
