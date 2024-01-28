extends Node2D

var creature_scene = preload("res://creature.tscn")
@onready var camera = get_node("Camera2D")
@onready var genetics = preload("res://src/genomes/Genetics.cs").new()

func physical_genome_to_int_arrays(genome):
	var node_ids = []
	var parent_ids = []
	var angles = []
	var sizes = []
	var joints = []

	for i in range(genome.size()):
		node_ids.append(i)
		var this_node = genome[str(i)]
		parent_ids.append(int(this_node["parent_id"]))
		angles.append(this_node["angle"])
		sizes.append(this_node["size"])
		if this_node["joint"] == "pivot":
			joints.append(1)
		else:
			joints.append(0)

	var return_array = [
		node_ids,
		parent_ids,
		angles,
		sizes,
		joints
	]

	return return_array

func int_arrays_to_physical_genome(arr):
	var return_dictionary = {}

	var node_ids = arr[0]
	var parent_ids = arr[1]
	var angles = arr[2]
	var sizes = arr[3]
	var joints = arr[4]

	for i in range(node_ids.size()):
		var this_node = {}

		if i < parent_ids.size():
			this_node["parent_id"] = str(parent_ids[i])
		else:
			this_node["parent_id"] = randi_range(0, node_ids.size() - 1)

		if i < angles.size():
			this_node["angle"] = angles[i]
		else:
			this_node["angle"] = randi_range(-180, 180)

		if i < sizes.size():
			this_node["size"] = sizes[i]
		else:
			this_node["size"] = sizes[randi_range(0, sizes.size() - 1)]

		if joints[i] == 1:
			this_node["joint"] = "pivot"
		else:
			this_node["joint"] = "fixed"

		return_dictionary[str(node_ids[i])] = this_node

	return return_dictionary

func create_offspring(creature_1, creature_2):
	var creature_1_physical_ints = physical_genome_to_int_arrays(creature_1.physical_genome)
	var creature_2_physical_ints = physical_genome_to_int_arrays(creature_2.physical_genome)

	var offspring_physical_ints = []
	for i in range(creature_1_physical_ints.size()):
		var trait_crossover = genetics.Crossover(creature_1_physical_ints[i], creature_2_physical_ints[i])
		var trait_mutation = genetics.Mutation(trait_crossover)
		offspring_physical_ints.append(trait_mutation)

	var offspring_pos = (creature_1.position + creature_2.position) / 2.0
	offspring_pos += Vector2(randi_range(-200, 200), randi_range(-200, 200))
	var offspring_rot = (creature_1.rotation + creature_2.rotation) / 2.0
	var offspring_physical_genome = int_arrays_to_physical_genome(offspring_physical_ints)
	create_creature(offspring_pos, offspring_rot, offspring_physical_genome)

func create_creature(pos, rot, physical_genome):
	var new_creature = creature_scene.instantiate()

	var behavioral_genome = {
		"0" = {
			"pattern" = [[["2", 40.0], ["3", -40.0], 1.0], [["2", -40.0], ["3", 40.0], 1.0]]
		},
		"1" = {
			"pattern" = [[["2", 40.0], 1.0], [["2", -40.0], 1.0]]
		},
		"2" = {
			"pattern" = [[["3", -40.0], 1.0], [["3", 40.0], 1.0]]
		},
		"3" = {
			"pattern" = [[1.0]]
		}
	}

	new_creature.physical_genome = physical_genome
	new_creature.behavioral_genome = behavioral_genome
	new_creature.position = pos
	new_creature.rotation = rot

	camera.reparent(new_creature)
	camera.position = Vector2(0, 0)
	self.get_parent().add_child.call_deferred(new_creature)

	creatures.append(new_creature)

var creatures = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var node_ids = [0, 1, 2, 3]
	var parent_ids = [0, 0, 0, 0]
	var angles = [0, 0, 120, -120]
	var sizes = [10, 10, 10, 10]
	var joints = [0, 0, 1, 1]
	var physical_genome = int_arrays_to_physical_genome([
		node_ids,
		parent_ids,
		angles,
		sizes,
		joints
	])
	create_creature(Vector2(0, 0), 0, physical_genome)
	create_creature(Vector2(200, 0), 180, physical_genome)

var timer = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= 5:
		create_offspring(creatures[randi_range(0, creatures.size() - 1)],
						 creatures[randi_range(0, creatures.size() - 1)])
		timer = 0
