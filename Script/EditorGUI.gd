extends Control

const LEVEL_SELECT_SCENE = preload("res://Scenes/level_select.tscn")
const ENEMY_SCENES = {
	"gh": preload("res://Scenes/Enemies/Ghaster/ghaster_static.tscn"),
	"fl": preload("res://Scenes/Enemies/Flapper/flapper_static.tscn"),
	"cg": preload("res://Scenes/Enemies/Crawler/crawler_ground_static.tscn"),
	"ca": preload("res://Scenes/Enemies/Crawler/crawler_air_static.tscn")
}
const LEVELS_FOLDER = "res://Script/Levels/"
const FILE_EXTENSION = ".gd"
const Y_CONSTRAINTS = {
	"gh": { "min": 160, "max": 670 },
	"fl": { "min": 130, "max": 700 },
	"cg": { "fixed": 710 },
	"ca": { "min": 120, "max": 420 }
}

const SCROLL_FACTOR = 0.01

var level_select_screen
var curr_enemy = null
var largest_x = -100
var enemy_data = {}
var enemy_indices = {}
var h_scroll_bar
var editor_screen
var editor_screen_bounds
var background
var camera
var idx_counter
var level_file_name
var curr_file_path
var right_click_pressed
var file_not_saved_popup
var file_name_unchanged_popup
var instructions_panel 
var level_not_shareable_popup
var sharing_panel


func _ready():
	Main.editor_paused2 = false
	Main.player_input_disabled = false
	Main.in_open_file = false
	play_click_sfx()
	#if Main.CURR_EDITOR_LEVEL_COMPLETED:
	#	mark_level("completed", "true")
	$Panel/PlayButton.disabled = true
	$Panel/SaveButton.disabled = true
	$Panel/WarningLabel.visible = false
	$Panel/WarningLabel2.visible = false
	initialize_scene_references()
	initialize_enemy_buttons()
	initialize_level_select_screen()
	
	if Main.CURR_EDITOR_LEVEL:
		load_enemies(Main.curr_editor_level_enemy_data)
		enemy_data = Main.curr_editor_level_enemy_data
		level_file_name = Main.CURR_EDITOR_LEVEL.trim_prefix(LEVELS_FOLDER).trim_suffix(FILE_EXTENSION) + ".gd"
		curr_file_path = Main.CURR_EDITOR_LEVEL
	else: 
		create_file("res://Script/Levels/Untitled.gd", {}, 0)
		Main.CURR_EDITOR_LEVEL = "res://Script/Levels/Untitled.gd"
		curr_file_path = Main.CURR_EDITOR_LEVEL
		level_file_name = "Untitled"
	idx_counter = count_enemies()
	set_process_input(true)

func _process(delta):
	if (level_file_name != "Untitled") and enemy_data.size() > 0 and not Main.editor_paused and not Main.editor_paused2:
		$Panel/PlayButton.disabled = false
		$Panel/SaveButton.disabled = false
	else:
		$Panel/PlayButton.disabled = true
		$Panel/SaveButton.disabled = true
	
	if Main.editor_paused2 or Main.editor_paused:
		$Panel/LineEdit.editable = false
		$Panel/CreateNewButton.disabled = true
		$Panel/OpenButton.disabled = true
		$Panel/ShareButton.disabled = true
		$Panel/InstructionsButton.disabled = true
		$Panel/QuitButton.disabled = true
	else:
		$Panel/LineEdit.editable = true
		$Panel/CreateNewButton.disabled = false
		$Panel/OpenButton.disabled = false
		$Panel/ShareButton.disabled = false
		$Panel/InstructionsButton.disabled = false
		$Panel/QuitButton.disabled = false

func initialize_scene_references():
	editor_screen = get_parent().get_node("../EditorScreen")
	editor_screen_bounds = get_parent().get_node("../EditorScreen/Boundaries")
	background = get_parent().get_node("../EditorScreen/Background")
	camera = get_parent()
	h_scroll_bar = get_node("../HScrollBar")
	file_not_saved_popup = get_parent().get_node("../NotSavedWarning")
	file_name_unchanged_popup = get_parent().get_node("../RenameFileWarning")
	instructions_panel = get_parent().get_node("../EditorInstructions")
	level_not_shareable_popup = get_parent().get_node("../InvalidShareLevelW")
	sharing_panel = get_parent().get_node("../SharingPanel")

