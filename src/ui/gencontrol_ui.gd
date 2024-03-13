extends Label

func _on_genetics_next_generation():
	var gen = int(get_node("GenNumLabel").text)
	get_node("GenNumLabel").text = str(gen + 1)
