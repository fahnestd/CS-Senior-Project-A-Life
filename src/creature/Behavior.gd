# Behavior evaluates which conditions in the behavioral genome are met and carries out a chosen behavior pattern
extends Node

@onready var Creature = get_parent()
@onready var Body = get_node("../Body")
@onready var Growth = get_node("../Growth")
@onready var Status = get_node("../Status")
@onready var Utility = get_node("/root/MainScene/Utility")

# Stores the pivot nodes in creation order, so behavioral patterns can specify things like "rotate first pivot node, rotate second pivot node" without referring to their specific ids
var pivot_nodes = {}
var visible_nodes = {}
var audible_nodes = {}

var behavior_step_progress = 0
var behavior_step_id = 0
var behavior_id = 0

# Returns a value in degrees that, if added to creature.rotation, would face the creature towards target_coords
func calculate_angle_difference(target_coords):
	var pos = Creature.global_position
	var vec_diff = target_coords - pos
	var dir_vec = Vector2(1, 0).rotated(Body.rotation)
	var angle_diff = Utility.angle_clamp(rad_to_deg(dir_vec.angle_to(vec_diff)))
	return angle_diff

func compare(conditional_type, value_1, value_2):
	if conditional_type == "equal":
		if value_1 == value_2:
			return true
	elif conditional_type == "notEqual":
		if value_1 != value_2:
			return true
	elif conditional_type == "less":
		if value_1 < value_2:
			return true
	elif conditional_type == "lessEqual":
		if value_1 <= value_2:
			return true
	elif conditional_type == "greater":
		if value_1 > value_2:
			return true
	elif conditional_type == "greaterEqual":
		if value_1 >= value_2:
			return true
	return false

func evaluate_condition(behavior, target_node, perceived_target_position):
	var target = behavior["target"]
	var condition = behavior["condition"]
	var evaluation = false
	if target["target_type"] != "none" and target["target_type"] != "Food" and not target_node.has_node(target["target_type"]):
		# TODO: Add a check based on target species (target_classifier)
		evaluation = false
	elif target["target_type"] == "Food" and target_node.has_node("Food") and target_node.energy_value == 0:
		evaluation = false
	elif target["target_type"] == "Food" and not target_node.has_node("Food") and (target_node.get_node("Status").integrity != 0 or target_node.get_node("Status").consumed == true):
		evaluation = false
	elif target["target_type"] == "Reproduction" and target_node.Creature.Status.reproduction_cooldown_progress != 0:
		evaluation = false
	elif condition["condition_type"] == "none":
		evaluation = true
	elif condition["condition_type"] == "angle_difference":
		if condition["condition_value"] != null:
			var angle_diff = calculate_angle_difference(perceived_target_position)
			evaluation = compare(condition["condition_comparison"], angle_diff, condition["condition_value"])
	# Update mutate_condition_type in Genetics when you add a new condition_type

	if not condition["and"] == null:
		evaluation = evaluation and evaluate_condition(condition["and"], target_node, perceived_target_position)
	if not condition["or"] == null:
		evaluation = evaluation or evaluate_condition(condition["or"], target_node, perceived_target_position)
	return evaluation

var last_target = null
func decide_pattern():
	var condition_met = false
	for key in Status.behavioral_genome.keys():
		var behavior = Status.behavioral_genome[key]
		var target = behavior["target"]
		if target["target_classifier"] == "self":
			condition_met = scan_perceived_nodes(key, Growth.nodes.values(), "self")
		else:
			if visible_nodes.size() > 0:
				condition_met = scan_perceived_nodes(key, visible_nodes, "visible")
			else:
				condition_met = scan_perceived_nodes(key, audible_nodes, "audible")
		if condition_met:
			return

	behavior_id = null
	last_target = null

func scan_perceived_nodes(behavior_key, check_nodes, check_type):
	var behavior = Status.behavioral_genome[behavior_key]
	for target_node in check_nodes:
		if last_target == null or target_node == last_target or check_type == "self":
			var perceived_target_position
			if check_type == "self":
				perceived_target_position = target_node.global_position
			elif check_type == "visible":
				perceived_target_position = visible_nodes[target_node]		
			elif check_type == "audible":
				perceived_target_position = audible_nodes[target_node][0]
				var ear = audible_nodes[target_node][1]
				perceived_target_position = ear.add_random_position_variance(perceived_target_position)
			if perceived_target_position:
				if evaluate_condition(behavior, target_node, perceived_target_position):
					if check_type == "visible":
						last_target = target_node
					else:
						last_target = null
					behavior_id = behavior_key
					return true
	return false

func process_behavior(delta):
	if behavior_step_progress == 0 and behavior_step_id == 0:
		decide_pattern()

	if behavior_id != null:
		var behavior_pattern = Status.behavioral_genome[behavior_id]["pattern"]
		var behavior_step = behavior_pattern.values()[behavior_step_id]
		var simultaneous_steps = behavior_step["steps"]
		var behavior_step_seconds = behavior_step["time"]

		behavior_step_progress += delta
		if behavior_step_progress > behavior_step_seconds:
			delta -= behavior_step_progress - behavior_step_seconds
			behavior_step_progress = behavior_step_seconds

		for nth_pivot in simultaneous_steps.keys():
			var behavior_step_angle = simultaneous_steps[nth_pivot]
			var movement_percent = delta / behavior_step_seconds
			var angle_shift = behavior_step_angle * movement_percent
			if pivot_nodes.size() >= nth_pivot + 1:
				var pivot_node = pivot_nodes[nth_pivot]
				if pivot_node.Status.integrity != 0:
					pivot_node.turn(angle_shift, true)

		if behavior_step_progress == behavior_step_seconds:
			behavior_step_progress = 0
			behavior_step_id += 1
			if behavior_step_id >= behavior_pattern.size():
				behavior_step_id = 0

func _physics_process(delta):
	process_behavior(delta)
