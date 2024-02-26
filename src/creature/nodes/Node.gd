extends Node2D


var parent = null
var angle = null
var size = null
var joint = null
var type = null

var node_plan = null

var scale_multiplier = .1
var leg_distance = 30
	
func _process(delta):
	#update_node_angle()
	update_node_position()
	

func scale_node(size):
	get_node('Sprite2D').scale.x = size * scale_multiplier
	get_node('Sprite2D').scale.y = size * scale_multiplier
	get_node('Area2D/CollisionShape2D').scale.x = size * scale_multiplier
	get_node('Area2D/CollisionShape2D').scale.y = size * scale_multiplier


func update_node_position():
	if parent != null:
		position = Vector2(leg_distance, 0).rotated(deg_to_rad(angle))
	
func update_node_angle():
	if parent != null:
		var parent_pos = parent["position"]
		var new_angle = rad_to_deg(parent_pos.angle_to_point(position))
		if new_angle < 0:
			new_angle += 360
		angle = new_angle
		
