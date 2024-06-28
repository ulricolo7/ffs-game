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

func _ready():
	if Main.CACHED_EDITOR_LEVEL:
		var cached_lvl_name = Main.CACHED_EDITOR_LEVEL.trim_prefix("res://Script/Levels/").trim_suffix(".gd")
		$Panel/LineEdit.text = cached_lvl_name
		curr_file_path = Main.CACHED_EDITOR_LEVEL
		level_file_name = cached_lvl_name + ".gd"
		print(level_file_name)
	else:
		level_file_name = "Untitled.gd"
	
	idx_counter = 0
	
	editor_screen = get_parent().get_node("../EditorScreen")
	editor_screen_bounds = get_parent().get_node("../EditorScreen/Boundaries")
	background = get_parent().get_node("../EditorScreen/Background")
	camera = get_parent()
	h_scroll_bar = get_node("../HScrollBar")
	
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("gh"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("fl"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("cg"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ca"))
	
	
	if Main.CACHED_EDITOR_LEVEL:
		$Panel/PlayButton.disabled = false
	else:
		$Panel/PlayButton.disabled = true
	if Main.CACHED_EDITOR_LEVEL_COMPLETED:
		$Panel/SaveButton.disabled = false
	else:
		$Panel/SaveButton.disabled = true
	$Panel/WarningLabel.visible = false
	set_process_input(true)
	
	level_select_screen = level_select_scene.instantiate()
	level_select_screen.visible = false
	level_select_screen.set_z_index(35)
	level_select_screen.position = Vector2(-885,0)
	add_child(level_select_screen)
	level_select_screen.find_child("Panel").connect("level_selected", Callable(self, "disable_level_select"))
	
	if Main.CACHED_EDITOR_LEVEL:
		load_enemies(Main.CACHED_EDITOR_LEVEL)


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
		print("spawned in ", inst_location)
		enemy_indices[enemy_instance] = idx_counter
		enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
		enemy_data[idx_counter] = {"position": enemy_instance.position, "type": enemy_type}
		idx_counter += 1
		print("Index Counter: ", enemy_indices[enemy_instance])
		
func _on_enemy_selected(viewport, event, shape_idx, enemy_instance):
	if event is InputEventMouseButton and event.pressed:
		curr_enemy = enemy_instance
		print("Selected enemy: ", enemy_instance)
		last_enemy = curr_enemy
	
func _input(event):
	adjust_largest_x()
	if event is InputEventMouseButton and event.is_released():
		$Panel.visible = true
		print(curr_enemy, " placed at: ", get_global_mouse_position().x, ", ", get_global_mouse_position().y)
		if curr_enemy:
			var idx = enemy_indices.get(curr_enemy)
			if enemy_data.has(idx):
				var new_position = get_global_mouse_position()
				new_position = apply_constraints(new_position, enemy_data[idx]["type"])
				enemy_data[idx]["position"] = new_position
				curr_enemy.position = new_position
				adjust_largest_x()
				print(enemy_data)
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
	
	if Main.player_input_disabled and (event is InputEventMouseButton and event.pressed):
		var mouse_pos = get_global_mouse_position()
		var line_edit_rect = Rect2($Panel/LineEdit.global_position, $Panel/LineEdit.size)
		if not line_edit_rect.has_point(mouse_pos):
			$Panel/LineEdit.release_focus()
		

func _on_delete_button_pressed(): 
	print("delete button pressed")
	if last_enemy:
		print("delete button executed")
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
			print("File deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")

func create_file(file_path: String, enemy_data: Dictionary, largest_x):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("extends Node")
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
		if FileAccess.file_exists(curr_file_path):
			$Panel/WarningLabel.visible = true
			$Panel/PlayButton.disabled = true
		else:
			$Panel/WarningLabel.visible = false
			$Panel/PlayButton.disabled = false
			level_file_name = name_typed + ".gd"
			Main.CACHED_EDITOR_LEVEL = curr_file_path
	else:
		$Panel/WarningLabel.visible = false
		$Panel/PlayButton.disabled = true

func _on_play_button_pressed():
	delete_file("res://Script/Levels/Untitled.gd")
	if FileAccess.file_exists(curr_file_path):
		print("deleting: ", curr_file_path)
		delete_file(curr_file_path) # to overwrite if the user saves again after editing further
	print("created file: ", level_file_name)
	create_file("res://Script/Levels/" + level_file_name, enemy_data, largest_x)
	Main.player_input_disabled = false 
	$Panel.visible = false
	Main.BOT_NAME = ""
	Main.LEVEL_SCRIPT = "res://Script/Levels/" + level_file_name
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
	# add an editor levle complete scene. To then update the Main.Cached level completed to true

func _on_save_button_pressed():
	Main.player_input_disabled = false
	
	# $Panel/PlayButton.disabled = false  # Enable the play button after saving
	print("Level saved as: ", level_file_name)

func apply_constraints(pos: Vector2, enemy_type: String):
	var constraints = y_constraints.get(enemy_type, {})
	if constraints.has("fixed"):
		pos.y = constraints["fixed"]
	else:
		if pos.y < constraints.get("min", pos.y):
			pos.y = constraints["min"]
		if pos.y > constraints.get("max", pos.y):
			pos.y = constraints["max"]
	return Vector2(pos.x, pos.y)

func _on_create_new_button_pressed():
	#delete_file("res://Script/Levels/Untitled.gd")
	#create_file("res://Script/Levels/Untitled.gd", enemy_data)
	Main.CACHED_EDITOR_LEVEL = ""
	get_tree().reload_current_scene()

func _on_open_button_pressed():
	print("open button pressed")
	level_select_screen.visible = true

func _on_line_edit_focus_entered():
	Main.player_input_disabled = true

func disable_level_select():
	get_tree().reload_current_scene()	
	load_enemies(Main.CACHED_EDITOR_LEVEL)
	
func load_enemies(file_path: String):
	
	if Main.CACHED_EDITOR_LEVEL:
		var cached_lvl_name = Main.CACHED_EDITOR_LEVEL.trim_prefix("res://Script/Levels/").trim_suffix(".gd")
		$Panel/LineEdit.text = cached_lvl_name	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var script_instance = load(file_path).new()
		var enemy_data = script_instance.enemy_data
		print(enemy_data)
		for idx in enemy_data.keys():
			var data = enemy_data[idx]
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
	else:
		print("Error: Could not open file: ", file_path)

func clear_enemies(): # only call this if user is opening a level on top of another level
	if Main.CACHED_EDITOR_LEVEL:
		$Panel/LineEdit.text = ""
	
