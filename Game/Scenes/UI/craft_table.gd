extends Node

var ui_scene = preload("res://Scenes/UI/craft_ui.tscn")
var enabled = false
var leftScene: Control
var rightScene: Control
var currentPage = 0

func gen_recipe(n: String, texture: String, description: String, ingredients: Dictionary, artefacts: Array, max_level := 0):
	return {"displayName": n,
			"texture": load(texture) if ResourceLoader.exists(texture) else null,
			"description": description,
			"ingredients": ingredients,
			"artefacts": artefacts,
			"max_level": max_level}

var recipes := [
	gen_recipe("Cat Walk", "", "Be a shadow so the night rewards you", { "night stone": 1, "amethyst": 2, "jade": 1, "sapphire": 1 }, []),
	gen_recipe("Hardened Mixture", "",  "Your enemies's life will empower you", { "blood stone": 1, "diamond": 2, "ruby": 2, "topaz": 1 }, []),
	gen_recipe("Potion of disturbance", "res://Assets/Textures/potion.png",  "Glass breaks, eyes look", { "diamond": 2, "sapphire": 2 }, ["artefact1"], 3),
	gen_recipe("Ivy Wall", "",  "From the ground, nature will raise", { "diamond": 1, "jade": 2, "topaz": 2, }, ["artefact2"], 3),
	gen_recipe("Shade Cloak", "",  "I am nothing but shadow in the light", { "amethyst": 3, "diamond": 1, "ruby": 2, "sapphire": 1 }, ["artefact3"], 3)
]

signal craft_success

func _ready():
	if(recipes[currentPage] != null):
		leftScene = _create_page(recipes[currentPage], currentPage)
		$"../LeftPage/SubViewPort".add_child(leftScene)
	if(recipes[currentPage + 1] != null):
		rightScene = _create_page(recipes[currentPage + 1], currentPage + 1)
		$"../RightPage/SubViewPort".add_child(rightScene)

func turn_page(direction: int):
	var target = currentPage + (2 * direction)
	if(target >= 0 && target < recipes.size()):
		$PageTurn.play()
		currentPage = target
		rightScene.queue_free()
		leftScene.queue_free()
		leftScene = _create_page(recipes[currentPage], currentPage)
		if(currentPage+1 < recipes.size()):
			rightScene = _create_page(recipes[currentPage+1], currentPage+1)
		else:
			rightScene = _create_page(null, -1)
		$"../LeftPage/SubViewPort".add_child(leftScene)
		$"../RightPage/SubViewPort".add_child(rightScene)

func try_craft(index: int, max_level: int, craft_page):
	if (enabled):
		var ingredients = recipes[index].ingredients
		for key in ingredients:
			if (Save.resources[key] < ingredients[key]):
				craft_page.craft_resources_limit()
				return
		for key in ingredients:
			Save.resources[key] -= ingredients[key]
		Save.unlockable[index] += 1
		
		craft_success.emit()
		craft_page.craft_success()
		
		if max_level != 0 && Save.unlockable[index] >= max_level:
			craft_page.craft_max_level()

func _create_page(recipe, recipeIndex: int):
	var sceneInstance
	if(recipe == null || recipeIndex < 0):
		sceneInstance = Control.new()
	else:
		sceneInstance = ui_scene.instantiate()
		sceneInstance.name = "CraftUI"
		sceneInstance.index = recipeIndex
		sceneInstance.label = recipe.displayName
		sceneInstance.texture = recipe.texture
		sceneInstance.description = recipe.description
		sceneInstance.resources = recipe.ingredients
		sceneInstance.artefacts = recipe.artefacts
		sceneInstance.max_level = recipe.max_level
		sceneInstance.craft_pressed.connect(try_craft)
		sceneInstance.turn_page.connect(turn_page)
		craft_success.connect(sceneInstance.updateResources)
	return sceneInstance
