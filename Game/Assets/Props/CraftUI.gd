extends Control

@export var RecipeIndex : int
@export var RecipeLabel: String
@export var Resources: Dictionary

var _label_settings = preload("res://Ressources/LabelSettings.tres")

signal craft_pressed(recipe_index: int)

func _ready():
	$"Panel/VBoxContainer/Label".text = RecipeLabel
	for key in Resources:
		var resourceContainer = VBoxContainer.new()
		var resourceLabel = Label.new()
		resourceLabel.name = key
		resourceLabel.text = key
		resourceLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		resourceLabel.label_settings = _label_settings
		var countLabel = Label.new()
		countLabel.name = "Count"
		countLabel.text = str(Resources[key])
		countLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		countLabel.label_settings = _label_settings
		resourceContainer.add_child(resourceLabel)
		resourceContainer.add_child(countLabel)
		$Panel/VBoxContainer.add_child(resourceContainer)

func _on_button_pressed():
	craft_pressed.emit(RecipeIndex)

func updateResources(updated: Dictionary):
	pass
