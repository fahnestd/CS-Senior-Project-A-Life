extends Label

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	msec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	get_node("MinRunTimeLabel").text = "%02d:" % minutes
	get_node("SecRunTimeLabel").text = "%02d." % seconds
	get_node("MsRunTimeLabel").text = "%03d" % msec
	
