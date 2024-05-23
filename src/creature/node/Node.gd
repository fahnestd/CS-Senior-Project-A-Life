extends Node2D

# Passed by creator
var id

@onready var ParentNode = get_parent()
@onready var Creature = ParentNode.Creature
@onready var CreatureGrowth = Creature.get_node("Growth")
@onready var CreatureMotion = Creature.get_node("Motion")
@onready var CreatureStatus = Creature.get_node("Status")

@onready var Area = get_node("Area")
@onready var Collision = Area.get_node("Collision")
@onready var Resources = get_node("/root/MainScene/Resources")
@onready var Sprite = get_node("Sprite")
@onready var Status = get_node("Status")
@onready var Utility = get_node("/root/MainScene/Utility")

func global_move(position_shift, propulsion, colliding_with_other_creature):
	if not Status.origin:
		global_position += position_shift
	elif colliding_with_other_creature:
		Creature.global_position += position_shift
	if propulsion:
		CreatureMotion.add_propulsion_position(position_shift)
	queue_redraw()

func move(position_shift, propulsion):
	if not Status.origin:
		position += position_shift
	else:
		Creature.position += position_shift
	if propulsion:
		CreatureMotion.add_propulsion_position(position_shift)
	update_angle(propulsion)
	queue_redraw()

func turn(angle_shift, propulsion):
	rotation_degrees += angle_shift
	rotation_degrees = Utility.angle_clamp(rotation_degrees)
	if propulsion:
		CreatureMotion.add_propulsion_angle(angle_shift)
	update_position(propulsion)

# Typically used by move() or turn()
func update_position(propulsion):
	if not Status.origin:
		var initial_position = position
		position = Vector2(CreatureStatus.node_distance, 0).rotated(rotation)
		if propulsion:
			CreatureMotion.add_propulsion_position(initial_position - position)
	queue_redraw()

# Typically used by move() or turn()
func update_angle(propulsion):
	var initial_angle = rotation_degrees
	var angle = Utility.angle_clamp(rad_to_deg(ParentNode.position.angle_to_point(position)))
	var angle_diff = Utility.angle_clamp(initial_angle - angle)
	if propulsion:
		CreatureMotion.add_propulsion_angle(angle_diff)
	rotation_degrees = Utility.angle_clamp(angle)

func initialize_position():
	rotation_degrees = Status.genes["angle"]
	update_position(false)
	Status.home_position = position
	Status.home_rotation = rotation_degrees

func initialize_connection():
	if not Status.origin:
		if Status.genes["joint"] == "pivot":
			Status.joint_color = Color(1, 0, 0, 1)
	else:
		Status.joint_color = Color(0, 0, 0, 0)

var fourth_size
func initialize_scale():
	var node_width = Sprite.texture.get_width()
	var size_scale = Status.genes["size"] / node_width
	fourth_size = Status.genes["size"] / 4.
	Sprite.scale.x = size_scale
	Sprite.scale.y = size_scale
	Area.scale.x = size_scale
	Area.scale.y = size_scale

func _ready():
	if not Status.origin:
		initialize_position()
	initialize_connection()
	initialize_scale()

func _physics_process(delta):
	if not Status.origin:
		drift_home(delta)

func drift_home(delta):
	if position != Status.home_position:
		var difference = Status.home_position - position
		move(difference * delta * 0.5, false)
	elif rotation_degrees != Status.home_rotation:
		var difference = Utility.angle_clamp(Status.home_rotation - rotation_degrees)
		turn(difference * delta * 0.5, false)

func _draw():
	if not Status.origin:
		draw_line(Vector2(0, 0), to_local(ParentNode.global_position), Status.joint_color, 1, false)
	draw_circle(Vector2(0, 0), fourth_size, Color(0, 1, 0) * Status.integrity / 100. + Color(1, 0, 0) * (1 - Status.integrity / 100.))

func get_consumed():
	Status.consumed = true
	Sprite.visible = false
	Collision.set_deferred("disabled", true)
	CreatureStatus.clear_skeleton()
