extends RigidBody3D

const DEPLOYABLE_WALL_LIFETIME := 5 # seconds

enum ProjectileState { INITIAL, MOVING, STOPPED }

var state: ProjectileState

# Called when the node enters the scene tree for the first time.
func _ready():
	state = ProjectileState.INITIAL
	get_tree().create_timer(DEPLOYABLE_WALL_LIFETIME).timeout.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position.y != 0:
		global_position.y = 0
	
	if state == ProjectileState.INITIAL and linear_velocity:
		state = ProjectileState.MOVING
	
	if state == ProjectileState.MOVING and not linear_velocity:
		state = ProjectileState.STOPPED
		freeze = true;
