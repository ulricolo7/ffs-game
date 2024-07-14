extends TextureButton

func _on_pressed():
	play_click_sfx()
	Main.in_editor = false
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")

func play_click_sfx():
	$ClickSFX.play()
