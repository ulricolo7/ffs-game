extends Panel

@export var bots_folder: String = "res://Scenes/Player/"
@export var button_scene = preload("res://Scenes/Simulator/bot_button.tscn")

signal switch_screens

# Called when the node enters the scene tree for the first time.
func _ready():
	_scan_bots_folder()

func _scan_bots_folder():
	var dir = DirAccess.open(bots_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (not file_name.match("player_character.tscn") and file_name.ends_with(".tscn")):
				var file_path = bots_folder + file_name
				_add_level_button(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + bots_folder)

func _add_level_button(file_path: String):
	var button_instance = button_scene.instantiate()
	var name_label = button_instance.get_node("HBoxContainer/VBoxContainer/BotName")
	#var desc_label = button_instance.get_node("Button/level_button/VBoxContainer/LevelDesc")
	var last_edited_label = button_instance.get_node("HBoxContainer/VBoxContainer/LastEdited")
	#print(name_label)
	#print(last_edited_label)
	name_label.text = file_path.get_file().get_basename()
	#print(name_label.text)
	#desc_label.text = file_path.get_file()
	last_edited_label.text = "Last edited: " + _get_file_last_modified(file_path)
	
	
	button_instance.connect("pressed", Callable(self, "_on_bot_button_pressed").bind(file_path))
	$VBoxContainer.add_child(button_instance)
	

func _get_file_last_modified(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var mod_time = FileAccess.get_modified_time(file_path)
		file.close()
		var date = Time.get_datetime_string_from_unix_time(mod_time)
		return date
	return "Unknown"

func _on_bot_button_pressed(file_path: String):
	print("bot selected")
	Main.BOT_NAME = file_path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_back_button_pressed():
	emit_signal("switch_screens")
