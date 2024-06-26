extends Control

const level_select_scene = preload("res://Scenes/level_select.tscn")
var level_select_screen

var curr_enemy = null
var last_enemy = null
var largest_x = -100

var enemy_data = {}
var enemy_indices = {}
var enemy_scenes = {
	"gh": preload("res://Scenes/Enemies/Ghaster/ghaster_static.tscn"),
	"fl": preload("res://Scenes/Enemies/Flapper/flapper_static.tscn"),
	"cg": preload("res://Scenes/Enemies/Crawler/crawler_ground_static.tscn"),
	"ca": preload("res://Scenes/Enemies/Crawler/crawler_air_static.tscn") 
}
var h_scroll_bar
var editor_screen
var editor_screen_bounds
var background
var camera
var scroll_factor = 0.01
var idx_counter
var level_file_name

var curr_file_path

var y_constraints = {
	"gh": { "min": 160, "max": 670 },
	"fl": { "min": 130, "max": 700 },
	"cg": { "fixed": 710 },
	"ca": { "min": 120, "max": 420 }
}

func set_button_able():
	# i made this function separated from _ready() in an attempt to have a reload function 
	# that doesnt create infinite loop. didnt work
	if Main.CACHED_EDITOR_LEVEL:
		var cached_lvl_name = Main.CACHED_EDITOR_LEVEL.trim_prefix("res://Script/Levels/").trim_suffix(".gd")
		$Panel/LineEdit.text = cached_lvl_name
		curr_file_path = Main.CACHED_EDITOR_LEVEL
		print(Main.CACHED_EDITOR_LEVEL)
		level_file_name = cached_lvl_name + ".gd"
		$Panel/PlayButton.disabled = false
		if check_level_validity(Main.CACHED_EDITOR_LEVEL):
			# BUG RIGHT HERE: LEVEL ISNT VALID FOR SOEM REASON
			print("LEVEL IS VALID")
			$Panel/SaveButton.disabled = false
		else:
			print("LEVEL ISN'T VALID")
			$Panel/SaveButton.disabled = true
	else:
		$Panel/PlayButton.disabled = true
		$Panel/SaveButton.disabled = true
		
