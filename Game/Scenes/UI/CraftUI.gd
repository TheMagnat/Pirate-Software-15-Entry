extends Control

@export var RecipeIndex : int
@export var RecipeLabel: String
@export var Resources: Dictionary

var _label_settings = preload("res://Ressources/LabelSettings.tres")
var _displayedResources = {}

signal craft_pressed(recipe_index: int)
signal turn_page(direction: int)

func _ready():
	$Panel/Craft.pressed.connect(_on_craft_pressed)
	
	$"Panel/VBoxContainer/Label".text = RecipeLabel
	for key in Resources:
		var resourceContainer = HBoxContainer.new()
		resourceContainer.anchors_preset = PRESET_TOP_WIDE
		var resourceLabel = Label.new()
		resourceLabel.name = "Resource"
		resourceLabel.text = key
		resourceLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		resourceLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		resourceLabel.label_settings = _label_settings
		var inventoryCountLabel = Label.new()
		inventoryCountLabel.name = "InventoryCount"
		inventoryCountLabel.text = str(Save.resources[key])
		inventoryCountLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inventoryCountLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		inventoryCountLabel.label_settings = _label_settings
		var recipeCountLabel = Label.new()
		recipeCountLabel.name = "Count"
		recipeCountLabel.text = "/ " + str(Resources[key])
		recipeCountLabel.size_flags_horizontal = Control.SIZE_FILL
		recipeCountLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		recipeCountLabel.label_settings = _label_settings
		resourceContainer.add_child(resourceLabel)
		resourceContainer.add_child(inventoryCountLabel)
		resourceContainer.add_child(recipeCountLabel)
		$Panel/VBoxContainer.add_child(resourceContainer)
		_displayedResources[key] = inventoryCountLabel
	if(RecipeIndex % 2 == 0):
		$Panel/NextPage.queue_free()
	else:
		$Panel/PreviousPage.queue_free()

func updateResources():
	for key in _displayedResources:
		_displayedResources[key].text = str(Save.resources[key])

func _on_craft_pressed():
	craft_pressed.emit(RecipeIndex)
	$Brew.play()

func _on_next_page_pressed():
	turn_page.emit(1)
	$PageTurn.play()

func _on_previous_page_pressed():
	turn_page.emit(-1)
	$PageTurn.play()
