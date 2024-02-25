extends Node

var creature_scene = preload("res://creature.tscn")

@onready var world = get_node("../World")

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
			"parent_id": "0",
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


func _ready():
	var creature1 = create_creature((world.GetSpawnCoordinates() - Vector2(10, 2)) * world.GetTileSize(), 0, default_physical_genome)
	build_creature(creature1)
	var creature2 = create_creature((world.GetSpawnCoordinates() + Vector2(10, 2)) * world.GetTileSize(), 180, default_physical_genome)
	build_creature(creature2)

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
	self.get_parent().add_child.call_deferred(new_creature)
	return new_creature

func build_creature(creature):
	var physical_genome = creature.get_node('PhysicalGenome').physical_genome
	var root_node = physical_genome["0"]
	for key in physical_genome:
		add_node(key, physical_genome[key])

func add_node(id, node_plan):
	if node_plan["type"] == "eye":
		var eye_node = preload("res://src/creature/nodes/Eye.tscn").instantiate()
		eye_node.get_node("Area2D").initialize(self)
		eye_node.size = node_plan["size"]
		eye_node.node_id = node_plan["id"]
		eye_node.scale.x = node_plan["size"]
		eye_node.scale.y = node_plan["size"]
		get_node('Body').add_child(eye_node)
		#move_node(id, Vector2(0, 0), false)
	if node_plan["type"] == "reproduction":
		var reproduction_node = preload("res://src/creature/nodes/Reproduction.tscn").instantiate()
		#reproduction_node.connect(_on_reproduce)		
		get_node('Body').add_child(reproduction_node)
		#move_node(id, Vector2(0, 0), false)

func add_connected_node(id):
	#var node = physical_genome[id]
	#var parent_id = node["parent_id"]
	#var parent_node = nodes[parent_id]
	#var new_sprite = Sprite2D.new()
	#body.add_child(new_sprite)
	#new_sprite.offset.x = 0.5
	#new_sprite.position = parent_node.position
	#new_sprite.rotation_degrees = node["angle"]
	#new_sprite.scale.x = connection_distance
	#new_sprite.texture = textures[node["joint"]]
	#new_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	#new_sprite.z_index = 1
	pass


func add_possible_nodes():
	var added_node = false
	while added_node and nodes.size() != physical_genome.size():
		added_node = false
		for id in physical_genome.keys():
			if not nodes.has(id):
				var parent_id = physical_genome[id]["parent_id"]
				if nodes.has(parent_id):
					add_connected_node(id)
					added_node = true

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
