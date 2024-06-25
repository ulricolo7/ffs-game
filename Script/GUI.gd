extends Control

var curr_enemy = null
var last_enemy = null
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

var y_constraints = {
	"gh": { "min": 160, "max": 670 },
	"fl": { "min": 130, "max": 700 },
	"cg": { "fixed": 710 },
	"ca": { "min": 120, "max": 380 }
}

#overall, what I did was I added a Camera2D as a child to Editor and attached GUI to it,
#and moved the Background Sprite to be separate from the Map

func _ready():
	idx_counter = 0
	#You made good call for references *thumbsup
	editor_screen = get_parent().get_node("../EditorScreen")
	editor_screen_bounds = get_parent().get_node("../EditorScreen/Boundaries")
	background = get_parent().get_node("../EditorScreen/Background")
	camera = get_parent()
	h_scroll_bar = get_node("../HScrollBar")
	
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("gh"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("fl"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("cg"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ca"))
	
	#The HSCrollbar is already emitting a signal. GPT doesnt know this and
	#this line to 'connect' is actually unnecessary
	#h_scroll_bar.connect("value_changed", Callable(self, "_on_h_scroll_bar_value_changed"))
	
	# max_value input is in the inspector tab for the hscrollbar
	#h_scroll_bar.max_value = 32000
	set_process_input(true)


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
	if event is InputEventMouseButton and event.is_released():
		$Panel.visible = true
		print(curr_enemy, " placed at: ", get_global_mouse_position().x, ", ", get_global_mouse_position().y)
		if curr_enemy:
			var idx = enemy_indices.get(curr_enemy)
			if enemy_data.has(idx):
				var new_position = get_global_mouse_position()
				
				if enemy_data[idx]["type"] == "gh":
					if new_position.y < 160:
						new_position.y = 160
					if new_position.y > 670:
						new_position.y = 670
				if enemy_data[idx]["type"] == "fl":
					if new_position.y < 130:
						new_position.y = 130
					if new_position.y > 700:
						new_position.y = 700
				if enemy_data[idx]["type"] == "cg":
					new_position.y = 710
				if enemy_data[idx]["type"] == "ca":
					if new_position.y > 380:
						new_position.y = 380
					if new_position.y < 120:
						new_position.y = 120
						
				enemy_data[idx]["position"] = new_position
				curr_enemy.position = new_position
				print(enemy_data)
			else:
				print("Error: No enemy data found for index ", idx)
			curr_enemy = null
		else:
			# Here you might add code to select a new enemy if needed.
			pass
	elif curr_enemy and event is InputEventMouseMotion:
		$Panel.visible = false
		curr_enemy.position += event.relative
		

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

func _on_play_button_pressed():
	$Panel.visible = false
	# logic to make this into a level and play
	delete_file("res://Script/Levels/Untitled.gd")
	create_file("res://Script/Levels/Untitled.gd", enemy_data)
	Main.BOT_NAME = ""
	Main.LEVEL_SCRIPT = "res://Script/Levels/Untitled.gd"
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_h_scroll_bar_value_changed(value):
	#lemme explain the code
	#the argument 'value' is the value of the scroller in the hscrollbar
	#we can set its min and max in the inspector tab or manually like what u did
	#to make it simple, I just gave it min 0 max 30000 as that is our max level length
	#you can find a logic to auto change the max level length according to the last enemy
	#I leave that to u
	var scroll_value = value
	
	#as the value starts from 0, the camera might snap backwards as the camera
	#should start from 640 (middle of screen). Hence it is 640 + scroll_value
	camera.position.x = scroll_value + 640
	
	#the editor screen starts from 0 anyways (refer to the 2D tab/check position 
	#under transform). So this I just leave it to scroll_value
	editor_screen_bounds.position.x = scroll_value
	
	#the speed of the bg is 0.99 (now I have edited so that Main.gd has that data)
	#the background is also longer than other sprites and it starts at 800, not 640
	#(the centre of the background is at 800), hence:
	background.position.x = scroll_value * Main.BG_SPEED + 800

#1600
#1280
#320px difference = real time speed of which the background can shift left relative to camera
#320 / 0.01 = 32000 max length



func _on_create_new_button_pressed():
	delete_file("res://Script/Levels/Untitled.gd")
	create_file("res://Script/Levels/Untitled.gd", enemy_data)

func delete_file(file_path: String): 
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("File deleted successfully")
		else:
			print("Error deleting file: ", err)
	else:
		print("File does not exist")

func create_file(file_path: String, enemy_data: Dictionary):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		#if it works, it works.
		file.store_line("extends Node")
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
		print("File created")

		#if FileAccess.file_exists(file_path):
			#delete_file(file_path)
	else:
		print("Error creating file")

