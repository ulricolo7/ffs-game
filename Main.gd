extends Node

var no_pause_state = 1
var SCROLL_SPEED 

func _process(delta):
	if no_pause_state == 1:
		SCROLL_SPEED = 400
	elif no_pause_state == 0:
		SCROLL_SPEED = 0
