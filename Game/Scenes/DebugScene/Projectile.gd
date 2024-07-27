extends RigidBody3D

@export var suspectLevelOnGround: float = 1.0
@export var suspectLevelOnHit: float = 5.0


# Called when the item hit the ground
func explode():
	collision_mask = 0
	collision_layer = 0
	hide()
	$BreakPlayer.play()
	$BreakPlayer.finished.connect(func(): queue_free())

	
func _on_body_entered(body):
	for target in $Area3D.get_overlapping_bodies():
		if target.is_in_group("Enemy"):
			target.suspiciousActivity(global_position - Vector3(0, 0.5, 0), suspectLevelOnHit if body == target else suspectLevelOnGround)
			$HitPlayer.play()
	if not body.is_in_group("Enemy") and not body.is_in_group("Projectile"):
		explode()
	
