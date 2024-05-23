# Status stores information about the node and responds accordingly
extends Node

@onready var NodeObject = get_parent()
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureStatus = Creature.get_node("Status")
@onready var genes = CreatureStatus.physical_genome.values()[NodeObject.id]
@onready var origin = (NodeObject.get_parent().name == "Body")

var joint_color = Color(0, 0, 0, 1)

# The node's position relative to its parent upon being created
# Nodes gradually drift toward their home_position
var home_position = Vector2(0, 0)
var home_rotation = 0

var consumption_rate = 0.25
func consume_energy(delta):
	if consumed == false:
		if CreatureStatus.energy > 0:
			if genes["type"] == "body":
				CreatureStatus.energy -= consumption_rate * genes["max_integrity"] * delta
			else:
				CreatureStatus.energy -= consumption_rate * genes["effectiveness"] * delta * 0.5
				CreatureStatus.energy -= consumption_rate * genes["max_integrity"] * delta * 0.5
			CreatureStatus.energy = max(0, CreatureStatus.energy)
		else:
			CreatureStatus.consume_integrity(consumption_rate * delta)

var consumed = false
@onready var integrity = 100 * genes["max_integrity"]
func get_hurt(amount):
	if integrity > 0:
		integrity -= amount
		integrity = max(0, integrity)
		NodeObject.queue_redraw()
		if integrity == 0:
			CreatureStatus.is_dead()

func _physics_process(delta):
	consume_energy(delta)
