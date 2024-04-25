# The Zookeeper is responsible for introducing creatures to the environment.
extends Node

var creature_limit = 30

var CreatureScene = preload("res://src/scenes/creature.tscn")
@onready var World = get_node("../World")
@onready var Genetics = get_node("../Genetics")
@onready var Creatures = get_node("../Creatures")

# Generate starter creatures
func _ready():
	var creatures_to_spawn = SimulationParameters.CreatureDensity * 5
	for i in range(creatures_to_spawn):
		create_creature(World.GetRandomSpawnCoordinates() * World.GetTileSize(), World.GetRandomStartingAngle(), null, null)

# Generate a new creature
func create_creature(pos, rot, physical_genome, behavioral_genome):
	if Creatures.get_child_count() < creature_limit:
		var creature = CreatureScene.instantiate()
		var body = creature.get_node('Body')

		# Rotate and place the creature to start position
		creature.global_position = pos
		body.rotation_degrees = rot
		if physical_genome:
			creature.get_node("Status").physical_genome = physical_genome

		if behavioral_genome:
			creature.get_node("Status").behavioral_genome = behavioral_genome

		if Creatures.get_child_count() < 3:
			creature.get_node("Status").reproduction_cooldown_progress = 0

		# Add the creature to the mainscene node.
		Creatures.add_child.call_deferred(creature)

func update_new_creature(creature, physical_genome):
	creature.Status.physical_genome = physical_genome

# TODO: Based on simulation initialization parameters:
# total_num_creatures
# starting_location
# min_creature_density (if a new creature would be too far from any existing creatures, choose a new location)
# max_creature_density (if a new creature would be too close to too many existing creatures, choose a new location)
# Generate the initial creatures
