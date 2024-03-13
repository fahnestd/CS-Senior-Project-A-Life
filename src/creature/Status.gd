# Status stores information about the creature as a whole and responds accordingly
extends Node

@onready var Creature = get_parent()

# How far away nodes are from each other
var node_distance = 20

# Max length of velocity vector per frame
var max_speed = 1

# Default behavioral genome. TODO: Gets set to a crossover of the creature's parents after it is born.
var behavioral_genome = {
	0: {
		"if" = {
			"angle diff" = {
				"conditional" = "lessEqual",
				"value" = -10
			}
		},
		"pattern" = {
			0: {
				0: 20.0,
				1: 20.0,
				"time": 0.25
			},
			1: {
				0: -20.0,
				1: -20.0,
				"time": 1.0
			}
		}
	},
	1: {
		"if" = {
			"angle diff" = {
				"conditional" = "greaterEqual",
				"value" = 10
			}
		},
		"pattern" = {
			0: {
				0: -20.0,
				1: -20.0,
				"time": 0.25
			},
			1: {
				0: 20.0,
				1: 20.0,
				"time": 1.0
			}
		}
	},
	2: {
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
			0: {
				0: 10.0,
				1: 10.0,
				"time": 0.25
			},
			1: {
				0: -10.0,
				1: -10.0,
				"time": 1.0
			}
		}
	},
	3: {
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
			0: {
				0: -10.0,
				1: -10.0,
				"time": 0.25
			},
			1: {
				0: 10.0,
				1: 10.0,
				"time": 1.0
			}
		}
	},
	4: {
		"pattern" = {
			0: {
				0: 40.0,
				1: -40.0,
				"time": 0.5
			},
			1: {
				0: -40.0,
				1: 40.0,
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
		"type": "eye"
	},
	1: {
		"parent_id": 0,
		"angle": 0,
		"size": 10.0,
		"joint": "fixed",
		"type": "reproduction"
	},
	2: {
		"parent_id": 0,
		"angle": 120,
		"size": 10.0,
		"joint": "pivot",
		"type": "body"
	},
	3: {
		"parent_id": 0,
		"angle": -120,
		"size": 10.0,
		"joint": "pivot",
		"type": "body"
	}
}
# Larger preset
#var physical_genome = {
	#0: {
		#"parent_id": 0,
		#"angle": 0,
		#"size": 10.0,
		#"joint": "fixed",
		#"type": "eye"
	#},
	#1: {
		#"parent_id": 0,
		#"angle": 0,
		#"size": 10.0,
		#"joint": "fixed",
		#"type": "reproduction"
	#},
	#2: {
		#"parent_id": 0,
		#"angle": 120,
		#"size": 10.0,
		#"joint": "pivot",
		#"type": "body"
	#},
	#3: {
		#"parent_id": 0,
		#"angle": -120,
		#"size": 10.0,
		#"joint": "pivot",
		#"type": "body"
	#},
	#4: {
		#"parent_id": 2,
		#"angle": 0,
		#"size": 10.0,
		#"joint": "fixed",
		#"type": "body"
	#},
	#5: {
		#"parent_id": 3,
		#"angle": 0,
		#"size": 10.0,
		#"joint": "fixed",
		#"type": "body"
	#}
#}

# TODO: Replace health with the energy system
var health = 100

# How many seconds delay between reproducing
var reproduction_cooldown = 5
# Counts down to 0 over time, gets set to reproduction_cooldown after reproducing
var reproduction_cooldown_progress = reproduction_cooldown

# TODO: Remove when node death is implemented and creatures eat dead nodes
func is_dead():
	if health <= 0:
		Creature.queue_free()

func reset_reproduction_cooldown():
	reproduction_cooldown_progress = reproduction_cooldown

# Reduces cooldown variable to 0 over time
func cooldown(delta):
	if reproduction_cooldown_progress > 0:
		reproduction_cooldown_progress = max(0, reproduction_cooldown_progress - delta)

func _physics_process(delta):
	is_dead()
	cooldown(delta)
