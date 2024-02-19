extends Node2D

var Behavior = preload("res://src/creature/Behavior.gd").new()

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

# Stores the ids of pivot nodes in creation order, so behavioral patterns can specify things like "rotate first pivot node, rotate second pivot node" without referring to their specific ids
var pivot_node_ids = {}

var propulsion_vector = Vector2(0, 0)
var propulsion_angle = 0

@onready var world = get_node("../../World")
@onready var camera = get_node("../Camera2D")
@onready var health = get_node("../CreatureHealth")

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
	new_area.script = load("res://src/creature/Collision.gd")
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

	if new_node["joint"] == "pivot":
		pivot_node_ids[str(pivot_node_ids.size())] = id

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

	update_node_angle(id)
	update_node_connections(id)

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

	if propulsion:
		propulsion_vector += old_pos - pos
		propulsion_angle += propulsion_angle_change

func update_node_angle(id):
	var node = nodes[id]
	if node.has("parent_connection"):
		var parent_connection = node["parent_connection"]
		var parent_id = parent_connection["parent_id"]
		var parent_node = nodes[parent_id]
		var parent_pos = parent_node["position"]
		var angle = rad_to_deg(parent_pos.angle_to_point(node["position"]))
		if angle < 0:
			angle += 360
		node["angle"] = angle

func update_node_connections(id):
	var node = nodes[id]
	if node.has("child_connections"):
		for connection in node["child_connections"]:
			update_connection(connection)

	if node.has("parent_connection"):
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

		if new_node_pos != node["position"]:
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

func build_creature():
	add_first_node()
	add_possible_nodes()
	force_add_remaining_nodes()

func add_first_node():
	var lowest_id = 0
	while not physical_genome.has(str(lowest_id)):
		lowest_id += 1
	var id = str(lowest_id)
	physical_genome[id]["parent_id"] = id
	add_node(id, Vector2(0, 0))
	camera.reparent.call_deferred(nodes[id]["area"])
	camera.position = Vector2(0, 0)

func add_possible_nodes():
	var added_node = false
	while true:
		added_node = false
		for id in physical_genome.keys():
			if not nodes.has(id):
				var parent_id = physical_genome[id]["parent_id"]
				if nodes.has(parent_id):
					add_connected_node(id)
					added_node = true
		if not added_node or nodes.size() == physical_genome.size():
			break

func force_add_remaining_nodes():
	if nodes.size() != physical_genome.size():
		for id in physical_genome.keys():
			if not nodes.has(id):
				var parent_id = int(physical_genome[id]["parent_id"])
				while not nodes.has(str(parent_id)):
					parent_id -= 1
					if parent_id < 0:
						parent_id = int(physical_genome[id]["parent_id"]) + 1
						while not nodes.has(str(parent_id)):
							parent_id += 1
				physical_genome[id]["parent_id"] = str(parent_id)
				add_connected_node(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	Behavior.creature = self
	build_creature()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Behavior.process_behavior(delta)

	propulsion_angle = clamp(propulsion_angle, -180, 180)

	self.rotation_degrees += propulsion_angle * delta

	var move_vector = propulsion_vector.rotated(deg_to_rad(self.rotation_degrees))

	if move_vector.length() <= max_speed:
		get_parent().position += move_vector
	else:
		get_parent().position += move_vector / move_vector.length() * max_speed

	propulsion_vector *= 0.99999
	propulsion_angle *= 0.99999
	
	handle_interactions()

# On second thought, we should probably move this functionality into the tile, and have the tile apply any affects it needs or wants onto the creature
# Ill leave it here for now though while I think it through.
func handle_interactions():
	handle_pressure();
	handle_lightlevel();
	handle_temperature();
	handle_tiletype();
	
	update_label();
	
func update_label():
	var terrainLabel = get_node("../TerrainLabel")
	var pos = Vector2i(get_parent().position)
	var global_pos = Vector2i(get_parent().global_position)
	terrainLabel.text = str(pos / world.GetTileSize());
	var tile = world.GetTile(global_pos)
	if tile != null:
		terrainLabel.text += "\nHealth: " + str(health.health);
		terrainLabel.text += "\nTerrain: " + str(tile.TerrainType);
		terrainLabel.text += "\nTemperature: " + str(tile.Temperature);
		if tile.Temperature == 1:
			health.Damage(1)
	else:
		pass


func handle_tiletype():
	pass
	
func handle_pressure():
	pass

func handle_lightlevel():
	pass
	
func handle_temperature():
	pass
