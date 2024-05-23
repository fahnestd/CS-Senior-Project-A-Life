extends Node

@onready var Area = get_node("../Area")
@onready var NodeObject = get_parent()
@onready var Status = NodeObject.get_node("Status")
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureStatus = Creature.get_node("Status")

func _ready():
	Area.area_entered.connect(_bite)

func _bite(other_area):
	if Status.integrity != 0:
		if other_area.name == "Food":
			CreatureStatus.energy += other_area.get_parent().consume(25 * Status.genes["effectiveness"])
		elif other_area.name == "Area":
			if other_area.NodeObject.Creature != Creature:
				if other_area.NodeStatus.integrity == 0 and other_area.NodeStatus.consumed == false:
					CreatureStatus.energy += 25 * Status.genes["effectiveness"]
					other_area.NodeObject.get_consumed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
