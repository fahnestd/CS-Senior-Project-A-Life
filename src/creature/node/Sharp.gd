extends Node

@onready var Area = get_node("../Area")
@onready var NodeObject = get_parent()
@onready var Status = NodeObject.get_node("Status")
@onready var Creature = NodeObject.get_parent().Creature

func _ready():
	Area.area_entered.connect(_stab)

func _stab(other_area):
	if Status.integrity != 0:
		if other_area.name == "Area":
			if other_area.NodeObject.Creature != Creature:
				other_area.NodeStatus.get_hurt(10 * Status.genes["effectiveness"])
