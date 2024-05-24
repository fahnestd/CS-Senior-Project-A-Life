extends Node2D

@onready var Behavior = get_node("Behavior")
@onready var Body = get_node("Body")
@onready var Growth = get_node("Growth")
@onready var Resources = get_node("../../Resources")
@onready var Status = get_node("Status")
@onready var World = get_node("../../World")

func _physics_process(delta):
	handle_interactions(delta)

func handle_interactions(delta):
	var _pos = Vector2i(position)
	var global_pos = Vector2i(global_position)
	var tile = World.GetTile(global_pos)
	handle_pressure(delta, tile);
	handle_lightlevel(delta, tile);
	handle_tiletype(delta, tile);
	
	update_label(delta, tile);

func update_label(_delta, tile):
	var terrainLabel = get_node("TerrainLabel")
	if tile != null:
		terrainLabel.text = str(tile.Coordinates);
		terrainLabel.text += "\nTerrain: " + str(tile.TerrainType);
		terrainLabel.text += "\nTemperature: " + str(tile.Temperature);
		terrainLabel.text += "\nLight Level: " + str(tile.LightLevel);

func handle_tiletype(_delta, _tile):
	pass
	
func handle_pressure(_delta, _tile):
	pass

func handle_lightlevel(_delta, _tile):
	pass
