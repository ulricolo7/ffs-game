extends Node

var pause_state = 0
var SCROLL_SPEED 

func _process(delta):
	if pause_state == 0:
		SCROLL_SPEED = 400
	elif pause_state == 1:
		SCROLL_SPEED = 0
