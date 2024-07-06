extends TextureButton

func _on_pressed():
	Main.in_editor = false
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")
