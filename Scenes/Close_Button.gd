extends TextureButton

func _on_pressed():
	get_parent().play_click_sfx()
	get_parent().hide()

