extends Control

func _ready():
	if Main.AUTO_REPLAY:
		$Label.position = Vector2(233, 113)
		$Replay_Button.position = Vector2(-2000, 449)
		$MainMenu_Button.position = Vector2(-2000, 530)
		$Editor_Button.position = Vector2(-1000, 200)
	elif not Main.AUTO_REPLAY and not Main.in_editor:
		$Label.position = Vector2(233, 50)
		$Replay_Button.position = Vector2(509, 449)
		$MainMenu_Button.position = Vector2(511, 530)
		$Editor_Button.position = Vector2(-1000, 200)
	elif not Main.AUTO_REPLAY and Main.in_editor:
		$Label.position = Vector2(233, 50)
		$Replay_Button.position = Vector2(509, 449)
		$MainMenu_Button.position = Vector2(-1000, 200)
		$Editor_Button.position = Vector2(511, 530)
		
		
func _on_replay_button_pressed():
	play_click_sfx()
	print("replay button pressed")
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed():
	play_click_sfx()
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")


func _on_editor_button_pressed():
	play_click_sfx()
	get_tree().change_scene_to_file("res://Scenes/editor_2.tscn")

func play_click_sfx():
	$ClickSFX.play()
