extends Node

@onready var Area = get_node("../Area")
@onready var Genetics = get_node("/root/MainScene/Genetics")
@onready var NodeObject = get_parent()
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureStatus = Creature.get_node("Status")

func _ready():
	Area.area_entered.connect(_reproduce)

var last_area_1 = null
var last_area_2 = null
func _reproduce(other_area):
	if CreatureStatus.reproduction_cooldown_progress == 0:
		var other_reproduction = get_reproduction_area(other_area)
		if other_reproduction and Creature != other_reproduction.Creature:
			if other_reproduction.Creature.Status.reproduction_cooldown_progress == 0:
				# Reproduction collisions create two signals (one from each creature)
				# Ensures only one signal is received
				if last_area_1 != Area or last_area_2 != other_area:
					Genetics.create_offspring(Creature, other_reproduction.Creature)
					CreatureStatus.reset_reproduction_cooldown()
					other_reproduction.Creature.Status.reset_reproduction_cooldown()
					last_area_1 = null
					last_area_2 = null
					other_reproduction.last_area_1 = other_area
					other_reproduction.last_area_2 = Area

# Returns null if the colliding area is not a reproduction area
func get_reproduction_area(area):
	var area_parent = area.get_parent()
	if area_parent.has_node("Reproduction"):
		return area_parent.get_node("Reproduction")
	else:
		return null
