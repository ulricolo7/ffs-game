extends Control

var options_screen

func _ready():
	var options_scene = preload("res://Scenes/options.tscn")
	options_screen = options_scene.instantiate()
	options_screen.visible = false
	options_screen.z_index = 10
	add_child(options_screen)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_simulate_pressed():
	pass # Replace with function body.


func _on_editor_pressed():
	get_tree().change_scene_to_file("res://Scenes/Editor.tscn")


func _on_options_pressed():
	options_screen.visible = true


func _on_quit_pressed():
	get_tree().quit()
