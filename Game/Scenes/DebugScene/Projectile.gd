extends RigidBody3D

@export var suspectLevel: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when the item hit the ground
func explode():
	queue_free()

func _on_body_entered(body):
	for target in $Area3D.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			target.suspiciousActivity(global_position, suspectLevel)
	
	if not body.is_in_group("Enemy") and not body.is_in_group("Projectile"):
		explode()
	
