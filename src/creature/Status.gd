# Status stores information about the creature as a whole and responds accordingly
extends Node

@onready var Creature = get_parent()

# How far away nodes are from each other
var node_distance = 20

# Max length of velocity vector per frame
var max_speed = 1

# Default behavioral genome. Gets set to a crossover of the creature's parents after it is born.
var behavioral_genome = {
	0: {
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
	1: {
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
	2: {
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
	3: {
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
	4: {
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
