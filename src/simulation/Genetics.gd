extends Node

@onready var Utility = get_node("../Utility")
@onready var Zookeeper = get_node("../Zookeeper")

var generate_creatures = false
var mutation_chance = 25
var mutation_intensity_decrease = -50
var mutation_intensity_increase = 50
var print_new_genome = false
var distance_check = 30.0

signal next_generation
signal creature_info(info)

func create_offspring(creature_1, creature_2):
	next_generation.emit()
	
	var physical_crossover = crossover({}, creature_1.Status.physical_genome, creature_2.Status.physical_genome)
	var physical_mutation = mutation(physical_crossover, physical_crossover.size(), mutation_intensity_decrease, mutation_intensity_increase)

	var offspring_pos = (creature_1.global_position + creature_2.global_position) / 2.0
	var offspring_rot = (creature_1.Body.rotation + creature_2.Body.rotation) / 2.0
	Zookeeper.create_creature(offspring_pos, offspring_rot, physical_mutation)
	if print_new_genome:
		print("New Genome:")
		print(physical_mutation)
		print()

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
func mutation(dict, num_nodes, min_intensity, max_intensity):
	if mutation_chance > randi_range(0, 99):
		num_nodes *= 1 + randi_range(min_intensity, max_intensity) / 100.0
		num_nodes = int(round(num_nodes))
		num_nodes = max(4, num_nodes)

	while num_nodes < dict.size():
		dict.erase(dict.keys()[randi_range(0, dict.size() - 1)])

	while num_nodes > dict.size():
		Utility.dictionary_next(dict, dict.values()[randi_range(0, dict.size() - 1)])

	return mutation_traversal(dict, num_nodes, min_intensity, max_intensity)

# Iterates through each key in the genome
# chance is the percentage chance that each value mutates
# min_intensity is the min percentage that a value can mutate by (-50 means the value can be halved)
# max_intensity is the max percentage that a value can mutate by (100 means the value can double)
func mutation_traversal(dict, num_nodes, min_intensity, max_intensity):
	for key in dict.keys():
		if dict[key] is Dictionary:
			dict[key] = mutation_traversal(dict[key], num_nodes, min_intensity, max_intensity)
		else:
			if mutation_chance > randi_range(0, 99):
				if key == "parent_id":
					dict[key] = int(dict[key])
					dict[key] += num_nodes * (1 + randi_range(min_intensity, max_intensity) / 100.0)
					dict[key] = int(round(dict[key])) % num_nodes
					if dict[key] < 0:
						dict[key] = num_nodes + dict[key]
				elif key == "angle":
					dict[key] += 360 * (1 + randi_range(min_intensity, max_intensity) / 100.0)
					dict[key] = Utility.angle_clamp(dict[key])
				elif key == "size":
					dict[key] *= 1 + randi_range(min_intensity, max_intensity) / 100.0
					dict[key] = float(clamp(dict[key], 5, 15))
				elif key == "joint":
					if dict[key] == "fixed":
						dict[key] = "pivot"
					else:
						dict[key] = "fixed"
				elif key == "type":
					dict[key] = mutate_type()
	return dict

var types = ["body", "reproduction", "eye"]
func mutate_type():
	return types[randi_range(0, types.size() - 1)]
