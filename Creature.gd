extends Node2D

#Changeable parameters
var connection_distance = 40
var num_nodes = 40
var proximity = 40 #The number of most recent nodes that can serve as origins for new nodes. A value of 1 results in a snake-like chain, whereas a value of num_nodes will make a circular shape.
var distance_fix = true #Whether or not connections should adjust themselves to try to maintain the connection_distance
var camera_enabled = false #Whether or not the camera should follow the most recently generated node.

var node_texture = preload("res://circle.png")
var connector_texture = preload("res://connector.png")

#Do not print the entire contents of a node, since it is a dictionary that recursively references itself.
#This will also cause errors when debugging that you can ignore.
var nodes = []
var distance_fix_nodes = []

var frame = 0
var generated_nodes = 1
var camera

func add_node(pos, size):
	var new_node = {
		"position": pos,
		"size": size
	}

	nodes.append(new_node)

	var new_area = Area2D.new()

	var new_sprite = Sprite2D.new()
	new_sprite.texture = node_texture
	new_sprite.scale.x = size / 10.0
	new_sprite.scale.y = size / 10.0
	new_area.add_child(new_sprite)

	var new_collision = CollisionShape2D.new()
	var new_rectangle = RectangleShape2D.new()
	new_rectangle.size = Vector2(size - 1, size - 1)
	new_collision.shape = new_rectangle

	new_area.add_child(new_collision)

	new_area.position = pos
	new_area.script = load("res://Area2D.gd")
	new_area.size = Vector2(size, size)
	new_area.node = new_node

	add_child(new_area)
	new_node["area"] = new_area

	move_node(new_node, pos)
	
	return new_node

func move_node(node, pos):
	node["position"] = pos
	node["area"].position = pos

	if node.has("origin_connections"):
		for i in node["origin_connections"]:
			move_connection(i, i["endpoint"]["position"])

	if node.has("endpoint_connection"):
		move_connection(node["endpoint_connection"], pos)
	
	distance_check(node)

func move_connection(connection, endpoint):
	var origin = connection["origin"]["position"]
	var distance = (endpoint - origin).length()
	var angle = rad_to_deg(origin.angle_to_point(endpoint))

	connection["sprite"].position = origin
	connection["sprite"].rotation_degrees = angle
	connection["sprite"].scale.x = distance
	connection["length"] = round(distance * 100.0) / 100.0

func distance_check(node):
	if node.has("origin_connections"):
		for i in node["origin_connections"]:
			if distance_fix and abs(i["length"] - connection_distance) > connection_distance * 0.25:
				if i["endpoint"] not in distance_fix_nodes:
					distance_fix_nodes.append(i["endpoint"])

	if node.has("endpoint_connection"):
		if distance_fix and abs(node["endpoint_connection"]["length"] - connection_distance) > connection_distance * 0.25:
			if node not in distance_fix_nodes:
				distance_fix_nodes.append(node)

func fix_connection_length(node):
	var connection = node["endpoint_connection"]
	var direction = connection["endpoint"]["position"] - connection["origin"]["position"]
	var distance = direction.length()
	direction = direction / distance
	
	if distance > connection_distance:
		distance *= 0.99
		distance = max(connection_distance * 0.75, distance)
	elif distance < connection_distance:
		distance *= 1.01
		distance = min(connection_distance * 1.25, distance)

	var new_endpoint = connection["origin"]["position"] + direction * distance
	move_node(connection["endpoint"], new_endpoint)

func add_connected_node(origin_node, angle, size):
	var new_sprite = Sprite2D.new()
	add_child(new_sprite)
	new_sprite.offset.x = 0.5
	new_sprite.position = origin_node.position
	new_sprite.rotation_degrees = angle
	new_sprite.scale.x = connection_distance
	new_sprite.texture = connector_texture
	new_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	new_sprite.z_index = -1

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(angle))
	var endpoint = origin_node.position + connection_distance * dir_vector

	var endpoint_node = add_node(endpoint, size)

	var new_connection = {
		"sprite": new_sprite,
		"origin": origin_node,
		"endpoint": endpoint_node,
		"length": connection_distance
	}

	if origin_node.has("origin_connections"):
		origin_node["origin_connections"].append(new_connection)
	else:
		origin_node["origin_connections"] = [new_connection]
	endpoint_node["endpoint_connection"] = new_connection

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("../Creature/Camera2D")
	add_node(Vector2(0, 0), 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frame > 0:
		while generated_nodes < num_nodes:
			add_connected_node(nodes[randi_range(max(0, len(nodes) - proximity), len(nodes) - 1)], randi_range(0, 360), 10)
			generated_nodes += 1

		if camera_enabled:
			camera.position = nodes[len(nodes) - 1]["position"]
		else:
			camera.position = nodes[0]["position"]
	else:
		frame += 1

	if distance_fix:
		var distance_fix_copy = []

		for i in distance_fix_nodes:
			fix_connection_length(i)
			distance_fix_copy.append(i)

		distance_fix_nodes = []

		for i in distance_fix_copy:
			distance_check(i)
