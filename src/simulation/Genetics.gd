extends Node

@onready var Utility = get_node("../Utility")
@onready var Zookeeper = get_node("../Zookeeper")
@onready var SpeciesManager = get_node("../SpeciesManager")

# % mutation chance
# Note that this chance applies to each parameter (not the genome as a whole)
# So a 50% chance means half of the entire genome will be mutated
var mutation_chance = 2
# min_change is the min percentage that a value can mutate by (-50 means the value can be halved)
# max_change is the max percentage that a value can mutate by (100 means the value can double)
var min_change = -50
var max_change = 50
var enable_physical_mutations = true
var print_new_physical_genome = false
var print_new_behavioral_genome = false

signal next_generation
signal creature_info(info)
signal track_species(genome)

func get_change():
	return 1 + randi_range(min_change, max_change) / 100.0

func create_offspring(creature_1, creature_2):
	next_generation.emit()
	
	var physical_crossover = crossover({}, creature_1.Status.physical_genome, creature_2.Status.physical_genome)
	var physical_mutation
	if enable_physical_mutations:
		physical_mutation = mutation(physical_crossover)
	else:
		physical_mutation = physical_crossover

	var behavioral_crossover = crossover({}, creature_1.Status.behavioral_genome, creature_2.Status.behavioral_genome)
	var behavioral_mutation = mutation(behavioral_crossover)

	var offspring_pos = (creature_1.global_position + creature_2.global_position) / 2.0
	var offspring_rot = (creature_1.Body.rotation + creature_2.Body.rotation) / 2.0

	Zookeeper.create_creature(offspring_pos, offspring_rot, physical_mutation, behavioral_mutation)

	# SpeciesManager.track_species(physical_mutation)
	track_species.emit(physical_mutation)

	if print_new_physical_genome:
		print("New Physical Genome:")
		Utility.print_dictionary(physical_mutation)
		print()

	if print_new_behavioral_genome:
		print("New Behavioral Genome:")
		Utility.print_dictionary(behavioral_mutation)
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
				if dict_1[key] is Dictionary:
					return_dict[key] = dict_1[key].duplicate(true)
				else:
					return_dict[key] = dict_1[key]
			else:
				if dict_2[key] is Dictionary:
					return_dict[key] = dict_2[key].duplicate(true)
				else:
					return_dict[key] = dict_2[key]
			dict_2.erase(key)
		elif randi_range(0, 1) == 0:
			return_dict[key] = dict_1[key]
		dict_1.erase(key)

	if dict_2.size() > 0:
		crossover(return_dict, dict_2, dict_1)

	return return_dict

func mutation(dict):
	mutate_num_entries(dict, 4)
	return mutation_traversal(dict, dict)

# Potentially mutates the number of entries in the dict by erasing entries or duplicating existing ones
# mutation_chance is the percentage chance that the number of entries can change
func mutate_num_entries(dict, min_entries):
	var num_entries = dict.size()
	if mutation_chance > randi_range(0, 99):
		num_entries *= get_change()
		num_entries = round(num_entries)
	num_entries = max(min_entries, num_entries)

	while num_entries < dict.size():
		dict.erase(dict.keys()[randi_range(0, dict.size() - 1)])

	while num_entries > dict.size():
		var copy_value = dict.values()[randi_range(0, dict.size() - 1)]
		if copy_value is Dictionary:
			copy_value = copy_value.duplicate(true)
			if copy_value.has("angle"):
				mutate_angle(copy_value)
		Utility.dictionary_next(dict, copy_value)

# Iterates through each key in the genome
# chance is the percentage chance that each value mutates
func mutation_traversal(dict, full_genome):
	for key in dict.keys():
		if dict[key] is Dictionary and (not key is String or key != "and" and key != "or"):
			if key is String and key == "pattern":
				mutate_pattern(dict["pattern"])
			else:
				dict[key] = mutation_traversal(dict[key], full_genome)
		else:
			if mutation_chance > randi_range(0, 99):
				key = str(key)
				if key == "parent_id":
					mutate_parent_id(dict, full_genome.size())
				elif key == "angle":
					mutate_angle(dict)
				elif key == "size":
					mutate_size(dict)
				elif key == "joint":
					mutate_joint(dict)
				elif key == "type":
					mutate_type(dict)
				elif key == "target_type":
					mutate_target_type(dict)
				elif key == "target_classifier":
					mutate_target_classifier(dict)
				elif key == "condition_type":
					mutate_condition_type(dict)
				elif key == "condition_comparison":
					mutate_condition_comparison(dict)
				elif key == "condition_value":
					mutate_condition_value(dict)
				elif key == "and":
					mutate_and_or(dict, "and", full_genome)
				elif key == "or":
					mutate_and_or(dict, "or", full_genome)
	return dict

func mutate_parent_id(dict, num_nodes):
	dict["parent_id"] += num_nodes * get_change()
	dict["parent_id"] = int(round(dict["parent_id"])) % num_nodes
	if dict["parent_id"] < 0:
		dict["parent_id"] = num_nodes + dict["parent_id"]

func mutate_angle(dict):
	dict["angle"] += 360 * (get_change() - 1)
	dict["angle"] = Utility.angle_clamp(dict["angle"])

func mutate_size(dict):
	dict["size"] *= get_change()
	dict["size"] = clamp(dict["size"], 5, 15)

func mutate_joint(dict):
	if dict["joint"] == "fixed":
		dict["joint"] = "pivot"
	else:
		dict["joint"] = "fixed"

var types = ["body", "reproduction", "eye", "mouth"]
func mutate_type(dict):
	dict["type"] = types[randi_range(0, types.size() - 1)]

var target_types = ["none", "Food", "Body", "Reproduction", "Eye", "Mouth"]
func mutate_target_type(dict):
	dict["target_type"] = target_types[randi_range(0, target_types.size() - 1)]

var target_classifiers = ["self", "same_species", "different_species"]
func mutate_target_classifier(dict):
	dict["target_classifier"] = target_classifiers[randi_range(0, target_classifiers.size() - 1)]

# Update mutate_condition_value when adding a condition_type
var condition_types = ["none", "angle_difference"]
func mutate_condition_type(dict):
	dict["condition_type"] = condition_types[randi_range(0, condition_types.size() - 1)]

var comparisons = ["equal", "notEqual", "less", "lessEqual", "greater", "greaterEqual"]
func mutate_condition_comparison(dict):
	dict["condition_comparison"] = comparisons[randi_range(0, comparisons.size() - 1)]

func mutate_condition_value(dict):
	if dict["condition_type"] == "angle_difference":
		if dict["condition_value"] == null:
			dict["condition_value"] = 0
		dict["condition_value"] += 360 * (get_change() - 1)
		dict["condition_value"] = Utility.angle_clamp(dict["condition_value"])
	else:
		dict["condition_value"] = null

func mutate_and_or(dict, key, full_genome):
	if dict[key] == null:
		var behavior_copy = full_genome.values()[randi_range(0, full_genome.size() - 1)].duplicate(true)
		behavior_copy.erase("pattern")
		dict[key] = behavior_copy
	else:
		dict[key] = null

func mutate_pattern(dict):
	mutate_num_entries(dict, 1)
	for step in dict.values():
		var steps = step["steps"]
		mutate_num_entries(steps, 1)
		for substep in steps.keys():
			if mutation_chance > randi_range(0, 99):
				steps[substep] += 360 * (get_change() - 1)
				steps[substep] = Utility.angle_clamp(steps[substep])
		if mutation_chance > randi_range(0, 99):
			step["time"] *= get_change()

func _on_status_creature_dead(_creature):
	print("TEST")
