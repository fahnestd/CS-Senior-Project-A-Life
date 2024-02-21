extends Area2D

var collision_check = false

var size = Vector2(0, 0)
var node_id

var type
var eye_radius = 200

var shift_sum = Vector2(0, 0)
var num_shifts = 0
var position_shift = Vector2(0, 0)
var new_position = position

var parent_creature
var collision_area

func initialize_eye():
	var sight_object = Area2D.new()
	var circle = CircleShape2D.new()
	circle.radius = eye_radius
	var collision = CollisionShape2D.new()
	collision.shape = circle
	sight_object.add_child(collision)
	sight_object.script = load("res://src/creature/Eye.gd")
	self.add_child(sight_object)

func _ready():
	parent_creature = get_parent().get_parent()
	area_entered.connect(_on_area_entered)

	if type == "eye":
		initialize_eye()

signal reproduce(creature_1, creature_2)
func _on_area_entered(node):
	if type == "reproduction" and node.type == "reproduction":
		reproduce.emit(parent_creature, node.parent_creature)

	if node.type != "sight":
		avoid_area(node)
		collision_check = true
		shift_position()

func avoid_area(area):
	collision_area = area

	#Position should not be modified in this function or else there will be a race condition
	#Modify position_shift instead
	var position_difference = area.position - position

	#Slight random shift to avoid getting stuck in a looping pattern
	position_shift -= Vector2(randf_range(-1, 1), randf_range(-1, 1)) / 4.0

	var unit_x = 0
	var unit_y = 0

	if position_difference.x > 0:
		unit_x = 1
	elif position_difference.x < 0:
		unit_x = -1

	if position_difference.y > 0:
		unit_y = 1
	elif position_difference.y < 0:
		unit_y = -1

	var shift = size - abs(position_difference)
	shift.x = max(0, shift.x)
	shift.y = max(0, shift.y)
	position_shift -= (Vector2(unit_x, unit_y) * shift) / 4.0

func shift_position():
	if position_shift != Vector2(0, 0):
		num_shifts += 1
		shift_sum += position_shift
		new_position = position
		new_position += shift_sum / num_shifts
		position_shift = Vector2(0, 0)
		parent_creature.move_node(node_id, new_position, true)

func _process(_delta):
	shift_position()

	if collision_check:
		var overlapping_areas = get_overlapping_areas()
		var num_overlapping_areas = len(overlapping_areas)
		for node in overlapping_areas:
			if node.type == "sight":
				num_overlapping_areas -= 1
		if num_overlapping_areas > 0:
			for node in overlapping_areas:
				if node.type != "sight":
					avoid_area(node)
		else:
			collision_check = false
			shift_sum = Vector2(0, 0)
			num_shifts = 0

	if collision_area != null:
		if collision_area.parent_creature != parent_creature:
			parent_creature.fix_connection_length(node_id)
		else:
			parent_creature.update_node_angle(node_id)
			parent_creature.update_node_connections(node_id)
	else:
		parent_creature.fix_connection_length(node_id)

func _draw():
	if type == "eye":
		draw_circle(self.position, eye_radius, Color(1, 1, 1, 0.1))
