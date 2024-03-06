extends Panel

var Creature

@onready var world = get_node('../../../../World')

func _on_camera_creature_info(creature):
	var tile = world.GetTile(Vector2i(creature.global_position))
	
	get_node("CreatureInfoLabel").text = "Health: " + str(creature.get_node('Status').health);
	get_node("CreatureInfoLabel").text += "\nTerrain: " + str(tile.TerrainType);
	get_node("CreatureInfoLabel").text += "\nTemperature: " + str(tile.Temperature);
	get_node("CreatureInfoLabel").text += "\nLocation: " + str(tile.Coordinates);
	
func _process(_delta):
	if Creature != null:
		var global_pos = Vector2i(Creature.global_position)
		var tile = Creature.world.GetTile(global_pos)
		
		get_node("CreatureInfoLabel").text = "Health: " + str(Creature.get_node('Status').health);
		get_node("CreatureInfoLabel").text += "\nTerrain: " + str(tile.TerrainType);
		get_node("CreatureInfoLabel").text += "\nTemperature: " + str(tile.Temperature);
		get_node("CreatureInfoLabel").text += "\nLocation: " + str(tile.Coordinates);
