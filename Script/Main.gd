extends Node

var SAVE_PATH = "res://Script/SavedOptions.gd"
var SAVED_OPTIONS = load(SAVE_PATH).new()

var MASTER_VOLUME
var AUTO_REPLAY
var FULL_SCREEN

var no_pause_state = 1
var SCROLL_SPEED 
var options_screen
var TEST_SPEED = 1
var BG_SPEED = 0.99

var BOT_NAME 
var LEVEL_LENGTH
var LEVEL_SCRIPT

var in_editor = false
var in_open_file = false
var level_switching = false
var CURR_EDITOR_LEVEL
var CURR_EDITOR_LEVEL_COMPLETED 
var PREP_EDITOR_LEVEL
var prep_editor_level_enemy_data
var player_input_disabled = false 
var curr_editor_level_enemy_data: Dictionary
var editor_paused = false

func _ready():
	MASTER_VOLUME = SAVED_OPTIONS.MASTER_VOLUME
	AUTO_REPLAY = SAVED_OPTIONS.AUTO_REPLAY
	FULL_SCREEN = SAVED_OPTIONS.FULL_SCREEN
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 
		linear_to_db(MASTER_VOLUME))
		
	if FULL_SCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(_delta):
	if no_pause_state == 1:
		SCROLL_SPEED = 700 * TEST_SPEED
	elif no_pause_state == 0:
		SCROLL_SPEED = 0 * TEST_SPEED

func pause():
	no_pause_state = 0
	
func resume():
	no_pause_state = 1
