extends Node

var no_pause_state = 1
var SCROLL_SPEED 
var options_screen
var MASTER_VOLUME = 0.5
var TEST_SPEED = 1
var BG_SPEED = 0.99

var AUTO_REPLAY = true

var BOT_NAME
var LEVEL_LENGTH

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 
		linear_to_db(MASTER_VOLUME))

func _process(delta):
	if no_pause_state == 1:
		SCROLL_SPEED = 700 * TEST_SPEED
	elif no_pause_state == 0:
		SCROLL_SPEED = 0 * TEST_SPEED
		

func pause():
	no_pause_state = 0
	
func resume():
	no_pause_state = 1
