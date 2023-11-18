extends TileMap
var rect = get_used_rect()
var current_layer = 0
var off_layer = 1

func _ready():
	for x in rect.size[0]:
		for y in rect.size[1]:
			var val = 0
			
			set_cell(current_layer, Vector2i(x,y), 0, Vector2i(randi() % 2,0))

func _process(delta):
	current_layer = (current_layer + 1) % 2
	off_layer = (current_layer + 1) % 2
	
	set_layer_enabled(current_layer, true)
	set_layer_enabled(off_layer, false)
	
	for x in rect.size[0]:
		for y in rect.size[1]:
			var live_neighbors = 0
			
			for i in 3:
				for j in 3:
					live_neighbors += get_cell_atlas_coords(off_layer, Vector2i(x-1+i, y-1+j))[0]
			
			if get_cell_atlas_coords(off_layer, Vector2i(x,y))[0] == 0:
				if live_neighbors == 3:
					set_cell(current_layer, Vector2i(x,y), 0, Vector2i(1,0))
				else:
					set_cell(current_layer, Vector2i(x,y), 0, Vector2i(0,0))
			else:
				if live_neighbors < 3 or live_neighbors > 4:
					set_cell(current_layer, Vector2i(x,y), 0, Vector2i(0,0))
				else:
					set_cell(current_layer, Vector2i(x,y), 0, Vector2i(1,0))
