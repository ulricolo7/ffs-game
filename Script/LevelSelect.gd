extends Panel

@export var levels_folder: String = "res://Script/Levels/"
@export var button_scene = preload("res://Scenes/level_button.tscn")
const make_new_lvl_button_scene = preload("res://Scenes/make_new_lvl_button.tscn")

signal level_selected

func _ready():
	if Main.in_editor:
		$Quit_Button.visible = false
	else:
		$open_file_quit.visible = false
	_scan_levels_folder()
	var make_new_lvl_instance = make_new_lvl_button_scene.instantiate()
	make_new_lvl_instance.connect("pressed", Callable(self, "open_editor"))
	$ScrollContainer/VBoxContainer.add_child(make_new_lvl_instance)
	

func _scan_levels_folder():
	var dir = DirAccess.open(levels_folder)
	var dev_files = []
	var normal_files = []
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".gd"):
				# Sorting the levels so that dev levels stay on top
				if file_name.begins_with("dev_"):
					dev_files.append(file_name)
				else:
					normal_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		
		var all_files = dev_files + normal_files
		if Main.in_editor:
			for file in normal_files:
				var file_path = levels_folder + file
				_add_level_button(file_path)
		else:
			for file in all_files:
				var file_path = levels_folder + file
				if not file.begins_with("dev_"):
					if is_level_saved(file_path):
						_add_level_button(file_path)
				else:
					_add_level_button(file_path)
		
	else:
		print("Failed to open directory: " + levels_folder)

func is_level_saved(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var line
		while not file.eof_reached():
			line = file.get_line().strip_edges()
			if line.begins_with("var is_saved"):
				return line == "var is_saved = true"
		file.close()
	return false

func _add_level_button(file_path: String):
	var button_instance = button_scene.instantiate()
	var name_label = button_instance.get_node("level_button/VBoxContainer/LevelName")
	var last_edited_label = button_instance.get_node("level_button/VBoxContainer/LastEdited")
	name_label.text = file_path.get_file().get_basename()
	last_edited_label.text = "Last edited: " + _get_file_last_modified(file_path)
	var lvl_name = name_label.text
	
	button_instance.connect("pressed", Callable(self, "_on_level_button_pressed").bind(file_path))
	button_instance.find_child("DeleteButton").connect("pressed", Callable(self, "_on_delete_lvl_button_pressed").bind(button_instance, file_path))
	if lvl_name.begins_with("dev_"):
		button_instance.find_child("DeleteButton").visible = false
	$ScrollContainer/VBoxContainer.add_child(button_instance)
	

func _get_file_last_modified(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var mod_time = FileAccess.get_modified_time(file_path)
		file.close()
		var date = Time.get_datetime_string_from_unix_time(mod_time)
		return date
	return "Unknown"

func _on_level_button_pressed(file_path: String):
	if Main.in_editor:
		print(file_path)
		Main.CACHED_EDITOR_LEVEL = file_path
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var enemy_data = {}
			var largest_x = 0
			var in_enemy_data = false
			var regex = RegEx.new()
			var result
			regex.compile("(\\d+): {\"position\": Vector2\\(([^,]+), ([^\\)]+)\\), \"type\": \"([^\"]+)\"},")
		
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line == "var enemy_data = {":
					in_enemy_data = true
					continue
				elif line == "}":
					in_enemy_data = false
					continue
	#		
				if in_enemy_data:
					result = regex.search(line)
					if result:
						var idx = result.get_string(1).to_int()
						var pos_x = result.get_string(2).to_float()
						var pos_y = result.get_string(3).to_float()
						var enemy_type = result.get_string(4)
						enemy_data[idx] = {"position": Vector2(pos_x, pos_y), "type": enemy_type}
			Main.curr_editor_level_enemy_data = enemy_data
		emit_signal("level_selected")
	else:
		Main.LEVEL_SCRIPT = file_path
		get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_delete_lvl_button_pressed(button_instance, file_path: String):
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File: ", file_path, "deleted successfully")
			button_instance.queue_free()
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")
		
	if Main.CACHED_EDITOR_LEVEL == file_path:
		Main.CACHED_EDITOR_LEVEL = ""
	if Main.CACHED_EDITOR_LEVEL_COMPLETED == file_path:
		Main.CACHED_EDITOR_LEVEL_COMPLETED = ""
	
func open_editor():
	print("reached")
	Main.in_editor = true
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")
