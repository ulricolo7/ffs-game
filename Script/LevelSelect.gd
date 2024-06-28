extends Panel

@export var levels_folder: String = "res://Script/Levels/"
@export var button_scene = preload("res://Scenes/level_button.tscn")
var show_dev_levels = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_scan_levels_folder()

func _scan_levels_folder():
	var dir = DirAccess.open(levels_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".gd"):
				if show_dev_levels or not file_name.begins_with("dev_"):
					var file_path = levels_folder + file_name
					_add_level_button(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + levels_folder)

func _add_level_button(file_path: String):
	var button_instance = button_scene.instantiate()
	var name_label = button_instance.get_node("level_button/VBoxContainer/LevelName")
	#var desc_label = button_instance.get_node("Button/level_button/VBoxContainer/LevelDesc")
	var last_edited_label = button_instance.get_node("level_button/VBoxContainer/LastEdited")
	name_label.text = file_path.get_file().get_basename()
	#desc_label.text = file_path.get_file()
	last_edited_label.text = "Last edited: " + _get_file_last_modified(file_path)
	
	
	button_instance.connect("pressed", Callable(self, "_on_level_button_pressed").bind(file_path))
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
	Main.LEVEL_SCRIPT = file_path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
