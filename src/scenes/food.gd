extends Node2D

# NOTE: Food collision is set to layer 2!
# this means we can set mouths to interact with food nodes without having to filter out node types.

var energy_value
var rng = RandomNumberGenerator.new()

# Minimum and Maximum allowed energy value
const MIN_ENERGY_VALUE = 25
const MAX_ENERGY_VALUE = 100

# Time in seconds after depletion for the food to regenerate
const REGROW_TIME = 25

func _ready():
	set_energy_and_start_timer()

func set_energy_and_start_timer():
	energy_value = rng.randf_range(MIN_ENERGY_VALUE, MAX_ENERGY_VALUE)
	get_node("DecayTimer").set_wait_time(energy_value)
	get_node("DecayTimer").start()

func _on_decay_timer_timeout():
	depleted()

# Use this to take energy from this food. It returns the total amount consumed so we can add that to the creatures energy
func consume(amount):
	energy_value -= amount
	if energy_value <= 0:
		var amount_consumed = amount + energy_value
		depleted()
		return amount_consumed
	return amount

func depleted():
	energy_value = 0
	get_node("FoodDead").visible = true
	get_node("FoodAlive").visible = false
	get_node("RegrowTimer").set_wait_time(REGROW_TIME)
	get_node("RegrowTimer").start()

func regenerated():
	get_node("FoodAlive").visible = true
	get_node("FoodDead").visible = false
	set_energy_and_start_timer()

func _on_regrow_timer_timeout():
	regenerated()
