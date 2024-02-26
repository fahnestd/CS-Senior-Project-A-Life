extends Node2D


var parent = null
var angle = null
var size = null
var joint = null
var type = null

var node_plan = null

var scale_multiplier = .1

func scale_node(size):
	get_node('Sprite2D').scale.x = size * scale_multiplier
	get_node('Sprite2D').scale.y = size * scale_multiplier
	get_node('Area2D/CollisionShape2D').scale.x = size * scale_multiplier
	get_node('Area2D/CollisionShape2D').scale.y = size * scale_multiplier
