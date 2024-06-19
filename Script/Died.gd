extends Control

func _ready():
	if Main.AUTO_REPLAY == true:
		$Label.position = Vector2(233, 113)
		$Replay_Button.position = Vector2(-2000, 449)
		$MainMenu_Button.position = Vector2(-2000, 536)
	else:
		$Label.position = Vector2(233, 50)
		$Replay_Button.position = Vector2(509, 449)
		$MainMenu_Button.position = Vector2(511, 536)
		
func _on_replay_button_pressed():
	print("replay button pressed")
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed():
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")