func _ready():
	if Main.CACHED_EDITOR_LEVEL_COMPLETED:
		mark_level_completed()
	
	set_button_able()
	
	editor_screen = get_parent().get_node("../EditorScreen")
	editor_screen_bounds = get_parent().get_node("../EditorScreen/Boundaries")
	background = get_parent().get_node("../EditorScreen/Background")
	camera = get_parent()
	h_scroll_bar = get_node("../HScrollBar")
	
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("gh"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("fl"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("cg"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ca"))
		
	$Panel/WarningLabel.visible = false
	$Panel/WarningLabel2.visible = false
	set_process_input(true)
	
	level_select_screen = level_select_scene.instantiate()
	level_select_screen.visible = false
	level_select_screen.set_z_index(35)
	level_select_screen.position = Vector2(-885,0)
	add_child(level_select_screen)
	level_select_screen.find_child("Panel").connect("level_selected", Callable(self, "disable_level_select"))
	level_select_screen.find_child("Panel").find_child("open_file_quit").connect("close_level_select", Callable(self, "close_selector"))
	
	if Main.CACHED_EDITOR_LEVEL:
		#enemy_data = Main.curr_editor_level_enemy_data
		#load_enemies(Main.CACHED_EDITOR_LEVEL)
		load_enemies(Main.curr_editor_level_enemy_data)
	idx_counter = count_enemies()
	
func _on_enemy_button_pressed(enemy_type):
	var enemy_scene = enemy_scenes.get(enemy_type)
	var inst_location = camera.position.x
	
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		if enemy_type == "gh":
			enemy_instance.position = Vector2(inst_location, 420)
		elif enemy_type == "fl":
			enemy_instance.position = Vector2(inst_location, 420)
		elif enemy_type == "cg":
			enemy_instance.position = Vector2(inst_location, 710)
		elif enemy_type == "ca":
			enemy_instance.position = Vector2(inst_location, 150)

		editor_screen.add_child(enemy_instance)
		enemy_indices[enemy_instance] = idx_counter
		enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
		enemy_data[idx_counter] = {"position": enemy_instance.position, "type": enemy_type}
		idx_counter += 1
		
func _on_enemy_selected(viewport, event, shape_idx, enemy_instance):
	if event is InputEventMouseButton and event.pressed:
		curr_enemy = enemy_instance
		#print("Selected enemy: ", enemy_instance)
		last_enemy = curr_enemy
	
func _input(event):
	adjust_largest_x()
	if event is InputEventMouseButton and event.is_released():
		$Panel.visible = true
		# print(curr_enemy, " placed at: ", get_global_mouse_position().x, ", ", get_global_mouse_position().y)
		if curr_enemy:
			var idx = enemy_indices.get(curr_enemy)
			if enemy_data.has(idx):
				var new_position = get_global_mouse_position()
				new_position = apply_constraints(new_position, enemy_data[idx]["type"])
				enemy_data[idx]["position"] = new_position
				curr_enemy.position = new_position
				adjust_largest_x()
				print(enemy_data)
				$Panel/SaveButton.disabled = true
				
			else:
				print("Error: No enemy data found for index ", idx)
			curr_enemy = null
		else:
			# Here you might add code to select a new enemy if needed.
			pass
	elif curr_enemy and event is InputEventMouseMotion:
		$Panel.visible = false
		var new_position = curr_enemy.position + event.relative
		new_position = apply_constraints(new_position, enemy_data[enemy_indices[curr_enemy]]["type"])
		curr_enemy.position = new_position
		adjust_largest_x()
		$Panel/SaveButton.disabled = true
	
	if Main.player_input_disabled and (event is InputEventMouseButton and event.pressed):
		var mouse_pos = get_global_mouse_position()
		var line_edit_rect = Rect2($Panel/LineEdit.global_position, $Panel/LineEdit.size)
		if not line_edit_rect.has_point(mouse_pos):
			$Panel/LineEdit.release_focus()

	Main.curr_editor_level_enemy_data = enemy_data
	
func count_enemies():
	return enemy_data.size()
			
func _on_delete_button_pressed(): 
	if last_enemy:
		var idx = enemy_indices.get(last_enemy, null)  # Use enemy_indices to get the index
		if idx != null:
			editor_screen.remove_child(last_enemy)
			last_enemy.queue_free()
			enemy_data.erase(idx)
			enemy_indices.erase(last_enemy)  # Remove from enemy_indices dictionary
			last_enemy = null
			# Note: Don't decrement idx_counter, as it is used to give unique IDs.
		else:
			print("Error: No index found for the selected enemy")

func _on_h_scroll_bar_value_changed(value):
	var scroll_value = value
	camera.position.x = scroll_value + 640
	editor_screen_bounds.position.x = scroll_value
	background.position.x = scroll_value * Main.BG_SPEED + 800

func adjust_largest_x():
	for idx in enemy_data.keys():
		var data = enemy_data[idx]
		if data["position"].x > largest_x:
			largest_x = data["position"].x

func delete_file(file_path: String): 
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File: ", file_path, " deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")

func create_file(file_path: String, enemy_data: Dictionary, largest_x):
	if FileAccess.file_exists(file_path):
		delete_file(file_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("var is_completed = false") # setup the default false value
		file.store_line("var is_saved = false")
		file.store_line("")
		file.store_line("var last_enemy_x = {0}".format([largest_x]))
		file.store_line("")
		file.store_line("var enemy_data = {")
		
		var i = 0
		for idx in enemy_data.keys():
			var data = enemy_data[idx]
			var str = "	{0}: {\"position\": Vector2{1}, \"type\": \"{2}\"},"
			file.store_line(str.format([i, data["position"], data["type"]]))
			i += 1
		
		file.store_line("}")
		
		file.close()
		#print("File created")
		
	else:
		print("Error creating file")

func _on_line_edit_text_submitted(new_text):
	$Panel/LineEdit.release_focus()

func _on_line_edit_text_changed(name_typed):
	name_typed = name_typed.strip_edges()
	if name_typed != "":
		curr_file_path = "res://Script/Levels/" + name_typed + ".gd"
		if name_typed.begins_with("dev_"):
			$Panel/WarningLabel.visible = false
			$Panel/WarningLabel2.visible = true
			$Panel/PlayButton.disabled = true
		elif FileAccess.file_exists(curr_file_path):
			$Panel/WarningLabel.visible = true
			$Panel/WarningLabel2.visible = false
			$Panel/PlayButton.disabled = true
		else:
			$Panel/WarningLabel.visible = false
			$Panel/WarningLabel2.visible = false
			$Panel/PlayButton.disabled = false
			level_file_name = name_typed + ".gd"
			Main.CACHED_EDITOR_LEVEL = curr_file_path
	else:
		$Panel/WarningLabel.visible = false
		$Panel/PlayButton.disabled = true

func _on_play_button_pressed():
	Main.curr_editor_level_enemy_data = enemy_data
	if FileAccess.file_exists(curr_file_path):
		#print("deleting: ", curr_file_path)
		delete_file(curr_file_path) # to overwrite if the user saves again after editing further
		print("deleted old file")
	create_file("res://Script/Levels/" + level_file_name, Main.curr_editor_level_enemy_data, largest_x)
	Main.player_input_disabled = false 
	Main.BOT_NAME = ""
	Main.LEVEL_SCRIPT = "res://Script/Levels/" + level_file_name
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_save_button_pressed():
	Main.player_input_disabled = false
	$Panel/LineEdit.release_focus()
	print("Level saved as: ", level_file_name)
	mark_level_saved()

func apply_constraints(pos: Vector2, enemy_type: String):
	var constraints = y_constraints.get(enemy_type, {})
	if pos.x < 600:
		pos.x = 600
	if constraints.has("fixed"):
		pos.y = constraints["fixed"]
	else:
		if pos.y < constraints.get("min", pos.y):
			pos.y = constraints["min"]
		if pos.y > constraints.get("max", pos.y):
			pos.y = constraints["max"]
	return Vector2(pos.x, pos.y)

func _on_create_new_button_pressed():
	Main.CACHED_EDITOR_LEVEL = ""
	Main.curr_editor_level_enemy_data = {}
	get_tree().reload_current_scene()
	# NOT DONE IMPLEMENTING 

func _on_open_button_pressed():
	level_select_screen.visible = true

func _on_line_edit_focus_entered():
	Main.player_input_disabled = true

func disable_level_select():
	get_tree().reload_current_scene()	
	load_enemies(Main.curr_editor_level_enemy_data)
	
#func load_enemies(file_path: String):
func load_enemies(e_data: Dictionary):
	print(e_data)
	if Main.CACHED_EDITOR_LEVEL: # cached editor level needs to cache enemy data
		var cached_lvl_name = Main.CACHED_EDITOR_LEVEL.trim_prefix("res://Script/Levels/").trim_suffix(".gd")
		$Panel/LineEdit.text = cached_lvl_name
		if not check_level_validity(Main.CACHED_EDITOR_LEVEL):
			print("this file is not validated")
			$Panel/SaveButton.disabled = true
	#var file = FileAccess.open(file_path, FileAccess.READ)
	#if file:
	#	var enemy_data = {}
	#	var largest_x = 0
	#	var in_enemy_data = false
	#	var regex = RegEx.new()
	#	var result
	#	regex.compile("(\\d+): {\"position\": Vector2\\(([^,]+), ([^\\)]+)\\), \"type\": \"([^\"]+)\"},")
		
	#	while not file.eof_reached():
	#		var line = file.get_line().strip_edges()
	#		if line == "var enemy_data = {":
	#			in_enemy_data = true
	#			continue
	#		elif line == "}":
	#			in_enemy_data = false
	#			continue
	#		
	#		if in_enemy_data:
	#			result = regex.search(line)
	#			if result:
	#				var idx = result.get_string(1).to_int()
	#				var pos_x = result.get_string(2).to_float()
	#				var pos_y = result.get_string(3).to_float()
	#				var enemy_type = result.get_string(4)
	#				enemy_data[idx] = {"position": Vector2(pos_x, pos_y), "type": enemy_type}
					
	for idx in e_data.keys():
		var data = e_data[idx]
		var enemy_type = data["type"]
		var enemy_scene = enemy_scenes.get(enemy_type)
			
		if enemy_scene:
			var enemy_instance = enemy_scene.instantiate()
			enemy_instance.position = data["position"]
			editor_screen.add_child(enemy_instance) # editor screen didnt get instantiated yet
			enemy_indices[enemy_instance] = idx
			enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
				# Ensure enemy_data dictionary in the editor is up to date
			self.enemy_data[idx] = {"position": enemy_instance.position, "type": enemy_type}
				
			if enemy_instance.position.x > largest_x:
				largest_x = enemy_instance.position.x
					
		else:
			print("Error: No scene found for enemy type: ", enemy_type)
	#else:
	#	print("Error: Could not open file: ", file_path)

func close_selector():
	if level_select_screen.visible:
		level_select_screen.visible = false
		
func check_level_validity(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var line
		while not file.eof_reached():
			line = file.get_line()
			if line.begins_with("var is_completed"):
				return line == "var is_completed = true"
		return false	
	else:
		print("Error: Could not open file: ", file_path)
		return false

func mark_level_saved():
	var file = FileAccess.open(Main.CACHED_EDITOR_LEVEL_COMPLETED, FileAccess.READ_WRITE)
	if not file:
		print("Error: Could not open file")
		return
	
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	delete_file(Main.CACHED_EDITOR_LEVEL_COMPLETED)
	
	var new_lines = []
	for line in lines:
		if line.strip_edges().begins_with("var is_saved"):
			new_lines.append("var is_saved = true")
		else:
			new_lines.append(line)
	file = FileAccess.open(Main.CACHED_EDITOR_LEVEL_COMPLETED, FileAccess.WRITE)
	print(Main.CACHED_EDITOR_LEVEL_COMPLETED)
	
	for line in new_lines:
		file.store_line(line)
	file.close()
	$Panel/SaveButton.disabled = true # disable until more changes added
	
	
func mark_level_completed():
	var file = FileAccess.open(Main.CACHED_EDITOR_LEVEL_COMPLETED, FileAccess.READ_WRITE)
	if not file:
		print("Error: Could not open file")
		return
	
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	delete_file(Main.CACHED_EDITOR_LEVEL_COMPLETED)
	
	var new_lines = []
	for line in lines:
		if line.strip_edges().begins_with("var is_completed"):
			new_lines.append("var is_completed = true")
		else:
			new_lines.append(line)
			
	file = FileAccess.open(Main.CACHED_EDITOR_LEVEL_COMPLETED, FileAccess.WRITE)
	
	for line in new_lines:
		file.store_line(line)
	file.close()

func _on_quit_button_pressed():
	Main.in_editor = false
	get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")
