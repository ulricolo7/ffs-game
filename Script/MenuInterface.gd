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
	
	print(var_name, " initialized")
	return var_name
	
func _ready():
	
	options_screen = init_screen(options_screen, options_scene, false, 10)
	level_select_screen = init_screen(level_select_screen, level_select_scene, false, 10)
	level_select_sim_screen = init_screen(level_select_sim_screen, level_select_sim_scene, false, 10)
	bot_select_screen = init_screen(bot_select_screen, bot_select_scene, false, 10)
	
	level_select_sim_screen.find_child("Panel").connect("switch_screens", Callable(self, "_on_level_selected"))
	
func _on_play_pressed():
	#get_tree().change_scene_to_file("res://Scenes/level.tscn")
	Main.BOT_NAME = ""
	level_select_screen.visible = true


func _on_simulate_pressed():
	level_select_sim_screen.visible = true
	#bot_select_screen.visible = true
	#Main.BOT_NAME = "Scanner"


func _on_editor_pressed():
	Main.in_editor = true
	get_tree().change_scene_to_file("res://Scenes/editor_2.tscn")


func _on_options_pressed():
	options_screen.visible = true


func _on_quit_pressed():
	get_tree().quit()
	
func _on_level_selected():
	print("switched screen")
	level_select_sim_screen.visible = false
	bot_select_screen.visible = true
	
