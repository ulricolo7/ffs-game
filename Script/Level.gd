extends Node2D

#enemy scenes
const GhasterScene = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FlapperScene = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CrawlerGroundScene = preload("res://Scenes/Enemies/Crawler/crawler_ground.tscn")
const CrawlerAirScene = preload("res://Scenes/Enemies/Crawler/crawler_air.tscn")

#level scenes
const GroundScene = preload("res://Scenes/ground.tscn")
const TreeShortScene = preload("res://Scenes/tree_short_2.tscn")
const TreeMedScene = preload("res://Scenes/tree_medium_2.tscn")
const TreeTallScene = preload("res://Scenes/tree_tall_2.tscn")

#interface scenes
const victory_scene = preload("res://Scenes/win.tscn")
const death_scene = preload("res://Scenes/died.tscn")
const pause_scene = preload("res://Scenes/paused.tscn")
const pause_scene_editor = preload("res://Scenes/pause_editor.tscn")

#variables
var SCREEN_LAYER = 30

var victory_screen
var death_screen
var pause_screen
var pause_screen_editor

var player
var player_scene

@onready var camera = $Camera
@onready var bg = $Background
@onready var progress_bar = $Camera/ProgressBar
@onready var tree_layer = $TreeLayer
@onready var go_sign = $"GO!"

var is_paused = false
@onready var pause_timer = $PauseTimer
@onready var death_timer = $DeathTimer
@onready var start_timer = $StartTimer

var enemy_data: Dictionary
var last_enemy
var LEVEL_LENGTH
var level_script

#functions
func _ready():
	Main.player_input_disabled = false
	init_level(Main.LEVEL_SCRIPT)
	spawn_ground(1200)
	spawn_trees()
	spawn_enemies()
	spawn_ground(1000)
	player = init_player(Main.BOT_NAME)
	#print("Level ready")
	start_run()
	

func _process(delta):
	if Input.is_action_just_pressed("pause") && start_timer.is_stopped():
		play_click_sfx()
		toggle_pause()
	camera.position.x += Main.SCROLL_SPEED * delta
	bg.position.x += Main.SCROLL_SPEED * delta * Main.BG_SPEED
	tree_layer.position.x += Main.SCROLL_SPEED * delta * 0.9
	progress_bar.value = ((camera.global_position.x - 640) / (LEVEL_LENGTH - 640)) * 100
	go_sign.global_position.x -= delta * 50
	
	
	if camera.position.x > LEVEL_LENGTH:
		win()

func toggle_pause():
	if is_paused:
		resume()
	else:
		pause()
	pause_timer.start(0.1)	

func init_level(level_script):
	if Main.in_editor:
		enemy_data = Main.curr_editor_level_enemy_data
	else:
		read_enemy_data(level_script)
	#change this
	
	Main.LEVEL_LENGTH = extract_largest_x(level_script) + 640
	LEVEL_LENGTH = Main.LEVEL_LENGTH

	death_timer.connect("timeout", Callable(self, "_on_death_timeout"))
	
	victory_screen = init_screen(victory_screen, victory_scene, false, SCREEN_LAYER)
	death_screen = init_screen(death_screen, death_scene, false, SCREEN_LAYER)
	pause_screen = init_screen(pause_screen, pause_scene, false, SCREEN_LAYER)
	pause_screen_editor = init_screen(pause_screen_editor, pause_scene_editor, false, SCREEN_LAYER)
	
	Main.no_pause_state = 1
	#print("Level initialized")

func init_screen(var_name, scene_name, visibility, z_ind):

	var_name = scene_name.instantiate()
	var_name.set_visible(visibility)
	var_name.set_z_index(z_ind)
	add_child(var_name)
	
	#print(var_name, " initialized")
	return var_name

func init_player(bot_name):
	if bot_name == "res://Scenes/Player/SHAKER[Medium].tscn":
		player_scene = preload("res://Scenes/Player/SHAKER[Medium].tscn")
	elif bot_name == "res://Scenes/Player/WEAVER[Medium].tscn":
		player_scene = preload("res://Scenes/Player/WEAVER[Medium].tscn")
	elif bot_name == "res://Scenes/Player/MAIDEN[Easy].tscn":
		player_scene = preload("res://Scenes/Player/MAIDEN[Easy].tscn")
	else:
		player_scene = preload("res://Scenes/Player/player_character.tscn")
	
	player = player_scene.instantiate()
	player.position = Vector2(-450, 0)
	player.scale = Vector2(1.5, 1.5)
	camera.add_child(player)
	
	player.connect("player_died", Callable(self, "die"))
	pause_screen.connect("resumed", Callable(self, "resume"))
	pause_screen_editor.connect("resumed", Callable(self, "resume"))
	
	print("Player intialized")
	return player

