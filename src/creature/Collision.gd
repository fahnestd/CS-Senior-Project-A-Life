extends Area2D

var collision_check = false

var size = Vector2(0, 0)
var node_id

var shift_sum = Vector2(0, 0)
var num_shifts = 0
var position_shift = Vector2(0, 0)
var new_position = position

var parent
var collision_area

func _ready():
	parent = get_parent()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	avoid_area(area)
	collision_check = true

func avoid_area(area):
	collision_area = area

	#Position should not be modified in this function or else there will be a race condition
	#Modify position_shift instead
	var position_difference = area.position - position

	#Slight random shift to avoid getting stuck in a looping pattern
	position_shift -= Vector2(randf_range(-1, 1), randf_range(-1, 1)) / 8.0

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
	position_shift -= (Vector2(unit_x, unit_y) * shift) / 8.0

func _process(_delta):
	if position_shift != Vector2(0, 0):
		num_shifts += 1
		shift_sum += position_shift
		new_position = position
		new_position += shift_sum / num_shifts
		position_shift = Vector2(0, 0)
		parent.move_node(node_id, new_position, true)

	if collision_check:
		var overlapping_areas = get_overlapping_areas()
		if len(overlapping_areas) > 0:
			for i in overlapping_areas:
				avoid_area(i)
		else:
			collision_check = false
			shift_sum = Vector2(0, 0)
			num_shifts = 0

	if collision_area != null:
		if collision_area.parent != parent:
			parent.fix_connection_length(node_id)
		else:
			parent.update_node_angle(node_id)
			parent.update_node_connections(node_id)
	else:
		parent.fix_connection_length(node_id)
