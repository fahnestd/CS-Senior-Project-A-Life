extends Area2D

@onready var NodeObject = get_parent()
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureBehavior = Creature.get_node("Behavior")

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(other_area):
	if other_area.get_parent().Creature != Creature:
		if other_area.name != "Eye":
			if not CreatureBehavior.visible_nodes.has(other_area):
				CreatureBehavior.visible_nodes[other_area.get_parent()] = null

func _on_area_exited(other_area):
	if other_area.get_parent().Creature != Creature:
		if other_area.name != "Eye":
			CreatureBehavior.visible_nodes.erase(other_area.get_parent())
