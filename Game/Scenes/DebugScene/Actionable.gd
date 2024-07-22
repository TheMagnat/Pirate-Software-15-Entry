extends Node3D


var inPlayer: Player = null
signal actioned

func playerEnteredArea(playerBody: Player):
	inPlayer = playerBody
	inPlayer.setActionPossible(true)
	
func playerExitedArea(playerBody: Player):
	inPlayer.setActionPossible(false)
	inPlayer = null

func _input(event):
	if inPlayer and event.is_action_pressed("interact"):
		actioned.emit()

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player"):
		playerEnteredArea(body)

func _on_area_3d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player"):
		playerExitedArea(body)
