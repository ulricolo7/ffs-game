extends Control

func _on_replay_button_pressed():
	print("replay button pressed")
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://menu_interface.tscn")


