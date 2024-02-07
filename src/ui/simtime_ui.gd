extends Label

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	msec = int(round(time * 1000)) % 1000
	seconds = int(floor(time)) % 60
	minutes = int(floor(time / 60.0))
	get_node("MsRunTimeLabel").text = "%03d" % msec
	get_node("MinRunTimeLabel").text = "%02d:" % minutes
	get_node("SecRunTimeLabel").text = "%02d." % seconds
	
