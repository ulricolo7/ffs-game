extends Node2D

const GhasterScene = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FlapperScene = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CrawlerGroundScene = preload("res://Scenes/Enemies/Crawler/crawler_ground.tscn")
const CrawlerAirScene = preload("res://Scenes/Enemies/Crawler/crawler_air.tscn")

const GroundScene = preload("res://Scenes/ground.tscn")
const TreeShortScene = preload("res://Scenes/tree_short_2.tscn")
const TreeMedScene = preload("res://Scenes/tree_medium_2.tscn")
const TreeTallScene = preload("res://Scenes/tree_tall_2.tscn")

var victory_screen
var death_screen
var pause_screen
var player
var enemy_instance
var x 
var y 

var is_paused = false
@onready var pause_timer = $PauseTimer
@onready var death_timer = $DeathTimer


var enemy_data = [
	{"position": Vector2(900, 329), "type": "gh"},
	{"position": Vector2(1270, 160), "type": "fl"},
	{"position": Vector2(1600, 720), "type": "cg"},
	{"position": Vector2(1600, 200), "type": "gh"},
	{"position": Vector2(1930, 400), "type": "fl"},
	{"position": Vector2(2000, 720), "type": "cg"},
	{"position": Vector2(2000, 80), "type": "ca"},
	{"position": Vector2(2100, 200), "type": "gh"},
	{"position": Vector2(2050, 550), "type": "gh"},
	{"position": Vector2(2450, 400), "type": "gh"},
	{"position": Vector2(2900, 320), "type": "gh"},
	{"position": Vector2(3270, 160), "type": "fl"},
	{"position": Vector2(3600, 720), "type": "cg"},
	{"position": Vector2(3600, 200), "type": "gh"},
	{"position": Vector2(3850, 400), "type": "fl"},
	{"position": Vector2(4000, 720), "type": "cg"},
	{"position": Vector2(4000, 80), "type": "ca"},
	{"position": Vector2(4050, 300), "type": "gh"},
	{"position": Vector2(4280, 650), "type": "gh"},
	{"position": Vector2(4700, 500), "type": "gh"},
	{"position": Vector2(4730, 650), "type": "gh"},
	{"position": Vector2(4800, 160), "type": "fl"},
	{"position": Vector2(4800, 460), "type": "fl"},
	{"position": Vector2(4900, 220), "type": "fl"},
	{"position": Vector2(4900, 520), "type": "fl"},
	{"position": Vector2(5000, 280), "type": "fl"},
	{"position": Vector2(5000, 580), "type": "fl"},
	{"position": Vector2(5100, 340), "type": "fl"},
	{"position": Vector2(5100, 640), "type": "fl"},
	{"position": Vector2(5200, 280), "type": "fl"},
	{"position": Vector2(5200, 580), "type": "fl"},
	{"position": Vector2(5300, 220), "type": "fl"},
	{"position": Vector2(5300, 520), "type": "fl"},
	{"position": Vector2(5400, 160), "type": "fl"},
	{"position": Vector2(5400, 460), "type": "fl"},
	{"position": Vector2(6500, 0), "type": "ca"},
	{"position": Vector2(6600, 720), "type": "cg"},
	{"position": Vector2(31000, 320), "type": "gh"},
]

var last_enemy = enemy_data[-1]
var LEVEL_LENGTH = last_enemy["position"].x + 1000
	
func _ready():
	pause_timer.one_shot = true
	death_timer.one_shot = true
	death_timer.connect("timeout", Callable(self, "_on_death_timeout"))
	
	var victory_scene = preload("res://Scenes/win.tscn")
	victory_screen = victory_scene.instantiate()
	victory_screen.visible = false
	victory_screen.z_index = 10
	add_child(victory_screen)
	
	var death_scene = preload("res://Scenes/died.tscn")
	death_screen = death_scene.instantiate()
	death_screen.visible = false
	death_screen.z_index = 10
	add_child(death_screen)
	
	var pause_scene = preload("res://Scenes/paused.tscn")
	pause_screen = pause_scene.instantiate()
	pause_screen.visible = false
	pause_screen.z_index = 10
	add_child(pause_screen)
	
	Main.no_pause_state = 1
	
	spawn_ground(1200)
	spawn_trees()
	spawn_enemies()
	spawn_ground(1000)
	
	player = get_node("Camera/Player")
	player.connect("player_died", Callable(self, "die"))
	player.connect("paused", Callable(self, "pause"))
	pause_screen.connect("resumed", Callable(self, "resume"))
	
	print("Level ready")


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	$Camera.position.x += Main.SCROLL_SPEED * delta
	$Background.position.x += Main.SCROLL_SPEED * delta * Main.BG_SPEED
	$TreeLayer.position.x += Main.SCROLL_SPEED * delta * 0.9
	
	if $Camera.position.x > LEVEL_LENGTH - 500:
		print("You win!")
		win()

func toggle_pause():
	if is_paused:
		resume()
	else:
		pause()
	pause_timer.start(0.1)	
	
func spawn_enemies():
	
	for data in enemy_data:
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
		
func spawn_ground(value):
	var dist_covered = 0
	var ground_instance
	
	while dist_covered < LEVEL_LENGTH:
		ground_instance = GroundScene.instantiate()
		ground_instance.position = Vector2(dist_covered, 193.662)
		dist_covered += value
		add_child(ground_instance)
	
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

func win():
	Main.no_pause_state = 0
	x = $Camera.position.x
	y = $Camera.position.y
	victory_screen.position = Vector2(x - 480, y - 240)
	victory_screen.visible = true
	player.freeze()

func die():
	Main.no_pause_state = 0 
	
	print("Game Over")
	x = $Camera.position.x
	y = $Camera.position.y

	death_screen.position = Vector2(x - 480, y - 240)
	death_screen.visible = true
	death_timer.start(1.0)
	

func pause():
	if Main.no_pause_state == 1:
		Main.no_pause_state = 0
		print("Paused")
		x = $Camera.position.x
		y = $Camera.position.y

		pause_screen.position = Vector2(x - 640, y - 420)
		pause_screen.visible = true
		player.freeze()
	# can make the music change to the main menu here?
		is_paused = true

func resume():
	print("resumed")
	if Main.no_pause_state == 0:
		Main.no_pause_state = 1
		pause_screen.visible = false
		player.unfreeze()
		enemy_instance.unfreeze()
		is_paused = false
		
func _on_death_timeout():
	get_tree().reload_current_scene()

