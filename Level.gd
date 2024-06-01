extends Node2D

const GhasterScene = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FlapperScene = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CrawlerGroundScene = preload("res://Scenes/Enemies/Crawler/crawler_ground.tscn")
const CrawlerAirScene = preload("res://Scenes/Enemies/Crawler/crawler_air.tscn")

var enemy_data = [
	{"position": Vector2(900, 160), "type": "gh"},
	{"position": Vector2(1270, 80), "type": "fl"},
	{"position": Vector2(1500, 370), "type": "cg"},
	{"position": Vector2(1500, 100), "type": "gh"},
	{"position": Vector2(1800, 200), "type": "fl"},
	{"position": Vector2(2000, 370), "type": "cg"},
	{"position": Vector2(2000, 40), "type": "ca"},
	{"position": Vector2(2050, 100), "type": "gh"},
	{"position": Vector2(2050, 200), "type": "gh"},
	{"position": Vector2(2250, 300), "type": "gh"}
]

func _ready():
	spawn_enemies()


func _process(delta):
	$Camera.position.x += Main.SCROLL_SPEED * delta
	
	if $Camera.position.x > 3000:
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
	queue_free()
	

		
