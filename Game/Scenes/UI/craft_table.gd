extends Node

var ui_scene = preload("res://Scenes/UI/craft_ui.tscn")
var enabled = false
var leftScene: Control
var rightScene: Control
var currentPage = 0

func gen_recipe(n: String, ingredients: Dictionary, artefacts: Array):
	return {"displayName": n,
			"ingredients": ingredients,
			"artefacts": artefacts}

var recipes := [
	gen_recipe("Cat Walk",{ "plants": 3, "copper": 3 }, []),
	gen_recipe("Hardened Mixture",{ "plants": 2, "copper": 2, "gold": 2 }, []),
	gen_recipe("Potion of disturbance",{ "plants": 4, "copper": 1, "gold": 1, }, ["artefact1"]),
	gen_recipe("Vine Wall",{ "plants": 3, "copper": 2, "ruby": 2, }, ["artefact2"]),
	gen_recipe("Shade Cloak",{ "plants": 1, "copper": 1, "gold": 2, "ruby": 2, }, ["artefact3"])
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

func try_craft(index: int):
	if (enabled):
		var ingredients = recipes[index].ingredients
		for key in ingredients:
			if (Save.resources[key] < ingredients[key]):
				return
		for key in ingredients:
			Save.resources[key] -= ingredients[key]
		Save.unlockable[index] += 1
		craft_success.emit()

func _create_page(recipe, recipeIndex: int):
	var sceneInstance
	if(recipe == null || recipeIndex < 0):
		sceneInstance = Control.new()
	else:
		sceneInstance = ui_scene.instantiate()
		sceneInstance.name = "CraftUI"
		sceneInstance.RecipeIndex = recipeIndex
		sceneInstance.RecipeLabel = recipe.displayName
		sceneInstance.Resources = recipe.ingredients
		sceneInstance.Artefacts = recipe.artefacts
		sceneInstance.craft_pressed.connect(try_craft)
		sceneInstance.turn_page.connect(turn_page)
		craft_success.connect(sceneInstance.updateResources)
	return sceneInstance
