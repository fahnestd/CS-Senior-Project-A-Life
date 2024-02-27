# The Zookeeper is responsible for introducing creatures to the environment.
extends Node

var CreatureScene = preload("res://src/scenes/creature.tscn")
@onready var World = get_node("../World")
@onready var Genetics = get_node("../Genetics")
@onready var Creatures = get_node("../Creatures")

# Generate 2 starter creatures
func _ready():
	create_creature((World.GetSpawnCoordinates() - Vector2(10, 2)) * World.GetTileSize(), 0)
	create_creature((World.GetSpawnCoordinates() + Vector2(10, 2)) * World.GetTileSize(), 180)

# Generate a new creature
func create_creature(pos, rot):
	var creature = CreatureScene.instantiate()
	var body = creature.get_node('Body')

	# Rotate and place the creature to start position
	creature.global_position = pos
	body.rotation_degrees = rot

	# Add the creature to the mainscene node.
	Creatures.add_child.call_deferred(creature)

# TODO: Based on simulation initialization parameters:
# total_num_creatures
# starting_location
# min_creature_density (if a new creature would be too far from any existing creatures, choose a new location)
# max_creature_density (if a new creature would be too close to too many existing creatures, choose a new location)
# Generate the initial creatures
