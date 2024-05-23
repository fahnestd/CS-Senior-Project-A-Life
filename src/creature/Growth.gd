# Growth determines the order of node creation and builds the node structure
extends Node

@onready var Behavior = get_node("../Behavior")
@onready var Body = get_node("../Body")
@onready var Creature = get_parent()
@onready var Status = get_node("../Status")
@onready var Utility = get_node("../../../Utility")

var node_scenes = {
	"body" = preload("res://src/scenes/node.tscn"),
	"reproduction" = preload("res://src/scenes/reproduction.tscn"),
	"eye" = preload("res://src/scenes/eye.tscn"),
	"mouth" = preload("res://src/scenes/mouth.tscn"),
	"sharp" = preload("res://src/scenes/sharp.tscn")
}

# Contains nodes that have been grown
var nodes = {}

# List of node ids corresponding to the physical genome in the order that they should be created
# {order: node id}
var growth_order = {}

# Determines the order that nodes should grow in
# Ensures that all nodes in the genome will connect to existing nodes
func initialize_growth_order():
	var nodes_to_add = Status.physical_genome.duplicate()
	growth_order[0] = nodes_to_add.keys().min()
	nodes_to_add.erase(growth_order[0])
	var tolerance = 0
	while nodes_to_add.size() > 0:
		var added_node = false
		for key in nodes_to_add.keys():
			var parent_id = Status.physical_genome[key]["parent_id"]
			for key2 in growth_order.values():
				if abs(key2 - parent_id) <= tolerance:
					Status.physical_genome[key]["parent_id"] = key2
					Utility.dictionary_append(growth_order, key)
					nodes_to_add.erase(key)
					added_node = true
					break
		if not added_node:
			tolerance += 1

func fully_grow():
	while nodes.size() < growth_order.size():
		add_node(growth_order[nodes.size()])

# Creates a node instance as a child of body or its parent
func add_node(id):
	var node_genes = Status.physical_genome[id]
	var node = node_scenes[node_genes["type"]].instantiate()
	node.id = nodes.size()
	if nodes.size() == 0:
		Body.add_child.call_deferred(node)
	else:
		nodes[node_genes["parent_id"]].add_child.call_deferred(node)
	if node_genes["joint"] == "pivot":
		Utility.dictionary_append(Behavior.pivot_nodes, node)
	nodes[id] = node

func _ready():
	initialize_growth_order()
	fully_grow()
