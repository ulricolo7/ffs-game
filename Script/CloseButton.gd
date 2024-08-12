extends TextureButton

func _on_pressed():
	get_parent().play_click_sfx()
	# get_parent().hide()
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")
