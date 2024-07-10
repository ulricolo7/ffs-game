extends Control
signal resumed
var options_screen

func _ready():
	var options_scene = preload("res://Scenes/options.tscn")
	options_screen = options_scene.instantiate()
	options_screen.visible = false
	options_screen.z_index = 10
	add_child(options_screen)


func _on_resume_pressed():
	play_click_sfx()
	print("resume button pressed")
	emit_signal("resumed")


func _on_options_pressed():
	play_click_sfx()
	options_screen.visible = true


func _on_main_menu_pressed():
	play_click_sfx()
	print("main menu button pressed")
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")


func _on_restart_pressed():
	play_click_sfx()
	print("restart button pressed")
	get_tree().reload_current_scene()

func play_click_sfx():
	$ClickSFX.play()
