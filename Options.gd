extends Control

func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Menu_Interface.tscn")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
