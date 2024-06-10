extends Control

func _ready():
	#$HSlider["value"] = db_to_linear(
		#AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$HSlider["value"] = Main.MASTER_VOLUME
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(Main.MASTER_VOLUME))

func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(value))
	Main.MASTER_VOLUME = value
