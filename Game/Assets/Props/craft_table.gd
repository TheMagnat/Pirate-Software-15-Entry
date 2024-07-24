extends Node

@export var inventory: Dictionary

var ui_scene = preload("res://Scenes/UI/craft_ui.tscn")
var currentPage = 0
var recipes = {
	0: 
	{
		"displayName": "Elixir of Cleverness",
		"ingredients" : 
		{
			"resource1": 1,
			"resource2": 2,
			"resource3": 3,
		},
	},
	1: 
	{
		"displayName": "Wall",
		"ingredients" : 
		{
			"resource1": 1,
			"resource2": 2,
		},
	},
	2: 
	{
		"displayName": "Shade Cloak",
		"ingredients" : 
		{
			"resource1": 1,
			"resource2": 2,
			"resource3": 3,
			"resource4": 4,
		},
	},
	3: 
	{
		"displayName": "Energy Drink",
		"ingredients" : 
		{
			"resource1": 3,
		},
	}
}

func _ready():
	_create_page(recipes[0], 0)

func next_page():
	pass
	
func try_craft(index: int):
	var ingredients = recipes[index].ingredients
	for key in ingredients:
		if (inventory[key] < ingredients[key]):
			return false
	for key in ingredients:
		inventory[key] -= ingredients[key]
	return true

func _create_page(recipe, recipeIndex: int):
	var sceneInstance = ui_scene.instantiate()
	sceneInstance.name = "CraftUI"
	sceneInstance.RecipeIndex = recipeIndex
	sceneInstance.RecipeLabel = recipe.displayName
	sceneInstance.Resources = recipe.ingredients
	sceneInstance.craft_pressed.connect(try_craft)
	$"../SubViewport/CraftUI".queue_free()
	$"../SubViewport".add_child(sceneInstance)
