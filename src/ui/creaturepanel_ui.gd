extends Panel

@onready var world = get_node("../World")
@onready var health = get_node("Health")
var creature

func _on_creature_generator_creature_info(info):
	creature = info
	var global_pos = Vector2i(info.global_position)
	var tile = info.world.GetTile(global_pos)
	
	get_node("CreatureInfoLabel").text = "Health: " + str(info.health.health);
	get_node("CreatureInfoLabel").text += "\nTerrain: " + str(tile.TerrainType);
	get_node("CreatureInfoLabel").text += "\nTemperature: " + str(tile.Temperature);
	get_node("CreatureInfoLabel").text += "\nLocation: " + str(tile.Coordinates);
	
func _process(delta):
	if creature != null:
		var global_pos = Vector2i(creature.global_position)
		var tile = creature.world.GetTile(global_pos)
		
		get_node("CreatureInfoLabel").text = "Health: " + str(creature.health.health);
		get_node("CreatureInfoLabel").text += "\nTerrain: " + str(tile.TerrainType);
		get_node("CreatureInfoLabel").text += "\nTemperature: " + str(tile.Temperature);
		get_node("CreatureInfoLabel").text += "\nLocation: " + str(tile.Coordinates);
