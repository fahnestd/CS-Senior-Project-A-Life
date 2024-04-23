extends Node2D

var energy_value
var rng = RandomNumberGenerator.new()

const MIN_ENERGY_VALUE = 10
const MAX_ENERGY_VALUE = 50

func _ready():
	energy_value = rng.randf_range(MIN_ENERGY_VALUE, MAX_ENERGY_VALUE)
	get_node("DecayTimer").set_wait_time(energy_value * 2)
	get_node("DecayTimer").start()

func _on_decay_timer_timeout():
	get_parent().queue_free()
