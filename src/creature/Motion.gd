# Motion handles the positioning of nodes, creature propulsion, and velocity
extends Node

@onready var Body = get_node("../Body")
@onready var Creature = get_node("../../Creature")
@onready var Status = get_node("../Status")
@onready var Utility = get_node("../../../Utility")

var propulsion_vectors = {}
var propulsion_angles = {}

func move_node(node, pos, propulsion):
	var old_pos = node["position"]
	var old_angle = node["angle"]
	node["position"] = pos
	node["object"].position = pos

	#update_node_angle(node)

	if propulsion:
		var propulsion_vector_change = old_pos - pos
		var propulsion_angle_change
		var angle_diff = old_angle - node["angle"]
		if angle_diff < 0:
			if abs(angle_diff) < angle_diff + 360:
				propulsion_angle_change = angle_diff
			else:
				propulsion_angle_change = angle_diff + 360
		else:
			if angle_diff < abs(angle_diff - 360):
				propulsion_angle_change = angle_diff
			else:
				propulsion_angle_change = angle_diff - 360

		Utility.dictionary_next(propulsion_vectors, propulsion_vector_change)
		Utility.dictionary_next(propulsion_angles, propulsion_angle_change)

func pivot_node(node, angle_shift, propulsion):
	node.rotation_degrees += angle_shift
	node.update_position()
#
	#if node.has("child_connections"):
		#for connection in node["child_connections"]:
			#var child_id = connection["child_id"]
			#pivot_node(child_id, origin_id, angle_shift, false)

func process_motion(delta):
	var propulsion_vector_sum = Vector2(0, 0)
	var propulsion_angle_sum = 0

	for key in propulsion_vectors.keys():
		propulsion_vector_sum += propulsion_vectors[key]
		propulsion_vectors[key] *= 0.97
		if propulsion_vectors[key].length() < 0.2:
			propulsion_vectors.erase(key)

	for key in propulsion_angles.keys():
		propulsion_angle_sum += propulsion_angles[key]
		propulsion_angles[key] *= 0.97
		if abs(propulsion_angles[key]) < 0.5:
			propulsion_angles.erase(key)

	Body.rotation_degrees += propulsion_angle_sum * delta * 2
	var move_vector = propulsion_vector_sum.rotated(deg_to_rad(Body.rotation_degrees)) * delta * 5

	if move_vector.length() <= Status.max_speed:
		Creature.position += move_vector
	else:
		Creature.position += move_vector / move_vector.length() * Status.max_speed

func _process(delta):
	process_motion(delta)
