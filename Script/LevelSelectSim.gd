extends Panel

@export var levels_folder: String = "res://Script/Levels/"
@export var button_scene = preload("res://Scenes/level_button.tscn")

signal switch_screens

# Called when the node enters the scene tree for the first time.
func _ready():
	_scan_levels_folder()

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
	play_click_sfx()
	var button_instance = button_scene.instantiate()
	var name_label = button_instance.get_node("level_button/VBoxContainer/LevelName")
	#var desc_label = button_instance.get_node("Button/level_button/VBoxContainer/LevelDesc")
	var last_edited_label = button_instance.get_node("level_button/VBoxContainer/LastEdited")
	name_label.text = file_path.get_file().get_basename()
	#desc_label.text = file_path.get_file()
	last_edited_label.text = "Last edited: " + _get_file_last_modified(file_path)
	
	
	button_instance.connect("pressed", Callable(self, "_on_level_button_pressed").bind(file_path))
	$VBoxContainer.add_child(button_instance)
	

func _get_file_last_modified(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var mod_time = FileAccess.get_modified_time(file_path)
		file.close()
		var date = Time.get_datetime_string_from_unix_time(mod_time)
		return date
	return "Unknown"

func _on_level_button_pressed(file_path: String):
	play_click_sfx()
	print("button pressed")
	Main.LEVEL_SCRIPT = file_path
	emit_signal("switch_screens")
	print("signal emitted")

func play_click_sfx():
	$ClickSFX.play()
