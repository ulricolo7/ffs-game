extends Control

func _ready():
	$VolumeSlider.value = Main.MASTER_VOLUME
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(Main.MASTER_VOLUME))
	
	$AutoReplayLabel/AutoReplayCheckBox.button_pressed = Main.AUTO_REPLAY
	$FullScreenLabel/FullScreenCheckBox.button_pressed = Main.FULL_SCREEN
	
func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(value))
	Main.MASTER_VOLUME = value


func _on_auto_replay_check_box_toggled(button_pressed):
	Main.AUTO_REPLAY = button_pressed


func _on_full_screen_check_box_toggled(button_pressed):
	Main.FULL_SCREEN = button_pressed
	var file = FileAccess.open("res://Script/Main.gd", FileAccess.READ_WRITE)
	print(file.get_line())
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
