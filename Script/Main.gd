extends Node

var no_pause_state = 1
var SCROLL_SPEED 
var options_screen

func _process(delta):
	if no_pause_state == 1:
		SCROLL_SPEED = 700
	elif no_pause_state == 0:
		SCROLL_SPEED = 0
		

