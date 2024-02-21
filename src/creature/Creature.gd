extends Node2D

var Behavior = preload("res://src/creature/Behavior.gd").new()

var physical_genome
var behavioral_genome
var creature_index

# Changeable parameters
var connection_distance = 20
var max_speed = 1

var textures = {
	"body" = preload("res://assets/creature/circle.png"),
	"reproduction" = preload("res://assets/creature/pink_circle.png"),
	"eye" = preload("res://assets/creature/blue_circle.png"),
	"fixed" = preload("res://assets/creature/fixed.png"),
	"pivot" = preload("res://assets/creature/pivot.png")
}
var node_width = textures["body"].get_width()
var node_height = textures["body"].get_height()

var nodes = {}
var root_node

# Stores the ids of pivot nodes in creation order, so behavioral patterns can specify things like "rotate first pivot node, rotate second pivot node" without referring to their specific ids
var pivot_node_ids = {}

var propulsion_vectors = {}
var propulsion_angles = {}

@onready var world = get_node("../World")
@onready var health = get_node("Health")
@onready var body = get_node("Body")

func add_node(id, pos):
	var node_plan = physical_genome[id]
	var node = {
		"id": id,
		"position": pos,
		"size": node_plan["size"],
		"angle": node_plan["angle"],
		"joint": node_plan["joint"],
		"type": node_plan["type"],
		"object": Area2D.new(),
		"sprite": Sprite2D.new()
	}
	nodes[id] = node
	initialize_object(node)
	initialize_sprite(node)
	move_node(id, pos, false)

func initialize_object(node):
	initialize_collision(node)
	node["object"].position = node["position"]
	node["object"].script = load("res://src/creature/Node.gd")
	node["object"].size = Vector2(node["size"], node["size"])
	node["object"].node_id = node["id"]
	node["object"].type = node["type"]
	body.add_child(node["object"])

func initialize_collision(node):
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(node["size"], node["size"])
	var collision = CollisionShape2D.new()
	collision.shape = rectangle
	node["object"].add_child(collision)

func initialize_sprite(node):
	node["sprite"].texture = textures[node["type"]]
	node["sprite"].scale.x = node["size"] / node_width
	node["sprite"].scale.y = node["size"] / node_height
	node["object"].add_child(node["sprite"])

func add_connected_node(id):
	var node = physical_genome[id]
	var parent_id = node["parent_id"]
	var parent_node = nodes[parent_id]
	var new_sprite = Sprite2D.new()
	body.add_child(new_sprite)
	new_sprite.offset.x = 0.5
	new_sprite.position = parent_node.position
	new_sprite.rotation_degrees = node["angle"]
	new_sprite.scale.x = connection_distance
	new_sprite.texture = textures[node["joint"]]
	new_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	new_sprite.z_index = 1

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(node["angle"]))
	var endpoint = parent_node.position + connection_distance * dir_vector
	add_node(id, endpoint)
	var new_node = nodes[id]

	if new_node["joint"] == "pivot":
		pivot_node_ids[str(pivot_node_ids.size())] = id

	var new_connection = {
		"sprite": new_sprite,
		"parent_id": parent_id,
		"child_id": id,
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
	node["object"].position = pos

	update_node_angle(id)
	update_node_connections(id)

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

		add_indexed_dictionary_entry(propulsion_vectors, propulsion_vector_change)
		add_indexed_dictionary_entry(propulsion_angles, propulsion_angle_change)

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

func add_indexed_dictionary_entry(dictionary, entry):
	var lowest_index = 0
	while dictionary.has(lowest_index):
		lowest_index += 1
	dictionary[lowest_index] = entry

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

func pivot_node(id, origin_id, angle_shift, propulsion):
	var node = nodes[id]
	var origin_node = nodes[origin_id]
	var origin_pos = origin_node["position"]
	var distance = node["position"].distance_to(origin_pos)
	var angle = rad_to_deg(origin_pos.angle_to_point(node["position"]))
	if angle < 0:
		angle += 360

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(angle + angle_shift))
	var endpoint = origin_pos + distance * dir_vector
	move_node(id, endpoint, propulsion)

	if node.has("child_connections"):
		for connection in node["child_connections"]:
			var child_id = connection["child_id"]
			pivot_node(child_id, origin_id, angle_shift, false)

func build_creature():
	add_first_node()
	add_possible_nodes()
	force_add_remaining_nodes()

func add_first_node():
	var lowest_id = 0
	while not physical_genome.has(str(lowest_id)):
		lowest_id += 1
	var id = str(lowest_id)
	if id != "0":
		physical_genome["0"] = physical_genome[id]
		physical_genome["0"]["parent_id"] = "0"	
		physical_genome.erase(id)
	add_node("0", Vector2(0, 0))
	root_node = nodes["0"]["object"]

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
	set_process_input(true)
	Behavior.creature = self
	build_creature()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Behavior.process_behavior(delta)

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

	body.rotation_degrees += propulsion_angle_sum * delta * 2
	var move_vector = propulsion_vector_sum.rotated(deg_to_rad(body.rotation_degrees)) * delta * 5

	if move_vector.length() <= max_speed:
		self.position += move_vector
	else:
		self.position += move_vector / move_vector.length() * max_speed

	handle_interactions(delta)

# On second thought, we should probably move this functionality into the tile, and have the tile apply any affects it needs or wants onto the creature
# Ill leave it here for now though while I think it through.
func handle_interactions(delta):
	var _pos = Vector2i(get_parent().position)
	var global_pos = Vector2i(get_parent().global_position)
	var tile = world.GetTile(global_pos)
	handle_pressure(delta, tile);
	handle_lightlevel(delta, tile);
	handle_temperature(delta, tile);
	handle_tiletype(delta, tile);
	
	update_label(delta, tile);
	
func update_label(_delta, tile):
	var terrainLabel = get_node("TerrainLabel")
	if tile != null:
		terrainLabel.text = str(tile.Coordinates);
		terrainLabel.text += "\nHealth: " + str(health.health);
		terrainLabel.text += "\nTerrain: " + str(tile.TerrainType);
		terrainLabel.text += "\nTemperature: " + str(tile.Temperature);

func handle_tiletype(_delta, _tile):
	pass
	
func handle_pressure(_delta, _tile):
	pass

func handle_lightlevel(_delta, _tile):
	pass

var temp_timer = 0;
func handle_temperature(delta, tile):
	if tile:
		if tile.Temperature >= 1:
			temp_timer += delta
		if temp_timer > 2:
			health.Damage(tile.Temperature)
			if health.health <= 0:
				die()
			temp_timer = 0

signal creature_died(creature_index);
func die():
	creature_died.emit(creature_index)
