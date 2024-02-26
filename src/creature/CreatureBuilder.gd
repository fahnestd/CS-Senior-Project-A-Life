extends Node

var creature_scene = preload("res://creature.tscn")

@onready var world = get_node("../World")
@onready var genome_mixer = get_node("../GenomeMixer")

var connection_distance = 20

var behavioral_genome = {
	"0" = {
		"if" = {
			"angle diff" = {
				"conditional" = "lessEqual",
				"value" = -10
			}
		},
		"pattern" = {
			"0" = {
				"0" = 20.0,
				"1" = 20.0,
				"time" = 0.25
			},
			"1" = {
				"0" = -20.0,
				"1" = -20.0,
				"time" = 1.0
			}
		}
	},
	"1" = {
		"if" = {
			"angle diff" = {
				"conditional" = "greaterEqual",
				"value" = 10
			}
		},
		"pattern" = {
			"0" = {
				"0" = -20.0,
				"1" = -20.0,
				"time" = 0.25
			},
			"1" = {
				"0" = 20.0,
				"1" = 20.0,
				"time" = 1.0
			}
		}
	},
	"2" = {
		"if" = {
			"angle diff" = {
				"conditional" = "lessEqual",
				"value" = -5,
				"and" = {
					"angle diff" = {
						"conditional" = "greater",
						"value" = -10
					}
				}
			}
		},
		"pattern" = {
			"0" = {
				"0" = 10.0,
				"1" = 10.0,
				"time" = 0.25
			},
			"1" = {
				"0" = -10.0,
				"1" = -10.0,
				"time" = 1.0
			}
		}
	},
	"3" = {
		"if" = {
			"angle diff" = {
				"conditional" = "greaterEqual",
				"value" = 5,
				"and" = {
					"angle diff" = {
						"conditional" = "less",
						"value" = 10
					}
				}
			}
		},
		"pattern" = {
			"0" = {
				"0" = -10.0,
				"1" = -10.0,
				"time" = 0.25
			},
			"1" = {
				"0" = 10.0,
				"1" = 10.0,
				"time" = 1.0
			}
		}
	},
	"4" = {
		"pattern" = {
			"0" = {
				"0" = 40.0,
				"1" = -40.0,
				"time" = 0.5
			},
			"1" = {
				"0" = -40.0,
				"1" = 40.0,
				"time" = 1.0
			}
		}
	}
}

var default_physical_genome = {
		"0" = {
			"parent_id": "",
			"angle": 0,
			"size": 10.0,
			"joint": "fixed",
			"type": "eye"
		},
		"1" = {
			"parent_id": "0",
			"angle": 0,
			"size": 10.0,
			"joint": "fixed",
			"type": "reproduction"
		},
		"2" = {
			"parent_id": "0",
			"angle": 120,
			"size": 10.0,
			"joint": "pivot",
			"type": "body"
		},
		"3" = {
			"parent_id": "0",
			"angle": 240,
			"size": 10.0,
			"joint": "pivot",
			"type": "body"
		}
	}

# Generate 2 starter creatures
func _ready():
	var creature1 = create_creature((world.GetSpawnCoordinates() - Vector2(10, 2)) * world.GetTileSize(), 0, default_physical_genome)
	build_creature(creature1)
	var creature2 = create_creature((world.GetSpawnCoordinates() + Vector2(10, 2)) * world.GetTileSize(), 180, default_physical_genome)
	build_creature(creature2)

# Generate a new creature
func create_creature(pos, rot, physical_genome):
	var new_creature = creature_scene.instantiate()
	
	# Setup Creature genomes
	new_creature.get_node('BehavioralGenome').behavioral_genome = behavioral_genome
	new_creature.get_node('PhysicalGenome').physical_genome = physical_genome
	
	# Rotate and place the creature to start position
	new_creature.global_position = pos
	new_creature.get_node("Body").rotation_degrees = rot
	
	#signal handlers
	#new_creature.reproduce.connect(_on_reproduce)
	#new_creature.creature_died.connect(_on_creature_died)
	#creature_info.emit(physical_genome)
	
	# add the creature to the mainscene node.
	self.get_node("../Creatures").add_child.call_deferred(new_creature)
	return new_creature

func build_creature(creature):
	var physical_genome = creature.get_node('PhysicalGenome').physical_genome
	add_node(creature, physical_genome, physical_genome["0"], "0")
	

func add_node(creature, genome, node_plan, node_id, parent_node = null):
	var node
	if node_plan["type"] == "eye":
		node = preload("res://src/creature/nodes/Eye.tscn").instantiate()
		node.scale_node(node_plan["size"])
		node.node_plan = node_plan
		node.parent = parent_node
		creature.get_node('Body').add_child(node)
		fix_connection_length(creature, node)
	if node_plan["type"] == "reproduction":
		node = preload("res://src/creature/nodes/Reproduction.tscn").instantiate()
		#node.connect(_on_reproduce)		
		node.parent = parent_node	
		creature.get_node('Body').add_child(node)
		fix_connection_length(creature, node)			
		#move_node(id, Vector2(0, 0), false)
		
	# Add other nodes
	var child_nodes = node_plan_filter_children(creature.get_node('PhysicalGenome').physical_genome, node_id)
	for child_node in child_nodes:
		add_node(creature, genome, genome[child_node], child_node, node)


func node_plan_filter_children(plan, node_id):
	var filtered = {}
	for key in plan.keys():
		if plan[key]["parent_id"] == null:
			continue
		if plan[key]["parent_id"] == node_id:
			filtered[key] = plan[key]
	return filtered
	
#func initialize_leg_node(node, pos):
	#node["position"] = pos
	#node["object"].position = pos
	#new_sprite.offset.x = 0.5
	#new_sprite.position = parent_node.position
	#new_sprite.rotation_degrees = node["angle"]
	#new_sprite.scale.x = connection_distance
	#new_sprite.texture = textures[node["joint"]]
	#new_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	#new_sprite.z_index = 1

func fix_connection_length(creature, node):
	if node.parent != null:
		var direction = node.parent["position"] - node["position"]
		var distance = direction.length()
		direction = direction / distance

		if distance > connection_distance:
			distance *= 0.9
			distance = max(connection_distance, distance)
		elif distance < connection_distance:
			distance *= 1.1
			distance = min(connection_distance, distance)

		var new_node_pos =  node.parent["position"] - direction * distance
		
		if new_node_pos != node["position"]:
			node["position"] = new_node_pos



#func add_possible_nodes():
	#var added_node = false
	#while added_node and nodes.size() != physical_genome.size():
		#added_node = false
		#for id in physical_genome.keys():
			#if not nodes.has(id):
				#var parent_id = physical_genome[id]["parent_id"]
				#if nodes.has(parent_id):
					#add_connected_node(id)
					#added_node = true
#
#func force_add_remaining_nodes():
	#if nodes.size() != physical_genome.size():
		#for id in physical_genome.keys():
			#if not nodes.has(id):
				#var parent_id = int(physical_genome[id]["parent_id"])
				#while not nodes.has(str(parent_id)):
					#parent_id -= 1
					#if parent_id < 0:
						#parent_id = int(physical_genome[id]["parent_id"]) + 1
						#while not nodes.has(str(parent_id)):
							#parent_id += 1
				#physical_genome[id]["parent_id"] = str(parent_id)
				#add_connected_node(id)
