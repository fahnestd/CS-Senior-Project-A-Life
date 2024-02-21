extends Node2D

var creature

var visible_nodes = {}

var behavior_step_progress = 0
var behavior_step_id = 0
var behavior_id = "0"

# Returns a value in degrees that, if added to creature.rotation, would face the creature towards target_coords
func calculate_angle_diff(target_coords):
	var pos = creature.get_global_position()
	var vec_diff = target_coords - pos 
	var dir_vec = Vector2(1, 0).rotated(creature.body.rotation)
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
		elif conditional_type == "greater":
			if angle_diff > conditional_value:
				evaluation = true
		if condition_details.has("and"):
			evaluation = evaluation and evaluate_condition(condition_details["and"], target_coords)
	return evaluation

func decide_pattern(target_coords):
	var viable_patterns = []

	for key in creature.behavioral_genome.keys():
		var pattern = creature.behavioral_genome[key]
		if pattern.has("if"):
			if evaluate_condition(pattern["if"], target_coords):
				viable_patterns.append(key)
		else:
			viable_patterns.append(key)

	if viable_patterns.size() > 0:
		behavior_id = viable_patterns[randi_range(0, viable_patterns.size() - 1)]
	else:
		behavior_id = null

func process_behavior(delta):
	if behavior_step_progress == 0 and behavior_step_id == 0:
		decide_pattern(Vector2(4000, 4000))

	if behavior_id:
		if behavior_id == "0":
			pass
		var behavior_pattern = creature.behavioral_genome[behavior_id]["pattern"]
		var simultaneous_steps = behavior_pattern[str(behavior_step_id)]
		var behavior_step_seconds = simultaneous_steps["time"]

		behavior_step_progress += delta
		if behavior_step_progress > behavior_step_seconds:
			delta -= behavior_step_progress - behavior_step_seconds
			behavior_step_progress = behavior_step_seconds

		for nth_pivot in simultaneous_steps.keys():
			if nth_pivot != "time":
				var behavior_step_angle = simultaneous_steps[nth_pivot]
				var movement_percent = delta / behavior_step_seconds
				var angle_shift = behavior_step_angle * movement_percent
				if creature.pivot_node_ids.size() >= int(nth_pivot) + 1:
					var id = creature.pivot_node_ids[nth_pivot]
					var node = creature.nodes[id]
					var parent_connection = node["parent_connection"]
					var parent_id = parent_connection["parent_id"]
					creature.pivot_node(id, parent_id, angle_shift, true)

		if behavior_step_progress == behavior_step_seconds:
			behavior_step_progress = 0
			behavior_step_id += 1
			if behavior_step_id >= behavior_pattern.size():
				behavior_step_id = 0
