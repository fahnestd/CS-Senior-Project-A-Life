extends Label


func _on_ui_update_timer_timeout():
	var nodes = get_node("../../../../FoodNodes").get_children()
	var totalEnergy = nodes.reduce(func (carry, food): return carry + food.energy_value, 0)
	
	text = "Total Energy: " + str(round(totalEnergy))
