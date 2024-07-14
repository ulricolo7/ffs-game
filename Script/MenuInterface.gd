extends Control

const options_scene = preload("res://Scenes/options.tscn")
const level_select_scene = preload("res://Scenes/level_select.tscn")
const level_select_sim_scene = preload("res://Scenes/Simulator/level_select.tscn")
const bot_select_scene = preload("res://Scenes/Simulator/bot_select.tscn")

var options_screen
var level_select_screen
var level_select_sim_screen
var bot_select_screen


func init_screen(var_name, scene_name, visibility, z_ind):

	var_name = scene_name.instantiate()
	var_name.set_visible(visibility)
	var_name.set_z_index(z_ind)
	add_child(var_name)
	return var_name
	
func _ready():
	print(Main.CURR_EDITOR_LEVEL)
	options_screen = init_screen(options_screen, options_scene, false, 10)
	level_select_screen = init_screen(level_select_screen, level_select_scene, false, 10)
	level_select_sim_screen = init_screen(level_select_sim_screen, level_select_sim_scene, false, 10)
	bot_select_screen = init_screen(bot_select_screen, bot_select_scene, false, 10)
	
	level_select_sim_screen.connect("switch_screens", Callable(self, "screen_switch"))
	bot_select_screen.find_child("Panel").connect("switch_screens", Callable(self, "screen_switch"))
	
func _on_play_pressed():
	play_click_sfx()
	Main.BOT_NAME = ""
	level_select_screen.visible = true

func _on_simulate_pressed():
	play_click_sfx()
	level_select_sim_screen.visible = true

func _on_editor_pressed():
	Main.in_editor = true
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")

func _on_options_pressed():
	play_click_sfx()
	options_screen.visible = true

func _on_quit_pressed():
	play_click_sfx() # this one is useless
	get_tree().quit()
	
func screen_switch():
	if level_select_sim_screen.visible:
		level_select_sim_screen.visible = false
		bot_select_screen.visible = true
	else:
		level_select_sim_screen.visible = true
		bot_select_screen.visible = false
	
func _on_instructions_pressed():
	play_click_sfx()
	if $InstructionsPanel.visible: 
		$InstructionsPanel.visible = false
		$Instructions.button_pressed = false
	else:
		$InstructionsPanel.visible = true
		$Instructions.button_pressed = true

func _on_close_instructions_pressed():
	play_click_sfx()
	$InstructionsPanel.visible = false
	$Instructions.button_pressed = false

	
func play_click_sfx():
	$ClickSFX.play()