func spawn_enemies():
	var enemy_instance
	
	for idx in enemy_data.keys():
		var data = enemy_data[idx]
		if data["type"] == "gh":
			enemy_instance = GhasterScene.instantiate()
		elif data["type"] == "fl":
			enemy_instance = FlapperScene.instantiate()
		elif data["type"] == "cg":
			enemy_instance = CrawlerGroundScene.instantiate()
		elif data["type"] == "ca":
			enemy_instance = CrawlerAirScene.instantiate()
			
		enemy_instance.position = data["position"]
		add_child(enemy_instance)
	
	#print("Enemies spawned")

func spawn_ground(value):
	var dist_covered = 0
	var ground_instance
	
	while dist_covered < LEVEL_LENGTH + 2000:
		ground_instance = GroundScene.instantiate()
		ground_instance.position = Vector2(dist_covered, 193.662)
		dist_covered += value
		add_child(ground_instance)
	
	#print("Ground spawned")
	
func spawn_trees():
	var dist_covered = 0
	var tree_instance
	
	while dist_covered < LEVEL_LENGTH:
		var rand = randi() % 3
		
		if rand == 1:
			tree_instance = TreeShortScene.instantiate()
		elif rand == 2:
			tree_instance = TreeMedScene.instantiate()
		else:
			tree_instance = TreeTallScene.instantiate()
			
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var dist_between = rng.randf_range(150.0, 1500.0)
		
		dist_covered += dist_between
		tree_instance.position = Vector2(dist_covered, 530)
		add_child(tree_instance)
	
	#print("Trees spawned")

func start_run():
	pause()
	if Main.in_editor:
		pause_screen_editor.set_visible(false)
	else:
		pause_screen.set_visible(false)
	start_timer.start(1)

func win():
	Main.pause()
	
	victory_screen.set_position(Vector2(camera.get_position().x - 640, 
		camera.get_position().y - 420))
		
	#if victory_screen.visible == false:
	#	print("Win!")
		
	victory_screen.set_visible(true)
	player.freeze()

func die():
	Main.pause()
	Main.player_input_disabled = true

	death_screen.set_position(Vector2(camera.get_position().x - 640, 
		camera.get_position().y - 420))
	death_screen._ready()
	death_screen.set_visible(true)
	
	if Main.AUTO_REPLAY == true:
		death_timer.start(0.9)
	
	#print("Game Over")

func pause():
	if Main.no_pause_state == 1:
		Main.no_pause_state = 0
		
		pause_screen.set_position(Vector2(camera.get_position().x - 640, 
			camera.get_position().y - 420))
		pause_screen_editor.set_position(Vector2(camera.get_position().x - 640, 
			camera.get_position().y - 420))
		if Main.in_editor:
			pause_screen_editor.set_visible(true)
		else:
			pause_screen.set_visible(true)
		player.freeze()
		
	# can make the music change to the main menu here?
		is_paused = true
		
		print("Paused")

func resume():
	if Main.no_pause_state == 0 and not Main.in_editor:
		Main.no_pause_state = 1
		pause_screen.visible = false
		player.unfreeze()
		is_paused = false
		
		print("Resumed")
	elif Main.no_pause_state == 0 and Main.in_editor:
		Main.no_pause_state = 1
		pause_screen_editor.visible = false
		player.unfreeze()
		is_paused = false
		
		print("Resumed")
		
func _on_death_timeout():
	get_tree().reload_current_scene()

func extract_largest_x(level_script):
	var file = FileAccess.open(level_script, FileAccess.READ)
	if file:
		var line
		while not file.eof_reached():
			line = file.get_line()
			if line.begins_with("var last_enemy_x = "):
				var parts = line.split(" = ")
				return parts[1].to_float()
		return 0.0	
	else:
		print("Error: Could not open file: ", level_script)
		return 0.0
	
func read_enemy_data(level_script):
	var file = FileAccess.open(level_script, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			if line.begins_with("var enemy_data"):
				line = file.get_line()
				while not line.begins_with("}") and not file.eof_reached():
					var parts = extract_line(line)
					if parts.size() == 4:
						var key = int(parts[0])
						var position = Vector2(float(parts[1]), float(parts[2]))
						var enemy_type = parts[3]
						enemy_data[key] = {"position": position, "type": enemy_type}
					line = file.get_line()
		file.close()
	else:
		print("Failed to open file: ", level_script)

func extract_line(line):
	var temp = line.strip_edges()
	temp = temp.replace(": {\"position\": Vector2(", ", ")
	temp = temp.replace("), \"type\": ", ", ").replace("},", "")
	temp = temp.replace("\"","")
	var arr = temp.split(", ")
	return arr

func _on_start_timer_timeout():
	toggle_pause()
	
func play_click_sfx():
	$ClickSFX.play()
