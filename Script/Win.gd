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
	Main.CURR_EDITOR_LEVEL_COMPLETED = Main.CURR_EDITOR_LEVEL
	mark_level(Main.CURR_EDITOR_LEVEL_COMPLETED, "completed", "true")
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")

func mark_level(file_path: String, mark: String, truthy: String):
	var file = FileAccess.open(Main.CURR_EDITOR_LEVEL_COMPLETED, FileAccess.READ_WRITE)
	if not file:
		print("Error: Could not open file")
		return
	
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	delete_file(Main.CURR_EDITOR_LEVEL_COMPLETED)
	var new_lines = []
	for line in lines:
		if line.strip_edges().begins_with("var is_{mark}".format({"mark": mark})):
			new_lines.append("var is_{mark} = {truthy}".format({"mark": mark, "truthy": truthy}))
		else:
			new_lines.append(line)
			
	file = FileAccess.open(Main.CURR_EDITOR_LEVEL_COMPLETED, FileAccess.WRITE)
	
	for line in new_lines:
		file.store_line(line)
	file.close()

func delete_file(file_path: String): 
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File: ", file_path, " deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")