func initialize_enemy_buttons():
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("gh"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("fl"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("cg"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ca"))

func initialize_level_select_screen():
	level_select_screen = init_screen(level_select_screen, LEVEL_SELECT_SCENE, false, 35)
	level_select_screen.position = Vector2(-885, 0)
	level_select_screen.connect("level_selected", Callable(self, "disable_level_select"))
	level_select_screen.connect("level_not_saved", Callable(self, "show_not_saved_warning"))
	level_select_screen.find_child("Panel").find_child("open_file_quit").connect("close_level_select", Callable(self, "close_selector"))

func _on_enemy_button_pressed(enemy_type):
	if Main.editor_paused:
		pass
	else:
		play_click_sfx()
		var enemy_scene = ENEMY_SCENES.get(enemy_type)
		var inst_location = camera.position.x
		mark_level("completed", "false")
		mark_level("saved", "false")
		reload_level_select_screen()

		if enemy_scene:
			var enemy_instance = enemy_scene.instantiate()
			enemy_instance.position = get_enemy_initial_position(enemy_type, inst_location)
			add_enemy_to_screen(enemy_instance, enemy_type)

func get_enemy_initial_position(enemy_type, inst_location):
	var y_pos = 420
	if enemy_type == "cg":
		y_pos = 710
	elif enemy_type == "ca":
		y_pos = 150
	return Vector2(inst_location, y_pos)

func add_enemy_to_screen(enemy_instance, enemy_type):
	editor_screen.add_child(enemy_instance)
	enemy_indices[enemy_instance] = idx_counter
	enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
	enemy_data[idx_counter] = {"position": enemy_instance.position, "type": enemy_type}
	idx_counter += 1

func _on_enemy_selected(viewport, event, shape_idx, enemy_instance):
	#play_click_sfx()
	if event is InputEventMouseButton and event.pressed:
		curr_enemy = enemy_instance
	
func _input(event):
	adjust_largest_x()
	if Input.is_action_pressed("delete_enemy"):
		right_click_pressed = true

	if  event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		right_click_pressed = false
		delete_curr_enemy()
		$Panel.visible = true
		mark_level("saved", "false")
		mark_level("completed", "false")
		reload_level_select_screen()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		right_click_pressed = false
		$Panel.visible = true
		if curr_enemy:
			var idx = enemy_indices.get(curr_enemy)
			if enemy_data.has(idx):
				var new_position = get_global_mouse_position()
				new_position = apply_constraints(new_position, enemy_data[idx]["type"])
				enemy_data[idx]["position"] = new_position
				curr_enemy.position = new_position
				adjust_largest_x()
				mark_level("saved", "false")
				mark_level("completed", "false")
				reload_level_select_screen()
			else:
				print("Error: No enemy data found for index ", idx)
			curr_enemy = null
		else:
			# Here you might add code to select a new enemy if needed.
			pass
	elif curr_enemy and event is InputEventMouseMotion:
		if right_click_pressed:
			return
		else:
			$Panel.visible = false
			var new_position = curr_enemy.position + event.relative
			new_position = apply_constraints(new_position, enemy_data[enemy_indices[curr_enemy]]["type"])
			curr_enemy.position = new_position
			adjust_largest_x()
			mark_level("saved", "false")
			mark_level("completed", "false")
	
	if Main.player_input_disabled and (event is InputEventMouseButton and event.pressed):
		var mouse_pos = get_global_mouse_position()
		var line_edit_rect = Rect2($Panel/LineEdit.global_position, $Panel/LineEdit.size)
		if not line_edit_rect.has_point(mouse_pos):
			$Panel/LineEdit.release_focus()
			Main.player_input_disabled = false
	
	Main.curr_editor_level_enemy_data = enemy_data

func delete_curr_enemy():
	play_click_sfx()
	if curr_enemy:
		var idx = enemy_indices.get(curr_enemy)
		if enemy_data.has(idx):
			editor_screen.remove_child(curr_enemy)
			enemy_data.erase(idx)
			curr_enemy.queue_free()
			curr_enemy = null
			adjust_largest_x()
			mark_level("saved", "false")
			# change this to mark unsaved and unvalidated
		else:
			print("Error: No enemy data found for index ", idx)
	else:
		print("Error: No current enemy to delete")
		
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
	else:
		print("Error creating file")

func delete_file(file_path: String): 
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File: ", file_path, " deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")

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
			level_file_name = name_typed + ".gd"
			Main.CURR_EDITOR_LEVEL = curr_file_path
	else:
		$Panel/WarningLabel.visible = false
		level_file_name = "Untitled"

func _on_line_edit_text_submitted(new_text):
	$Panel/LineEdit.release_focus()

func _on_play_button_pressed():
	play_click_sfx()
	var curr_lvl_is_saved
	var curr_lvl_is_completed
	if FileAccess.file_exists(curr_file_path):
		if check_level_saved(curr_file_path):
			curr_lvl_is_saved = true
		if check_level_validity(curr_file_path):
			curr_lvl_is_completed = true
		delete_file(curr_file_path) # to overwrite if the user saves again after editing further
	create_file("res://Script/Levels/" + level_file_name, Main.curr_editor_level_enemy_data, largest_x)
	if curr_lvl_is_saved:
		mark_level("saved", "true")
	if curr_lvl_is_completed:
		mark_level("completed", "true")
	Main.curr_editor_level_enemy_data = enemy_data
	
	Main.player_input_disabled = false 
	Main.BOT_NAME = ""
	Main.LEVEL_SCRIPT = "res://Script/Levels/" + level_file_name # check if needed
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_save_button_pressed():
	play_click_sfx()
	var curr_lvl_is_completed
	if FileAccess.file_exists(curr_file_path):
		if check_level_validity(curr_file_path):
			curr_lvl_is_completed = true
		delete_file(curr_file_path) # to overwrite if the user saves again after editing further
	create_file("res://Script/Levels/" + level_file_name, Main.curr_editor_level_enemy_data, largest_x)
	Main.player_input_disabled = false
	$Panel/LineEdit.release_focus()
	$Panel/PlayButton.disabled = false
	mark_level("saved", "true")
	if curr_lvl_is_completed:
		mark_level("completed", "true")
	reload_level_select_screen()

func apply_constraints(pos: Vector2, enemy_type: String):
	var constraints = Y_CONSTRAINTS.get(enemy_type, {})
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
	
func load_enemies(e_data: Dictionary):
	print(e_data)
	if Main.CURR_EDITOR_LEVEL != "res://Script/Levels/Untitled.gd":
		var cached_lvl_name = Main.CURR_EDITOR_LEVEL.trim_prefix(LEVELS_FOLDER).trim_suffix(FILE_EXTENSION)
		$Panel/LineEdit.text = cached_lvl_name
		
	for idx in e_data.keys():
		add_enemy_instance(e_data[idx], idx)

func add_enemy_instance(data, idx):
	var enemy_type = data["type"]
	var enemy_scene = ENEMY_SCENES.get(enemy_type)
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.position = data["position"]
		editor_screen.add_child(enemy_instance)
		enemy_indices[enemy_instance] = idx
		enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
		enemy_data[idx] = {"position": enemy_instance.position, "type": enemy_type}
		update_largest_x(enemy_instance.position.x)
	else:
		print("Error: No scene found for enemy type: ", enemy_type)

		
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

func check_level_saved(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var line
		while not file.eof_reached():
			line = file.get_line()
			if line.begins_with("var is_saved"):
				return line == "var is_saved = true"
		return false	
	else:
		print("Error: Could not open file: ", file_path)
		return false

func mark_level(mark: String, truthy: String):
	var file = FileAccess.open(Main.CURR_EDITOR_LEVEL, FileAccess.READ_WRITE)
	if not file:
		print("Error: Could not open file")
		return
	
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	delete_file(Main.CURR_EDITOR_LEVEL)
	var new_lines = []
	for line in lines:
		if line.strip_edges().begins_with("var is_{mark}".format({"mark": mark})):
			new_lines.append("var is_{mark} = {truthy}".format({"mark": mark, "truthy": truthy}))
		else:
			new_lines.append(line)
			
	file = FileAccess.open(Main.CURR_EDITOR_LEVEL, FileAccess.WRITE)
	
	for line in new_lines:
		file.store_line(line)
	file.close()

# HELPER AND OBVIOUS FUNCTIONS BELOW

func init_screen(var_name, scene_name, visibility, z_ind):
	var_name = scene_name.instantiate()
	var_name.set_visible(visibility)
	var_name.set_z_index(z_ind)
	add_child(var_name)
	return var_name

func _on_line_edit_focus_entered():
	Main.player_input_disabled = true

func disable_level_select():
	# add here the verification
	get_tree().reload_current_scene()
	load_enemies(Main.curr_editor_level_enemy_data)
	
func _on_h_scroll_bar_value_changed(value):
	var scroll_value = value
	camera.position.x = scroll_value + 640
	editor_screen_bounds.position.x = scroll_value
	background.position.x = scroll_value * Main.BG_SPEED + 800

func update_largest_x(x):
	if x > largest_x:
		largest_x = x

func adjust_largest_x():
	largest_x = 0
	for idx in enemy_data.keys():
		var data = enemy_data[idx]
		if data["position"].x > largest_x:
			largest_x = data["position"].x

func _on_quit_button_pressed():
	play_click_sfx()
	if not check_level_saved(curr_file_path) and count_enemies() > 0:
		show_not_saved_warning()
	else:
		Main.in_editor = false
		Main.CURR_EDITOR_LEVEL = ""
		Main.CURR_EDITOR_LEVEL_COMPLETED = ""
		Main.curr_editor_level_enemy_data = {}
		# may need to delete untitled
		get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")

func close_selector():
	if level_select_screen.visible:
		level_select_screen.visible = false

func _on_create_new_button_pressed():
	play_click_sfx()
	if not check_level_saved(curr_file_path) and count_enemies() > 0:
		Main.level_switching = true
		show_not_saved_warning()
	else:
		Main.CURR_EDITOR_LEVEL = ""
		Main.CURR_EDITOR_LEVEL_COMPLETED = ""
		Main.curr_editor_level_enemy_data = {}
		get_tree().reload_current_scene()
	# NOT DONE IMPLEMENTING 
	
func _on_open_button_pressed():
	play_click_sfx()
	Main.editor_paused2 = true
	Main.player_input_disabled = true
	if not check_level_saved(curr_file_path) and count_enemies() > 0:
		Main.level_switching = true
	level_select_screen.visible = true
	Main.in_open_file = true

func count_enemies():
	return enemy_data.size()

func _on_upload_music_button_pressed():
	play_click_sfx()
	var dialog = $Panel/UploadMusic
	dialog.visible = true

func _on_upload_music_file_selected(path):
	play_click_sfx()
	var audio_player = $"../../AudioStreamPlayer"
	audio_player.stream = path
	audio_player.play()

func play_click_sfx():
	$"../../ClickSFX".play()

func reload_level_select_screen():
	if level_select_screen:
		level_select_screen.queue_free()
	level_select_screen = LEVEL_SELECT_SCENE.instantiate()
	level_select_screen.set_visible(false) # Set initial visibility as required
	level_select_screen.set_z_index(35)
	add_child(level_select_screen)
	
	# Set its position and connect signals again
	level_select_screen.position = Vector2(-885, 0)
	level_select_screen.connect("level_selected", Callable(self, "disable_level_select"))
	level_select_screen.connect("level_not_saved", Callable(self, "show_not_saved_warning"))
	level_select_screen.find_child("Panel").find_child("open_file_quit").connect("close_level_select", Callable(self, "close_selector"))
	


func _on_save_and_exit_button_pressed():
	play_click_sfx()
	if Main.level_switching:
		if Main.in_open_file:
			if Main.CURR_EDITOR_LEVEL == "res://Script/Levels/Untitled.gd":
				show_change_name_warning()
				file_not_saved_popup.position.x = -1000
			else:
				_on_save_button_pressed()
				Main.level_switching = false
				Main.editor_paused = false
				Main.CURR_EDITOR_LEVEL = Main.PREP_EDITOR_LEVEL
				Main.curr_editor_level_enemy_data = Main.prep_editor_level_enemy_data
				get_tree().reload_current_scene()
		else:
			if Main.CURR_EDITOR_LEVEL == "res://Script/Levels/Untitled.gd":
				show_change_name_warning()
				file_not_saved_popup.position.x = -1000
			else:
				_on_save_button_pressed()
				Main.CURR_EDITOR_LEVEL = ""
				Main.CURR_EDITOR_LEVEL_COMPLETED = ""
				Main.curr_editor_level_enemy_data = {}
				Main.level_switching = false
				Main.editor_paused = false
				get_tree().reload_current_scene()
	else: 
		if Main.CURR_EDITOR_LEVEL == "res://Script/Levels/Untitled.gd":
			show_change_name_warning()
			file_not_saved_popup.position.x = -1000
		else:
			_on_save_button_pressed()
			Main.CURR_EDITOR_LEVEL = ""
			Main.CURR_EDITOR_LEVEL_COMPLETED = ""
			Main.curr_editor_level_enemy_data = {}
			Main.in_editor = false
			get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")

func _on_back_button_pressed():
	play_click_sfx()
	Main.level_switching = false
	Main.editor_paused = false
	set_process_input(true)
	file_not_saved_popup.position.x = -1000


func _on_dont_save_button_pressed():
	play_click_sfx()
	if Main.level_switching:
		if Main.in_open_file:
			Main.level_switching = false
			Main.editor_paused = false
			Main.CURR_EDITOR_LEVEL = Main.PREP_EDITOR_LEVEL
			Main.curr_editor_level_enemy_data = Main.prep_editor_level_enemy_data
			get_tree().reload_current_scene()
		else:
			Main.CURR_EDITOR_LEVEL = ""
			Main.CURR_EDITOR_LEVEL_COMPLETED = ""
			Main.curr_editor_level_enemy_data = {}
			Main.level_switching = false
			Main.editor_paused = false
			get_tree().reload_current_scene()
	else: 
		Main.in_editor = false
		Main.editor_paused = false
		Main.CURR_EDITOR_LEVEL = ""
		Main.CURR_EDITOR_LEVEL_COMPLETED = ""
		Main.curr_editor_level_enemy_data = {}
		get_tree().change_scene_to_file("res://Scenes/menu_interface.tscn")
	

func show_not_saved_warning():
	print("show panel")
	file_not_saved_popup.position.x = camera.position.x - 320
	Main.editor_paused = true
	set_process_input(false)

func show_change_name_warning():
	Main.editor_paused = true
	level_select_screen.find_child("Panel").find_child("open_file_quit").disabled = true
	file_name_unchanged_popup.position.x = camera.position.x - 220

func signal_test():
	print("signal received")

func _on_go_back_button_pressed():
	print("this")
	play_click_sfx()
	set_process_input(true)
	file_name_unchanged_popup.position.x = -1800
	file_not_saved_popup.position.x = camera.position.x - 320

func _on_instructions_button_pressed():
	play_click_sfx()
	instructions_panel.position.x = camera.position.x - 320
	Main.editor_paused = true

func _on_instructions_quit_button_pressed():
	play_click_sfx()
	instructions_panel.position.x = -1800
	Main.editor_paused = false

# LEVEL SHARING CODE BELOW

func _on_share_button_pressed():
	play_click_sfx()
	if not check_level_validity(curr_file_path):
		var popup_content = level_not_shareable_popup.find_child("Content")
		level_not_shareable_popup.position.x = camera.position.x - 320
		popup_content.text = "Level \"{0}\" is not completed and cannot be shared!".format([curr_file_path.get_file().get_basename()])
		Main.player_input_disabled = true
		Main.editor_paused2 = true
	else: 
		Main.player_input_disabled = true
		Main.editor_paused2 = true
		sharing_panel.position.x = camera.position.x - 320
		var serialized_level_data = serialize_level(enemy_data)
		var encoded_level_data = encode_level_data(serialized_level_data)
		print(encoded_level_data)
		sharing_panel.find_child("ExportCode").text = encoded_level_data
		

func _on_back_button_2_pressed():
	play_click_sfx()
	Main.player_input_disabled = false
	Main.editor_paused2 = false
	level_not_shareable_popup.position.x = - 3100

func serialize_level(level_data: Dictionary) -> String:
	var json = JSON.new()
	return json.stringify(level_data)

const BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
func to_base64(data: PackedByteArray) -> String:
	var output = ""
	var padding = ""
	var data_size = data.size()
	var i = 0

	while i < data_size:
		var byte1 = data[i]
		var byte2 = 0
		var byte3 = 0
		if i + 1 < data_size:
			byte2 = data[i + 1]
		if i + 2 < data_size:
			byte3 = data[i + 2]

		output += BASE64_ALPHABET[(byte1 >> 2) & 0x3F]
		output += BASE64_ALPHABET[((byte1 & 0x3) << 4) | ((byte2 >> 4) & 0x0F)]
		if i + 1 < data_size:
			output += BASE64_ALPHABET[((byte2 & 0xF) << 2) | ((byte3 >> 6) & 0x03)]
		else:
			padding += "="
		if i + 2 < data_size:
			output += BASE64_ALPHABET[byte3 & 0x3F]
		else:
			padding += "="
		i += 3
	return output + padding

func from_base64(data: String) -> PackedByteArray:
	var output = PackedByteArray()
	var padding = 0
	if data.ends_with("=="):
		padding = 2 
	elif data.ends_with("="):
		padding = 1
	var data_size = data.length() - padding
	var i = 0

	while i < data_size:
		var enc1 = BASE64_ALPHABET.find(data[i])
		var enc2 = BASE64_ALPHABET.find(data[i + 1])
		var enc3 = 0
		if i + 2 < data_size:
			enc3 = BASE64_ALPHABET.find(data[i + 2]) 
		var enc4 = 0
		if i + 3 < data_size:
			enc4 = BASE64_ALPHABET.find(data[i + 3]) 

		var byte1 = (enc1 << 2) | (enc2 >> 4)
		var byte2 = ((enc2 & 15) << 4) | (enc3 >> 2)
		var byte3 = ((enc3 & 3) << 6) | enc4

		output.append(byte1)
		if i + 2 < data_size:
			output.append(byte2)
		if i + 3 < data_size:
			output.append(byte3)
		i += 4
	return output

func encode_level_data(data: String) -> String:
	var bytes = data.to_utf8_buffer()
	var compressed_bytes = bytes.compress(2)
	var original_size = str(bytes.size())
	var encoded_size = to_base64(original_size.to_utf8_buffer())
	return encoded_size + ":" + to_base64(compressed_bytes)

func decode_level_data(encoded_data: String) -> String:
	var split_data = encoded_data.split(":")
	var encoded_size = split_data[0]
	var encoded_content = split_data[1]
	
	var original_size_bytes = from_base64(encoded_size)
	var original_size = int(original_size_bytes.get_string_from_utf8())

	var compressed_bytes = from_base64(encoded_content)
	var decompressed_bytes = compressed_bytes.decompress(original_size, 2)
	return decompressed_bytes.get_string_from_utf8()

func _on_exit_share_button_pressed():
	play_click_sfx()
	Main.player_input_disabled = false
	Main.editor_paused2 = false
	sharing_panel.position.x = 1700

func _on_copy_code_button_pressed():
	play_click_sfx()
	Main.player_input_disabled = true
	Main.editor_paused2 = true
	DisplayServer.clipboard_set(sharing_panel.find_child("ExportCode").text)
	sharing_panel.find_child("CopiedToClipboardNotif").visible = true
	sharing_panel.find_child("ClipboardNotifTimer").start(2.5)

func _on_clipboard_notif_timer_timeout():
	sharing_panel.find_child("CopiedToClipboardNotif").visible = false
