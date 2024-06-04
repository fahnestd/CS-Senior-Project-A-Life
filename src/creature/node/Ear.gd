extends Area2D

@onready var NodeObject = get_parent()
@onready var Status = NodeObject.get_node("Status")
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureBehavior = Creature.get_node("Behavior")
@onready var Collision = get_node("Collision")

func _ready():
	Collision.scale.x = Status.genes["effectiveness"]
	Collision.scale.y = Status.genes["effectiveness"]
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# Ears are less effective at locating far away nodes
# Called in Behavior so that perceived position changes every time a behavior is chosen
func add_random_position_variance(pos):
	var pos_diff = pos - NodeObject.global_position
	var perceived_position = pos
	perceived_position += Vector2(randf_range(-pos_diff.x, pos_diff.x), randf_range(-pos_diff.y, pos_diff.y)) * 0.5 / Status.genes["effectiveness"]
	return perceived_position

func _on_area_entered(other_area):
	if Status.integrity != 0:
		if other_area.name == "Food" or other_area.get_parent().Creature != Creature:
			if other_area.name != "Eye" and other_area.name != "Ear":
				var other_node = other_area.get_parent()
				CreatureBehavior.audible_nodes[other_node] = [other_node.global_position, self]

func _on_area_exited(other_area):
	if other_area.name == "Food" or other_area.get_parent().Creature != Creature:
		if other_area.name != "Eye" and other_area.name != "Ear":
			var other_node = other_area.get_parent()
			CreatureBehavior.audible_nodes.erase(other_node)
