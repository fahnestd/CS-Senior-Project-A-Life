extends Node

var FoodScene = preload("res://src/scenes/food.tscn")
@onready var World = get_node("../World")
@onready var FoodNodes = get_node("../FoodNodes")

func _ready():
	# This gives 11 - the minimum of the slider (10) * 40 which means the range is 40-400 starting food
	var food_to_generate = (11 - SimulationParameters.FoodScarcity) * 40
	for i in range(food_to_generate):
		var food_node = FoodScene.instantiate()
		food_node.global_position = World.GetRandomSpawnCoordinates() * World.GetTileSize()
		FoodNodes.add_child(food_node)
