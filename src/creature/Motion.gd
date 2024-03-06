# Motion handles the positioning of nodes, creature propulsion, and velocity
extends Node

@onready var Body = get_node("../Body")
@onready var Creature = get_parent()
@onready var Status = get_node("../Status")
@onready var Utility = get_node("../../../Utility")

var propulsion_vectors = {}
var propulsion_angles = {}

func pivot_node(node, angle_shift):
	node.turn(angle_shift, true)

func add_propulsion_position(position_shift):
	Utility.dictionary_next(propulsion_vectors, position_shift)

func add_propulsion_angle(angle_shift):
	Utility.dictionary_next(propulsion_angles, angle_shift)

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
