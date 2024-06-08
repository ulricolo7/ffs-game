extends Node2D

const GhasterScene = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FlapperScene = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CrawlerGroundScene = preload("res://Scenes/Enemies/Crawler/crawler_ground.tscn")
const CrawlerAirScene = preload("res://Scenes/Enemies/Crawler/crawler_air.tscn")
var victory_screen
var death_screen
var player

var enemy_data = [
	{"position": Vector2(900, 329), "type": "gh"},
	{"position": Vector2(1270, 160), "type": "fl"},
	{"position": Vector2(1600, 730), "type": "cg"},
	{"position": Vector2(1600, 200), "type": "gh"},
	{"position": Vector2(1930, 400), "type": "fl"},
	{"position": Vector2(2000, 730), "type": "cg"},
	{"position": Vector2(2000, 80), "type": "ca"},
	{"position": Vector2(2050, 200), "type": "gh"},
	{"position": Vector2(2050, 350), "type": "gh"},
	{"position": Vector2(2450, 600), "type": "gh"},
	{"position": Vector2(2900, 320), "type": "gh"},
	{"position": Vector2(3270, 160), "type": "fl"},
	{"position": Vector2(3600, 730), "type": "cg"},
	{"position": Vector2(3600, 200), "type": "gh"},
	{"position": Vector2(3850, 400), "type": "fl"},
	{"position": Vector2(4000, 730), "type": "cg"},
	{"position": Vector2(4000, 80), "type": "ca"},
	{"position": Vector2(4050, 200), "type": "gh"},
	{"position": Vector2(4050, 350), "type": "gh"},
	{"position": Vector2(4280, 650), "type": "gh"}
]

func _ready():
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
	
	Main.no_pause_state = 1
	
	spawn_enemies()
	
	player = get_node("Camera/Player")
	player.connect("player_died", Callable(self, "die"))
	



func _process(delta):
	$Camera.position.x += Main.SCROLL_SPEED * delta
	
	if $Camera.position.x > 5000:
		print("You win!")
		win()
	
func spawn_enemies():
	var enemy_instance
		
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
		print("Enemy spawned with speed: ", enemy_instance.XSPEED + Main.SCROLL_SPEED)
		
func win():
	Main.no_pause_state = 0
	var x = $Camera.position.x
	var y = $Camera.position.y
	
	victory_screen.position = Vector2(x - 480, y - 240)
	victory_screen.visible = true
	player.freeze()

func die():
	Main.no_pause_state = 0
	print("Game Over")
	var x = $Camera.position.x
	var y = $Camera.position.y
	
	death_screen.position = Vector2(x - 480, y - 240)
	death_screen.visible = true

