extends RigidBody3D


func _integrate_forces(state):
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		#var local_collision_pos: Vector3 = state.get_contact_local_position(0)
		#if to_local(local_collision_pos).y > 1.0:
			#broke()
		var strength: Vector3 = state.get_contact_impulse(0)
		if strength.length() > 1.0:
			$HitPlayer.play()
#
#func broke():
	#queue_free()
