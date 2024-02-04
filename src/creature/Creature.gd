extends Node2D

var physical_genome
var behavioral_genome

# Changeable parameters
var connection_distance = 20
var max_speed = 1

var node_texture = preload("res://assets/creature/circle.png")
var node_width = node_texture.get_width()
var node_height = node_texture.get_height()
var fixed_texture = preload("res://assets/creature/fixed.png")
var pivot_texture = preload("res://assets/creature/pivot.png")

var nodes = {}

var propulsion_vector = Vector2(0, 0)
var propulsion_angle = 0
var inertia_vector = Vector2(0, 0)
var inertia_angle = 0

@onready var world = get_node("../../World")

func add_node(id, pos):
	var node_plan = physical_genome[id]
	var size = node_plan["size"]
	var angle = node_plan["angle"]
	var joint = node_plan["joint"]
	var new_node = {
		"position": pos,
		"size": size,
		"angle": angle,
		"joint": joint
	}

	nodes[id] = new_node

	var new_area = Area2D.new()

	var new_sprite = Sprite2D.new()
	new_sprite.texture = node_texture
	new_sprite.scale.x = size / node_width
	new_sprite.scale.y = size / node_height
	new_area.add_child(new_sprite)

	var new_collision = CollisionShape2D.new()
	var new_rectangle = RectangleShape2D.new()
	new_rectangle.size = Vector2(size - 1, size - 1)
	new_collision.shape = new_rectangle

	new_area.add_child(new_collision)

	new_area.position = pos
	new_area.script = load("res://src/creature/Area2D.gd")
	new_area.size = Vector2(size, size)
	new_area.node_id = id

	add_child(new_area)
	new_node["area"] = new_area

	move_node(id, pos, false)

	return id

func add_connected_node(id):
	var node = physical_genome[id]
	var parent_id = node["parent_id"]
	var parent_node = nodes[parent_id]
	var new_sprite = Sprite2D.new()
	add_child(new_sprite)
	new_sprite.offset.x = 0.5
	new_sprite.position = parent_node.position
	new_sprite.rotation_degrees = node["angle"]
	new_sprite.scale.x = connection_distance
	if node["joint"] == "pivot":
		new_sprite.texture = pivot_texture
	else:
		new_sprite.texture = fixed_texture
	new_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	new_sprite.z_index = 1

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(node["angle"]))
	var endpoint = parent_node.position + connection_distance * dir_vector
	var new_node_id = add_node(id, endpoint)
	var new_node = nodes[new_node_id]

	var new_connection = {
		"sprite": new_sprite,
		"parent_id": parent_id,
		"child_id": new_node_id,
		"length": connection_distance
	}

	if parent_node.has("child_connections"):
		parent_node["child_connections"].append(new_connection)
	else:
		parent_node["child_connections"] = [new_connection]
	new_node["parent_connection"] = new_connection

func move_node(id, pos, propulsion):
	var node = nodes[id]
	var old_pos = node["position"]
	var old_angle = node["angle"]
	node["position"] = pos
	node["area"].position = pos

	fix_node_connections(id)

	if propulsion:
		propulsion_vector += pos - old_pos
		propulsion_angle += node["angle"] - old_angle

func fix_node_connections(id):
	var node = nodes[id]
	if node.has("child_connections"):
		for connection in node["child_connections"]:
			update_connection(connection)

	if node.has("parent_connection"):
		var parent_connection = node["parent_connection"]
		var parent_id = parent_connection["parent_id"]
		var parent_node = nodes[parent_id]
		var parent_pos = parent_node["position"]
		var angle = rad_to_deg(parent_pos.angle_to_point(node["position"]))
		if angle < 0:
			angle += 360
		node["angle"] = angle
		update_connection(node["parent_connection"])

func update_connection(connection):
	var parent_id = connection["parent_id"]
	var parent_node = nodes[parent_id]
	var parent_pos = parent_node["position"]
	var child_id = connection["child_id"]
	var child_node = nodes[child_id]
	var child_pos = child_node["position"]
	var distance = child_pos.distance_to(parent_pos)
	var angle = child_node["angle"]

	connection["sprite"].position = parent_pos
	connection["sprite"].rotation_degrees = angle
	connection["sprite"].scale.x = distance
	connection["length"] = round(distance * 100.0) / 100.0

func fix_connection_length(id):
	var node = nodes[id]
	if node.has("parent_connection"):
		var connection = node["parent_connection"]
		var parent_id = connection["parent_id"]
		var parent_node = nodes[parent_id]
		var parent_pos = parent_node["position"]
		var direction = parent_pos - node["position"]
		var distance = direction.length()
		direction = direction / distance

		if distance > connection_distance:
			distance *= 0.9
			distance = max(connection_distance, distance)
		elif distance < connection_distance:
			distance *= 1.1
			distance = min(connection_distance, distance)

		var new_node_pos = parent_pos - direction * distance

		move_node(id, new_node_pos, false)

