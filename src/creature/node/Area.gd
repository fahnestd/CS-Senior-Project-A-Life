extends Area2D

@onready var NodeObject = get_parent()
@onready var NodeStatus = NodeObject.get_node("Status")

var position_shift = Vector2(0, 0)
var colliding_areas = {}

func _on_area_entered(area):
	colliding_areas[area] = null

func _on_area_exited(area):
	colliding_areas.erase(area)

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _physics_process(_delta):
	for area in colliding_areas.keys():
		var other_object = area.get_parent()
		var other_status = other_object.get_node("Status")
		var other_size = other_status.genes["size"]
		
		var distance_to = global_position.distance_to(other_object.global_position)
		var size_allowance = (NodeStatus.genes["size"] + other_size) * 0.5
		if distance_to < size_allowance:
			var direction = (global_position - other_object.global_position).normalized()
			var overlap = size_allowance - distance_to
			position_shift += direction * overlap * 0.5
	if position_shift != Vector2(0, 0):
		NodeObject.move(position_shift, true)
		position_shift = Vector2(0, 0)
