extends Node2D

var physical_genome = {
	node_plan = {
		"0" = {
			"parent_id": "None",
			"angle": 0,
			"size": 10,
			"joint": "None"
		},
		"1" = {
			"parent_id": "0",
			"angle": 0,
			"size": 10,
			"joint": "fixed"
		},
		"2" = {
			"parent_id": "0",
			"angle": 120,
			"size": 10,
			"joint": "pivot"
		},
		"3" = {
			"parent_id": "0",
			"angle": -120,
			"size": 10,
			"joint": "pivot"
		}
	}
}

var behavioral_genome = {
	"0" = {
		"pattern" = [[["2", 40.0], ["3", -40.0], 1.0], [["2", -40.0], ["3", 40.0], 1.0]]
	},
	"1" = {
		"pattern" = [[["2", 40.0], 1.0], [["2", -40.0], 1.0]]
	},
	"2" = {
		"pattern" = [[["3", -40.0], 1.0], [["3", 40.0], 1.0]]
	},
	"3" = {
		"pattern" = [[1.0]]
	}
}

# Changeable parameters
var connection_distance = 20
var max_speed = 1
var distance_fix = true # Whether or not connections should adjust themselves to try to maintain the connection_distance

var node_texture = preload("res://assets/creature/circle.png")
var node_width = node_texture.get_width()
var node_height = node_texture.get_height()
var fixed_texture = preload("res://assets/creature/fixed.png")
var pivot_texture = preload("res://assets/creature/pivot.png")

var node_plan = physical_genome["node_plan"].duplicate(true)
var nodes = {}

var propulsion_vector = Vector2(0, 0)
var propulsion_angle = 0
var inertia_vector = Vector2(0, 0)
var inertia_angle = 0

func add_node(id, pos):
	var node = node_plan[id]
	var size = node["size"]
	var angle = node["angle"]
	var new_node = {
		"position": pos,
		"size": size,
		"angle": angle
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
	new_area.script = load("res://src/Area2D.gd")
	new_area.size = Vector2(size, size)
	new_area.node_id = id

	add_child(new_area)
	new_node["area"] = new_area

	move_node(id, pos)

	return id

func add_connected_node(id):
	var node = node_plan[id]
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

func move_node(id, pos):
	var node = nodes[id]
	var old_pos = node["position"]
	var old_angle = node["angle"]
	node["position"] = pos
	node["area"].position = pos

	if node.has("child_connections"):
		for connection in node["child_connections"]:
			update_connection(connection)

	if node.has("parent_connection"):
		var parent_connection = node["parent_connection"]
		var parent_id = parent_connection["parent_id"]
		var parent_node = nodes[parent_id]
		var parent_pos = parent_node["position"]
		var angle = rad_to_deg(parent_pos.angle_to_point(pos))
		node["angle"] = angle
		update_connection(node["parent_connection"])

	propulsion_vector += pos - old_pos
	propulsion_angle += node["angle"] - old_angle

func update_connection(connection):
	var parent_id = connection["parent_id"]
	var parent_node = nodes[parent_id]
	var parent_pos = parent_node["position"]
	var child_id = connection["child_id"]
	var child_node = nodes[child_id]
	var child_pos = child_node["position"]
	var distance = (child_pos - parent_pos).length()
	var angle = child_node["angle"]

	connection["sprite"].position = parent_pos
	connection["sprite"].rotation_degrees = angle
	connection["sprite"].scale.x = distance
	connection["length"] = round(distance * 100.0) / 100.0

func fix_connection_length(child_id):
	var child_node = nodes[child_id]
	if child_node.has("parent_connection"):
		var connection = child_node["parent_connection"]
		var parent_id = connection["parent_id"]
		var parent_node = nodes[parent_id]
		var parent_pos = parent_node["position"]
		var direction = parent_pos - child_node["position"]
		var distance = direction.length()
		direction = direction / distance
		
		if distance > connection_distance * 2:
			distance *= 0.99
			distance = max(connection_distance * 0.5, distance)
		elif distance < connection_distance * 0.5:
			distance *= 1.01
			distance = min(connection_distance * 2, distance)

		var new_node_pos = parent_pos - direction * distance

		if new_node_pos != child_node["position"]:
			move_node(child_id, new_node_pos)

func pivot_node(id, angle_shift):
	var node = nodes[id]
	var parent_connection = node["parent_connection"]
	var parent_id = parent_connection["parent_id"]
	var parent_node = nodes[parent_id]
	var parent_pos = parent_node["position"]
	var distance = parent_connection["length"]

	var dir_vector = Vector2(1, 0).rotated(deg_to_rad(node["angle"] + angle_shift))
	var endpoint = parent_pos + distance * dir_vector
	move_node(id, endpoint)

# Called when the node enters the scene tree for the first time.
func _ready():
	while len(node_plan) > 0:
		for id in node_plan.keys():
			var parent_id = node_plan[id]["parent_id"]
			if parent_id == "None":
				add_node(id, Vector2(0, 0))
				node_plan.erase(id)
			elif nodes.has(parent_id):
				add_connected_node(id)
				node_plan.erase(id)

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
		var angle_change = behavior_step_angle * movement_percent
		pivot_node(behavior_step_node_id, angle_change)

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
		self.position -= inertia_vector
	else:
		self.position -= inertia_vector / inertia_vector.length() * max_speed

	inertia_vector *= 0.95
	inertia_angle *= 0.95

	if distance_fix:
		for id in nodes:
			fix_connection_length(id)
