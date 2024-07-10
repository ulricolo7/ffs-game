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

func _on_restart_pressed():
	play_click_sfx()
	print("restart button pressed")
	get_tree().reload_current_scene()


func _on_editor_2_pressed():
	play_click_sfx()
	print("editor button pressed")
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")
	
func play_click_sfx():
	$ClickSFX.play()
