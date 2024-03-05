extends Node2D

# Passed by creator
var id

@onready var ParentNode = get_parent()
@onready var Creature = ParentNode.Creature
@onready var CreatureGrowth = Creature.get_node("Growth")
@onready var CreatureStatus = Creature.get_node("Status")

@onready var Area = get_node("Area")
@onready var Resources = Creature.get_node("../../Resources")
@onready var Sprite = get_node("Sprite")
@onready var Status = get_node("Status")

# Call update_position whenever pivot_angle is changed
func update_position():
	if not Status.origin:
		position = Vector2(CreatureStatus.node_distance, 0).rotated(deg_to_rad(rotation_degrees))
	update_angle()

# Call update_angle whenever position is changed
func update_angle():
	var angle = rad_to_deg(ParentNode.position.angle_to_point(position))
	if angle < 0:
		angle += 360
	rotation_degrees = angle

func initialize_position():
	rotation_degrees = Status.genes["angle"]
	update_position()
	Status.home_position = position

func initialize_sprite():
	Sprite.texture = Resources.textures[Status.genes["type"]]

func initialize_connection():
	if not Status.origin:
		if Status.genes["joint"] == "pivot":
			Status.joint_color = Color(1, 0, 0, 1)
	else:
		Status.joint_color = Color(0, 0, 0, 0)

func initialize_scale():
	var node_width = Sprite.texture.get_width()
	Sprite.scale.x = Status.genes["size"] / node_width
	Sprite.scale.y = Status.genes["size"] / node_width
	Area.scale.x = Status.genes["size"] / node_width
	Area.scale.y = Status.genes["size"] / node_width

func _ready():
	if not Status.origin:
		initialize_position()
	initialize_sprite()
	initialize_connection()
	update_angle()
	initialize_scale()

func _draw():
	draw_line(Vector2(0, 0), -1 * position.rotated(deg_to_rad(-1 * rotation_degrees)), Status.joint_color, 1, false)
