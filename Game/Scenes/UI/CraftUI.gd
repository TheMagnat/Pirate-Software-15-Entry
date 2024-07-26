extends Control

@export var RecipeIndex : int
@export var RecipeLabel: String
@export var Resources: Dictionary

const LABEL_SETTINGS := preload("res://Ressources/LabelSettings.tres")

func make_label(n: String, text: String, alignment: HorizontalAlignment, container: HBoxContainer) -> Label:
	var label := Label.new()
	label.name = n
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = alignment
	label.label_settings = LABEL_SETTINGS
	container.add_child(label)
	return label

var _displayedResources = {}

signal craft_pressed(recipe_index: int)
signal turn_page(direction: int)

func _ready():
	$Panel/Craft.pressed.connect(_on_craft_pressed)
	
	$"Panel/VBoxContainer/Label".text = RecipeLabel
	for key in Resources:
		var resourceContainer = HBoxContainer.new()
		resourceContainer.anchors_preset = PRESET_TOP_WIDE
		make_label("Resource", key, HORIZONTAL_ALIGNMENT_LEFT, resourceContainer)
		var inventoryCountLabel := make_label("InventoryCount", str(Save.resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
		make_label("Count", "/ " + str(Resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
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
