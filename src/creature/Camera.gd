extends Camera2D


# Called when the node enters the scene tree for the first time.
var zoom_speed = 0.05

func _ready():
	self.set_process_input(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.zoom.x = max(self.zoom.x - zoom_speed, 0.1)
			self.zoom.y = max(self.zoom.y - zoom_speed, 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.zoom.x += zoom_speed
			self.zoom.y += zoom_speed