func pivot_node(id, origin_id, angle_shift):
	var node = nodes[id]
	var origin_node = nodes[origin_id]
	var origin_pos = origin_node["position"]
	var distance = node["position"].distance_to(origin_pos)
	var angle = rad_to_deg(origin_pos.angle_to_point(node["position"]))
	if angle < 0:
		angle += 360

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(angle + angle_shift))
	var endpoint = origin_pos + distance * dir_vector
	move_node(id, endpoint, true)

	if node.has("child_connections"):
		for connection in node["child_connections"]:
			var child_id = connection["child_id"]
			pivot_node(child_id, origin_id, angle_shift)

# Called when the node enters the scene tree for the first time.
func _ready():
	var added_node = false
	while true:
		added_node = false
		for id in physical_genome.keys():
			if nodes.size() == 0:
				physical_genome[id]["parent_id"] = id
				add_node(id, Vector2(0, 0))
				added_node = true
			elif not nodes.has(id):
				var parent_id = physical_genome[id]["parent_id"]
				if nodes.has(parent_id):
					add_connected_node(id)
					added_node = true
		if not added_node or nodes.size() == physical_genome.size():
			break

var behavior_step_progress = 0
var behavior_step_id = 0
var behavior_id = "0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if behavior_step_progress == 0 and behavior_step_id == 0:
		behavior_id = str(randi_range(0, len(behavioral_genome) - 1))

	var behavior = behavioral_genome[behavior_id]
	var behavior_pattern = behavior["pattern"]
	var simultaneous_steps = behavior_pattern[behavior_step_id]
	var behavior_step_seconds = simultaneous_steps[len(simultaneous_steps) - 1]

	behavior_step_progress += delta
	if behavior_step_progress > behavior_step_seconds:
		behavior_step_progress = 0
		behavior_step_id += 1
		if behavior_step_id >= len(behavior_pattern):
			behavior_step_id = 0

	for i in range(len(simultaneous_steps) - 1):
		var behavior_step = simultaneous_steps[i]
		var behavior_step_node_id = behavior_step[0]
		var behavior_step_angle = behavior_step[1]
		var movement_percent = delta / behavior_step_seconds
		var angle_shift = behavior_step_angle * movement_percent
		if nodes.has(behavior_step_node_id):
			var node = nodes[behavior_step_node_id]
			if node["joint"] == "pivot" and node.has("parent_connection"):
				var parent_connection = node["parent_connection"]
				var parent_id = parent_connection["parent_id"]
				pivot_node(behavior_step_node_id, parent_id, angle_shift)

	if inertia_angle > 0 and propulsion_angle < 0:
		inertia_angle += propulsion_angle * 0.01
	elif inertia_angle < 0 and propulsion_angle > 0:
		inertia_angle += propulsion_angle * 0.01
	else:
		inertia_angle += propulsion_angle

	self.rotation_degrees += inertia_angle * delta
	propulsion_angle = 0
	propulsion_vector = propulsion_vector.rotated(deg_to_rad(self.rotation_degrees))

	if inertia_vector.x > 0 and propulsion_vector.x < 0:
		inertia_vector.x += propulsion_vector.x * 0.01
	elif inertia_vector.x < 0 and propulsion_vector.x > 0:
		inertia_vector.x += propulsion_vector.x * 0.01
	else:
		inertia_vector.x += propulsion_vector.x

	if inertia_vector.y > 0 and propulsion_vector.y < 0:
		inertia_vector.y += propulsion_vector.y * 0.01
	elif inertia_vector.y < 0 and propulsion_vector.y > 0:
		inertia_vector.y += propulsion_vector.y * 0.01
	else:
		inertia_vector.y += propulsion_vector.y

	propulsion_vector *= 0

	if inertia_vector.length() <= max_speed:
		get_parent().position -= inertia_vector
	else:
		get_parent().position -= inertia_vector / inertia_vector.length() * max_speed

	inertia_vector *= 0.95
	inertia_angle *= 0.95
	
	handle_interactions()

func handle_interactions():
	handle_pressure();
	handle_lightlevel();
	handle_temperature();
	
func handle_pressure():
	get_node("../TerrainLabel").text = str(Vector2i(get_parent().position) / world.GetTileSize());
	get_node("../TerrainLabel").text += "\nTemperature: " + str(world.GetTileTemperature(Vector2i(get_parent().global_position) / world.GetTileSize())) + "\nTerrain: " + str(world.GetTileTerrainType(Vector2i(get_parent().global_position) / world.GetTileSize()));

func handle_lightlevel():
	pass
	
func handle_temperature():
	pass
