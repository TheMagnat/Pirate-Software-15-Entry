extends Control

var index : int
var label: String
var texture: Texture2D
var description: String
var resources: Dictionary
var artefacts: Array
var max_level: int

const LABEL_SETTINGS := preload("res://Ressources/LabelSettings.tres")

func make_label(n: String, text: String, alignment: HorizontalAlignment, container: HBoxContainer) -> Label:
	var lbl := Label.new()
	lbl.name = n
	lbl.text = text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = alignment
	lbl.label_settings = LABEL_SETTINGS
	container.add_child(lbl)
	return lbl

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
	
	$Panel/VBoxContainer/Sprite2D.texture = texture
	if texture != null:
		$Panel/VBoxContainer/Sprite2D.scale = Vector2(128.0, 128.0) / texture.get_height()
	
	$Panel/VBoxContainer/Description.material = $Panel/VBoxContainer/Description.material.duplicate()
	$Panel/VBoxContainer/Sprite2D.material = $Panel/VBoxContainer/Sprite2D.material.duplicate()
	$Panel/VBoxContainer/Description.mouse_entered.connect(show_description.bind(true))
	$Panel/VBoxContainer/Description.mouse_exited.connect(show_description.bind(false))
	$Panel/VBoxContainer/Description.text = description
	$Panel/VBoxContainer/Description.modulate.a = 0.0
	
	$"Panel/VBoxContainer/Label".text = label
	for key in resources:
		var resourceContainer := HBoxContainer.new()
		resourceContainer.anchors_preset = PRESET_TOP_WIDE
		make_label("Resource", key.capitalize(), HORIZONTAL_ALIGNMENT_LEFT, resourceContainer)
		var inventoryCountLabel := make_label("InventoryCount", str(Save.resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
		make_label("Count", "/ " + str(resources[key]), HORIZONTAL_ALIGNMENT_RIGHT, resourceContainer)
		$Panel/VBoxContainer.add_child(resourceContainer)
		_displayedResources[key] = inventoryCountLabel
	
	$Panel/Level.visible = Save.unlockable[index] != 0
	$Panel/Level.text = "Level " + str(Save.unlockable[index])
	
	$Panel/FindSomething.visible = false
	for artefact in artefacts:
		if Save.resources[artefact] < 1 && Save.unlockable[index] < 1:
			$Panel/Craft.visible = false
			$Panel/FindSomething.visible = true
			$Panel/FindSomething.text = findsomethingtext[index]
			break
	
	if max_level != 0 && Save.unlockable[index] >= max_level:
		$Panel/Craft.queue_free()
	
	if(index % 2 == 0):
		$Panel/NextPage.queue_free()
	else:
		$Panel/PreviousPage.queue_free()

func updateResources():
	for key in _displayedResources:
		_displayedResources[key].text = str(Save.resources[key])

func _on_craft_pressed():
	craft_pressed.emit(index, max_level, self)

func craft_resources_limit():
	$Panel/NotEnough/AnimationPlayer.play("warning")

func craft_max_level():
	$Panel/Craft.queue_free()

func craft_success():
	$Panel/Level.visible = true
	$Panel/Level.text = "Level " + str(Save.unlockable[index])
	$Brew.play()

var desc_tween: Tween
func show_description(s: bool):
	if desc_tween: desc_tween.kill()
	desc_tween = create_tween().bind_node(self).set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	desc_tween.tween_property($Panel/VBoxContainer/Description, "modulate:a", 1.0 if s else 0.0, 0.5)
	desc_tween.tween_method(func(x: float): $Panel/VBoxContainer/Sprite2D.material.set_shader_parameter("transparency", x), $Panel/VBoxContainer/Sprite2D.material.get_shader_parameter("transparency"), 0.2 if s else 1.0, 0.5)
	desc_tween.tween_method(func(x: float): $Panel/VBoxContainer/Description.material.set_shader_parameter("displacement", x), $Panel/VBoxContainer/Description.material.get_shader_parameter("displacement"), 2.0 if s else 100.0, 0.5)

func _on_next_page_pressed():
	turn_page.emit(1)

func _on_previous_page_pressed():
	turn_page.emit(-1)
