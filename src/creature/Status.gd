# Status stores information about the creature as a whole and responds accordingly
extends Node

@onready var Creature = get_parent()
@onready var Growth = get_node("../Growth")
#@onready var SpeciesManager = get_node("SpeciesManager")

signal creature_dead(creature)

var energy = 100

# How far away nodes are from each other
var node_distance = 20

# Max length of velocity vector per frame
var max_speed = 1

# Default behavioral genome. Gets set to a crossover of the creature's parents after it is born.
var behavioral_genome = {
	0: {
		"target" = {
			"target_type" = "Food",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "lessEqual",
			"condition_value" = -20,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: -20.0,
					1: -20.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: 20.0,
					1: 20.0
				},
				"time": 1.0
			}
		}
	},
	1: {
		"target" = {
			"target_type" = "Food",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "greaterEqual",
			"condition_value" = 20,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 20.0,
					1: 20.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -20.0,
					1: -20.0
				},
				"time": 1.0
			}
		}
	},
	2: {
		"target" = {
			"target_type" = "Food",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "lessEqual",
			"condition_value" = -5,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: -10.0,
					1: -10.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: 10.0,
					1: 10.0
				},
				"time": 1.0
			}
		}
	},
	3: {
		"target" = {
			"target_type" = "Food",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "greaterEqual",
			"condition_value" = 5,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 10.0,
					1: 10.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -10.0,
					1: -10.0
				},
				"time": 1.0
			}
		}
	},
	4: {
		"target" = {
			"target_type" = "Food",
			"target_classifier" = "different_species"
		},
		"condition" = {
			"condition_type" = "none",
			"condition_comparison" = null,
			"condition_value" = null,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 40.0,
					1: -40.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -40.0,
					1: 40.0
				},
				"time": 1.0
			}
		}
	},
	5: {
		"target" = {
			"target_type" = "Reproduction",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "lessEqual",
			"condition_value" = -20,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: -20.0,
					1: -20.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: 20.0,
					1: 20.0
				},
				"time": 1.0
			}
		}
	},
	6: {
		"target" = {
			"target_type" = "Reproduction",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "greaterEqual",
			"condition_value" = 20,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 20.0,
					1: 20.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -20.0,
					1: -20.0
				},
				"time": 1.0
			}
		}
	},
	7: {
		"target" = {
			"target_type" = "Reproduction",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "lessEqual",
			"condition_value" = -5,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: -10.0,
					1: -10.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: 10.0,
					1: 10.0
				},
				"time": 1.0
			}
		}
	},
	8: {
		"target" = {
			"target_type" = "Reproduction",
			"target_classifier" = "same_species"
		},
		"condition" = {
			"condition_type" = "angle_difference",
			"condition_comparison" = "greaterEqual",
			"condition_value" = 5,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 10.0,
					1: 10.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -10.0,
					1: -10.0
				},
				"time": 1.0
			}
		}
	},
	9: {
		"target" = {
			"target_type" = "none",
			"target_classifier" = "self"
		},
		"condition" = {
			"condition_type" = "none",
			"condition_comparison" = null,
			"condition_value" = null,
			"and" = null,
			"or" = null
		},
		"pattern" = {
			0: {
				"steps": {
					0: 40.0,
					1: -40.0
				},
				"time": 0.25
			},
			1: {
				"steps": {
					0: -40.0,
					1: 40.0
				},
				"time": 1.0
			}
		}
	}
}

# Default physical genome. Gets set to a crossover of the creature's parents after it is born.
# Small Preset
var physical_genome = {
	0: {
		"parent_id": 0,
		"angle": 0,
		"size": 10.0,
		"joint": "fixed",
		"type": "reproduction",
		"max_integrity": 1.0,
		"effectiveness": 1.0
	},
	1: {
		"parent_id": 0,
		"angle": 0,
		"size": 10.0,
		"joint": "fixed",
		"type": "mouth",
		"max_integrity": 1.0,
		"effectiveness": 1.0
	},
	2: {
		"parent_id": 0,
		"angle": 120,
		"size": 10.0,
		"joint": "pivot",
		"type": "body",
		"max_integrity": 1.0,
		"effectiveness": 1.0
	},
	3: {
		"parent_id": 0,
		"angle": -120,
		"size": 10.0,
		"joint": "pivot",
		"type": "body",
		"max_integrity": 1.0,
		"effectiveness": 1.0
	},
	4: {
		"parent_id": 0,
		"angle": 180,
		"size": 10.0,
		"joint": "fixed",
		"type": "eye",
		"max_integrity": 1.0,
		"effectiveness": 1.0
	}
}

# How many seconds delay between reproducing
var reproduction_cooldown = 30
# Counts down to 0 over time, gets set to reproduction_cooldown after reproducing
var reproduction_cooldown_progress = reproduction_cooldown

var dead = false
func is_dead():
	if not dead:
		for node in Growth.nodes.values():
			if node.Status.integrity > 0:
				return
		emit_signal("creature_dead", Creature)
		dead = true
		#SpeciesManager.creature_dead(Creature)

func clear_skeleton():
	if dead:
		for node in Growth.nodes.values():
			if node.Status.consumed == false:
				return
		Creature.queue_free()

func reset_reproduction_cooldown():
	reproduction_cooldown_progress = reproduction_cooldown

# Reduces cooldown variable to 0 over time
func cooldown(delta):
	if reproduction_cooldown_progress > 0:
		reproduction_cooldown_progress = max(0, reproduction_cooldown_progress - delta)

# Called when creature is out of energy
# Drains an equivalent amount from node integrity instead
func consume_integrity(amount):
	for node in Growth.nodes.values():
		node.Status.get_hurt(amount)

func _physics_process(delta):
	cooldown(delta)
