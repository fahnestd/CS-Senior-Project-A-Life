extends Control

var scene = preload("res://src/scenes/mainscene.tscn")

func _on_start_button_pressed():
	
	SimulationParameters.CreatureDensity = get_node("VBoxContainer/CreatureDensityUIBox/CreatureDensitySlider").value
	SimulationParameters.FoodScarcity = get_node("VBoxContainer/FoodScarcityUIBox/FoodScarcitySlider").value
	get_tree().change_scene_to_packed(scene)
