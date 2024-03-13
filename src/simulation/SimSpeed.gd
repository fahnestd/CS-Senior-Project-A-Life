extends Label

func _on_one_time_button_pressed():
	Engine.time_scale  = 1.0
	get_node("SimLabel").text = "1"


func _on_two_time_button_pressed():
	Engine.time_scale  = 2.0
	get_node("SimLabel").text = "2"


func _on_four_time_button_pressed():
	Engine.time_scale  = 4.0
	get_node("SimLabel").text = "4"
