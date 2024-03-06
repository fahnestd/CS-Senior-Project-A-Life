# Utility contains useful functions that aren't specialized for any purpose
extends Node

# Adds an entry to the dictionary at the next lowest numerical index
func dictionary_next(dictionary, entry):
	var lowest_index = 0
	while dictionary.has(lowest_index):
		lowest_index += 1
	dictionary[lowest_index] = entry

# Adds an entry to the dictionary at the next numerical index based on size
# Faster, but do not use after erasing an entry
func dictionary_append(dictionary, entry):
	dictionary[dictionary.size()] = entry

# Clamps an angle from -180 (exclusive) to 180 (inclusive)
func angle_clamp(angle):
	while angle <= -180:
		angle += 360
	while angle > 180:
		angle -= 360
	return angle
