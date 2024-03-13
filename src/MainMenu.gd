extends Control

var scene = preload("res://src/scenes/mainscene.tscn")

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(scene)
