extends Label

func _on_one_time_button_pressed():
	Engine.time_scale  = 1.0
	update_physics_ticks()
	get_node("SimLabel").text = "1"

func _on_two_time_button_pressed():
	Engine.time_scale = 2.0
	update_physics_ticks()
	get_node("SimLabel").text = "2"


func _on_four_time_button_pressed():
	Engine.time_scale  = 4.0
	update_physics_ticks()
	get_node("SimLabel").text = "4"

func _on_simulation_skip_timer_timeout():
	Engine.time_scale = 1.0
	update_physics_ticks()
	get_node('FFImage').visible = false

func _on_skip_five_minutes_button_pressed():
	start_warp(5)

func _on_skip_thirty_minutes_button_pressed():
	start_warp(30)

func _on_skip_sixty_minutes_button_pressed():
	start_warp(60)

func start_warp(duration_in_minutes):
	get_node('FFImage').visible = true	
	Engine.time_scale = duration_in_minutes * 60.0
	update_physics_ticks()
	get_node("SimulationSkipTimer").set_wait_time(duration_in_minutes * 60)
	get_node("SimulationSkipTimer").start()

func update_physics_ticks():
	Engine.max_physics_steps_per_frame = round(Engine.time_scale)
	Engine.physics_ticks_per_second = round(Engine.time_scale * 60)
