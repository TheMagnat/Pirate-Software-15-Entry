extends Node3D


var inPlayer: Player = null
signal actioned(player: Player)

func _ready():
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	$Area3D.body_exited.connect(_on_area_3d_body_exited)

func playerEnteredArea(playerBody: Player):
	inPlayer = playerBody
	inPlayer.setActionPossible(true)
	
func playerExitedArea(_playerBody: Player):
	inPlayer.setActionPossible(false)
	inPlayer = null

func _input(event):
	if inPlayer and event.is_action_pressed("interact"):
		actioned.emit(inPlayer)

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		playerEnteredArea(body)

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		playerExitedArea(body)
