extends Panel


func _on_creature_generator_creature_info(info):
	var key = info.keys()
	get_node("CreatureInfoLabel").text = "Parent ID: " + str(info[key[0]]["parent_id"]) + "\n"
	get_node("CreatureInfoLabel").text +="Angle: " + str(info[key[0]]["angle"]) + "\n"
	get_node("CreatureInfoLabel").text +="Size: " + str(info[key[0]]["size"]) + "\n"
	get_node("CreatureInfoLabel").text +="Joint: " + str(info[key[0]]["joint"]) + "\n"
	
