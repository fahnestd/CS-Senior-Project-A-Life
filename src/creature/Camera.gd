extends Camera2D


# Called when the node enters the scene tree for the first time.
var zoom_speed = 0.10
var movement_speed = 300.00

var target_node = null

func target(creature):
	target_node = creature.root_node

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

func _process(delta):
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"): # W
		movement.y -= movement_speed
	if Input.is_action_pressed("ui_down"): # S
		movement.y += movement_speed
	if Input.is_action_pressed("ui_right"): # D
		movement.x += movement_speed
	if Input.is_action_pressed("ui_left"): # A
		movement.x -= movement_speed

	if movement != Vector2.ZERO:
		target_node = null

	if target_node != null:
		self.global_position = target_node.global_position
	else:
		self.global_position += movement * delta
