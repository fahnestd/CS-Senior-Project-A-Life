extends Node

@onready var Area = get_node("../Area")
@onready var NodeObject = get_parent()
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureStatus = Creature.get_node("Status")

func _ready():
	Area.area_entered.connect(_bite)

func _bite(other_area):
	if other_area.name == "Food":
		CreatureStatus.energy += other_area.get_parent().consume(25)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
