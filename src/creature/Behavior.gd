# Behavior evaluates which conditions in the behavioral genome are met and carries out a chosen behavior pattern
extends Node

@onready var Creature = get_parent()
@onready var Body = get_node("../Body")
@onready var Growth = get_node("../Growth")
@onready var Motion = get_node("../Motion")
@onready var Status = get_node("../Status")

# Stores the pivot nodes in creation order, so behavioral patterns can specify things like "rotate first pivot node, rotate second pivot node" without referring to their specific ids
var pivot_nodes = {}
var visible_nodes = {}

var behavior_step_progress = 0
var behavior_step_id = 0
var behavior_id = 0

# Returns a value in degrees that, if added to creature.rotation, would face the creature towards target_coords
func calculate_angle_diff(target_coords):
	var pos = Creature.get_global_position()
	var vec_diff = target_coords - pos 
	var dir_vec = Vector2(1, 0).rotated(Body.rotation)
	var angle_diff = round(rad_to_deg(dir_vec.angle_to(vec_diff)))
	return angle_diff

func evaluate_condition(condition, target_coords):
	var evaluation = false
	var condition_type = condition.keys()[0]
	if condition_type == "angle diff":
		var angle_diff = calculate_angle_diff(target_coords)
		var condition_details = condition[condition_type]
		var conditional_type = condition_details["conditional"]
		var conditional_value = condition_details["value"]
		if conditional_type == "less":
			if angle_diff < conditional_value:
				evaluation = true
		elif conditional_type == "lessEqual":
			if angle_diff <= conditional_value:
				evaluation = true
		elif conditional_type == "greater":
			if angle_diff > conditional_value:
				evaluation = true
		elif conditional_type == "greaterEqual":
			if angle_diff >= conditional_value:
				evaluation = true
		if condition_details.has("and"):
			evaluation = evaluation and evaluate_condition(condition_details["and"], target_coords)
	return evaluation

func decide_pattern(target_coords):
	var viable_patterns = []

	for key in Status.behavioral_genome.keys():
		var pattern = Status.behavioral_genome[key]
		if pattern.has("if"):
			if evaluate_condition(pattern["if"], target_coords):
				viable_patterns.append(key)
		else:
			viable_patterns.append(key)

	if viable_patterns.size() > 0:
#		behavior_id = viable_patterns[randi_range(0, viable_patterns.size() - 1)]
		behavior_id = viable_patterns[0]
	else:
		behavior_id = null

func process_behavior(delta):
	if behavior_step_progress == 0 and behavior_step_id == 0:
		var detected_node = false
		for node in visible_nodes:
			if node.type == "reproduction":
				decide_pattern(node.global_position)
				detected_node = true
				break
		if not detected_node:
			# Target the point 1 unit in front of the creature
			decide_pattern(Creature.global_position + Vector2(1, 0).rotated(deg_to_rad(Body.rotation_degrees)))

	if behavior_id:
		var behavior_pattern = Status.behavioral_genome[behavior_id]["pattern"]
		var simultaneous_steps = behavior_pattern[behavior_step_id]
		var behavior_step_seconds = simultaneous_steps["time"]

		behavior_step_progress += delta
		if behavior_step_progress > behavior_step_seconds:
			delta -= behavior_step_progress - behavior_step_seconds
			behavior_step_progress = behavior_step_seconds

		for nth_pivot in simultaneous_steps.keys():
			if nth_pivot is int:
				var behavior_step_angle = simultaneous_steps[nth_pivot]
				var movement_percent = delta / behavior_step_seconds
				var angle_shift = behavior_step_angle * movement_percent
				if pivot_nodes.size() >= nth_pivot + 1:
					Motion.pivot_node(pivot_nodes[nth_pivot], angle_shift)

		if behavior_step_progress == behavior_step_seconds:
			behavior_step_progress = 0
			behavior_step_id += 1
			if behavior_step_id >= behavior_pattern.size():
				behavior_step_id = 0

func _process(delta):
	process_behavior(delta)
