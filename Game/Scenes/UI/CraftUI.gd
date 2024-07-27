extends Control

var RecipeIndex : int
var RecipeLabel: String
var Resources: Dictionary
var Artefacts: Array

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

const findsomethingtext := [
	"I need to find something first...",
	"There's something missing...",
	"This needs something more...",
]

func _ready():
	$Panel/Craft.pressed.connect(_on_craft_pressed)
	
	$"Panel/VBoxContainer/Label".text = RecipeLabel
	for key in Resources:
		var resourceContainer := HBoxContainer.new()
		resourceContainer.anchors_preset = PRESET_TOP_WIDE
		make_label("Resource", key, HORIZONTAL_ALIGNMENT_LEFT, resourceContainer)
		var inventoryCountLabel := make_label("InventoryCount", str(Save.resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
		make_label("Count", "/ " + str(Resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
		$Panel/VBoxContainer.add_child(resourceContainer)
		_displayedResources[key] = inventoryCountLabel
	
	$Panel/FindSomething.visible = false
	for artefact in Artefacts:
		if Save.resources[artefact] < 1:
			$Panel/Craft.queue_free()
			$Panel/FindSomething.visible = true
			$Panel/FindSomething.text = findsomethingtext[RecipeIndex - 2]
			break
	
	if(RecipeIndex % 2 == 0):
		$Panel/NextPage.queue_free()
	else:
		$Panel/PreviousPage.queue_free()

func updateResources():
	for key in _displayedResources:
		_displayedResources[key].text = str(Save.resources[key])

func _on_craft_pressed():
	for resource in Resources:
		if Save.resources[resource] < Resources[resource]:
			$Panel/NotEnough/AnimationPlayer.play("warning")
			return
	
	craft_pressed.emit(RecipeIndex)
	$Brew.play()

func _on_next_page_pressed():
	turn_page.emit(1)

func _on_previous_page_pressed():
	turn_page.emit(-1)
