# Status stores information about the node and responds accordingly
extends Node

@onready var NodeObject = get_parent()
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureStatus = Creature.get_node("Status")
@onready var genes = CreatureStatus.physical_genome[NodeObject.id]
@onready var origin = (NodeObject.get_parent().name == "Body")

var joint_color = Color(0, 0, 0, 1)

# The node's position relative to its parent upon being created
# TODO: Nodes gradually drift toward their home_position
var home_position = Vector2(0, 0)
var home_rotation = 0

# TODO: Put node health here
