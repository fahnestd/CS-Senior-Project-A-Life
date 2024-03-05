extends Area2D

#var type = "sight"
var parent_creature
var Behavior
var visible_nodes


#func initialize(parent_creature):
	#Behavior = parent_creature.Behavior
	#visible_nodes = Behavior.visible_nodes
	#area_entered.connect(_on_area_entered)
	#area_exited.connect(_on_area_exited)

#func _on_area_entered(node):
	#if node.parent_creature != parent_creature:
		#if node.type != "sight":
			#if not visible_nodes.has(node):
				#visible_nodes[node] = null
#
#func _on_area_exited(node):
	#pass
	#if node.parent_creature != parent_creature:
		#visible_nodes.erase(node)

func _process(_delta):
	pass
