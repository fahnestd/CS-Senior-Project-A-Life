extends Label

func _on_one_time_button_pressed():
	Engine.time_scale  = 1.0
	Engine.physics_ticks_per_second = 60
	get_node("SimLabel").text = "1"


func _on_two_time_button_pressed():
	Engine.time_scale = 2.0
	Engine.physics_ticks_per_second = 120
	get_node("SimLabel").text = "2"


func _on_four_time_button_pressed():
	Engine.time_scale  = 4.0
	Engine.physics_ticks_per_second = 240
	get_node("SimLabel").text = "4"
