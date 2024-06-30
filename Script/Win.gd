extends Control

func _ready():
	if Main.in_editor:
		$MainMenu_Button.visible = false
		$Editor_Button.visible = true
	else:
		$MainMenu_Button.visible = true
		$Editor_Button.visible = false

func _on_replay_button_pressed():
	print("replay button pressed")
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")

func _on_editor_button_pressed():
	Main.CACHED_EDITOR_LEVEL_COMPLETED = Main.CACHED_EDITOR_LEVEL
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")

