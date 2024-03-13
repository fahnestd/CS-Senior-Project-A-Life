extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass


func _on_food_h_slider_value_changed(value):
	get_node("FoodPercentLabel").text = str(value * 100.0) + "%"
	# Add additional logic for actually changing food availability
