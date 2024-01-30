extends Node2D

var creature_scene = preload("res://creature.tscn")
@onready var camera = get_node("Camera2D")

var mutation_chance = 10

func create_offspring(creature_1, creature_2):
	var trait_crossover = crossover({}, creature_1.physical_genome, creature_2.physical_genome)
	var trait_mutation = mutation(trait_crossover, trait_crossover.size(), mutation_chance, -50, 50)

	var offspring_pos = (creature_1.position + creature_2.position) / 2.0
	var offspring_rot = (creature_1.rotation + creature_2.rotation) / 2.0
	create_creature(offspring_pos, offspring_rot, trait_mutation)
	print("New Genome:")
	print(trait_mutation)
	print()

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
	new_creature.rotation_degrees = rot

	camera.reparent(new_creature)
	camera.position = Vector2(0, 0)
	self.get_parent().add_child.call_deferred(new_creature)

	creatures.append(new_creature)

# Checks each key value pair in both dict_1 and dict_2, constructing return_dict from the winning values
# If both values are dictionaries, recursively calls crossover, setting the key in return_dict to the returned value
# Otherwise, has a 50% chance to set the key in return_dict to either value
# If the other dict does not have the key, has a 50% chance to set it to the existing value or to not set the key
# dict_2's keys are checked by a recursive call at the end of the function
func crossover(return_dict, dict_1, dict_2):
	dict_1 = dict_1.duplicate(true)
	dict_2 = dict_2.duplicate(true)
	for key in dict_1.keys():
		if dict_2.has(key):
			if dict_1[key] is Dictionary and dict_2[key] is Dictionary:
				return_dict[key] = crossover({}, dict_1[key], dict_2[key])
			elif randi_range(0, 1) == 0:
				return_dict[key] = dict_1[key]
			else:
				return_dict[key] = dict_2[key]
			dict_2.erase(key)
		elif randi_range(0, 1) == 0:
			return_dict[key] = dict_1[key]
		dict_1.erase(key)

	if dict_2.size() > 0:
		crossover(return_dict, dict_2, dict_1)

	return return_dict

# Potentially mutates the number of nodes in the genome
# chance is the percentage chance that the number of nodes can change
# min_intensity is the min percentage that a value can mutate by (-50 means the value can be halved)
# max_intensity is the max percentage that a value can mutate by (100 means the value can double)
func mutation(dict, num_nodes, chance, min_intensity, max_intensity):
	if chance > randi_range(0, 99):
		num_nodes *= 1 + randi_range(min_intensity, max_intensity) / 100.0
		num_nodes = int(round(num_nodes))
		num_nodes = max(4, num_nodes)

	while num_nodes < dict.size():
		dict.erase(dict.keys()[randi_range(0, dict.size() - 1)])

	var new_key = 0
	while num_nodes > dict.size():
		while dict.has(str(new_key)):
			new_key += 1
		dict[str(new_key)] = dict[dict.keys()[randi_range(0, dict.size() - 1)]]

	return mutation_values(dict, num_nodes, chance, min_intensity, max_intensity)

# Iterates through each key in the genome
# chance is the percentage chance that each value mutates
# min_intensity is the min percentage that a value can mutate by (-50 means the value can be halved)
# max_intensity is the max percentage that a value can mutate by (100 means the value can double)
func mutation_values(dict, num_nodes, chance, min_intensity, max_intensity):
	for key in dict.keys():
		if dict[key] is Dictionary:
			dict[key] = mutation_values(dict[key], num_nodes, chance, min_intensity, max_intensity)
		else:
			if chance > randi_range(0, 99):
				if key == "parent_id":
					dict[key] = int(dict[key])
					dict[key] += num_nodes * (1 + randi_range(min_intensity, max_intensity) / 100.0)
					dict[key] = int(round(dict[key])) % num_nodes
					if dict[key] < 0:
						dict[key] = num_nodes + dict[key]
					dict[key] = str(dict[key])
				elif key == "angle":
					dict[key] += 360 * (1 + randi_range(min_intensity, max_intensity) / 100.0)
					dict[key] = int(round(dict[key])) % 360
					if dict[key] < 0:
						dict[key] = 360 + dict[key]
				elif key == "size":
					dict[key] *= 1 + randi_range(min_intensity, max_intensity) / 100.0
					dict[key] = float(clamp(dict[key], 5, 15))
				elif key == "joint":
					if dict[key] == "fixed":
						dict[key] = "pivot"
					else:
						dict[key] = "fixed"
	return dict

var creatures = []
func _ready():
	var physical_genome = {
		"0" = {
			"parent_id": "0",
			"angle": 0,
			"size": 10.0,
			"joint": "fixed"
		},
		"1" = {
			"parent_id": "0",
			"angle": 0,
			"size": 10.0,
			"joint": "fixed"
		},
		"2" = {
			"parent_id": "0",
			"angle": 120,
			"size": 10.0,
			"joint": "pivot"
		},
		"3" = {
			"parent_id": "0",
			"angle": 240,
			"size": 10.0,
			"joint": "pivot"
		}
	}
	create_creature(Vector2(0, 0), 90, physical_genome)

var timer = 0
func _process(delta):
	timer += delta
	if timer >= 1:
		create_offspring(creatures[creatures.size() - 1],
						 creatures[creatures.size() - 1])
		timer = 0
