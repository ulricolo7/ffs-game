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
		var bot_list = []
		
		while file_name != "":
			if ".tscn.remap" in file_name:
				file_name.trim_suffix(".remap")
			if not dir.current_is_dir() and (not file_name.match("player_character.tscn")):
				
				var file_path = bots_folder + file_name
				var bot_difficulty = get_bot_difficulty(file_name)
				bot_list.append({"path": file_path, "difficulty": bot_difficulty})
			file_name = dir.get_next()
		dir.list_dir_end()
		
		bot_list.sort_custom(Callable(self, "compare_bot_difficulty"))
		
		for bot in bot_list:
			_add_bot_button(bot["path"])
	else:
		print("Failed to open directory: " + bots_folder)

func get_bot_difficulty(file_name: String):
	if "[Easy]" in file_name:
		return 1
	elif "[Medium]" in file_name:
		return 2
	elif "[Hard]" in file_name:
		return 3
	else:
		return 999 # jic 

func compare_bot_difficulty(a, b):
	return (a["difficulty"] - b["difficulty"]) < 0

func _add_bot_button(file_path: String):
	var button_instance = button_scene.instantiate()
	var name_label = button_instance.get_node("HBoxContainer/VBoxContainer/BotName")
	var last_edited_label = button_instance.get_node("HBoxContainer/VBoxContainer/LastEdited")
	name_label.text = file_path.get_file().get_basename()
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
	play_click_sfx()
	Main.BOT_NAME = file_path
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_back_button_pressed():
	play_click_sfx()
	emit_signal("switch_screens")

func play_click_sfx():
	$ClickSFX.play()
