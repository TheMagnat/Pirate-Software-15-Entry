class_name SpawnInformation


var position: Vector3
var cameraAngle: float
var resources: Dictionary
var collected: PackedStringArray

func _init(positionP: Vector3, cameraAngleP: float, resourcesP: Dictionary, collectedP: PackedStringArray) -> void:
	position = positionP
	cameraAngle = cameraAngleP
	resources = resourcesP.duplicate()
	collected = collectedP.duplicate()
