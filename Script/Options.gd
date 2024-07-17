extends Control

func _ready():
	$VolumeSlider.value = Main.MASTER_VOLUME
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(Main.MASTER_VOLUME))
	
	$AutoReplayLabel/AutoReplayCheckBox.button_pressed = Main.AUTO_REPLAY
	$FullScreenLabel/FullScreenCheckBox.button_pressed = Main.FULL_SCREEN
	
func _on_main_menu_button_pressed():
	play_click_sfx()
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(value))
		
	Main.MASTER_VOLUME = value
	
	update_saved_options()


func _on_auto_replay_check_box_toggled(button_pressed):
	play_click_sfx()
	Main.AUTO_REPLAY = button_pressed
	
	update_saved_options()


func _on_full_screen_check_box_toggled(button_pressed):
	play_click_sfx() # this is the problem
	Main.FULL_SCREEN = button_pressed
	
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_saved_options()

func update_saved_options():
	if FileAccess.file_exists(Main.SAVE_PATH):
		delete_file(Main.SAVE_PATH)
	
	var file = FileAccess.open(Main.SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line("var MASTER_VOLUME = {0}".format([Main.MASTER_VOLUME]))
		file.store_line("var AUTO_REPLAY = {0}".format([Main.AUTO_REPLAY]))
		file.store_line("var FULL_SCREEN = {0}".format([Main.FULL_SCREEN]))
		file.close()

func delete_file(file_path: String): 
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File: ", file_path, " deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")

func play_click_sfx():
	$ClickSFX.play()
