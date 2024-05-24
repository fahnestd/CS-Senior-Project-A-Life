extends Area2D

@onready var NodeObject = get_parent()
@onready var Status = NodeObject.get_node("Status")
@onready var Creature = NodeObject.get_parent().Creature
@onready var CreatureBehavior = Creature.get_node("Behavior")
@onready var Collision = get_node("Collision")

func _ready():
	Collision.scale.x = Status.genes["effectiveness"]
	Collision.scale.y = Status.genes["effectiveness"]
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
func _physics_process(delta):
	var shape = get_node("Collision").shape 
	shape.set_radius( 200 - (40 * Creature.visibility_factor))

func _on_area_entered(other_area):
	if Status.integrity != 0:
		if other_area.name == "Food" or other_area.get_parent().Creature != Creature:
			if other_area.name != "Eye" and other_area.name != "Ear":
				var other_node = other_area.get_parent()
				CreatureBehavior.visible_nodes[other_node] = other_node.global_position

func _on_area_exited(other_area):
	if other_area.name == "Food" or other_area.get_parent().Creature != Creature:
		if other_area.name != "Eye" and other_area.name != "Ear":
			var other_node = other_area.get_parent()
			CreatureBehavior.visible_nodes.erase(other_node)
