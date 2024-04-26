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

func evaluate_condition(behavior, target_node):
	var target = behavior["target"]
	var condition = behavior["condition"]
	var evaluation = false
	if condition["condition_type"] == "none":
		evaluation = true
	elif target["target_type"] != "none" and not target_node.has_node(target["target_type"]):
		# TODO: Add a check based on target species (target_classifier)
		evaluation = false
	elif condition["condition_type"] == "angle_difference":
		if condition["condition_value"] != null:
			var angle_diff = calculate_angle_difference(target_node.global_position)
			evaluation = compare(condition["condition_comparison"], angle_diff, condition["condition_value"])
	# Update mutate_condition_type in Genetics when you add a new condition_type

	if not condition["and"] == null:
		evaluation = evaluation and evaluate_condition(condition["and"], target_node)
	if not condition["or"] == null:
		evaluation = evaluation or evaluate_condition(condition["or"], target_node)
	return evaluation

func decide_pattern():
	for key in Status.behavioral_genome.keys():
		var behavior = Status.behavioral_genome[key]
		var target = behavior["target"]
		var check_nodes = visible_nodes
		if target["target_classifier"] == "self":
			check_nodes = Growth.nodes.values()
		for target_node in check_nodes:
			if evaluate_condition(behavior, target_node):
				behavior_id = key
				return

	behavior_id = null

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
