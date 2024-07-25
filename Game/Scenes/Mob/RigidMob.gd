extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _integrate_forces(state):
	#if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		#var local_collision_pos: Vector3 = state.get_contact_local_position(0)
		#if to_local(local_collision_pos).y > 1.0:
			#broke()
#
#func broke():
	#queue_free()


func _on_body_entered(body):
	pass
