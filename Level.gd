extends Node2D

const GhasterScene = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FlapperScene = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CrawlerScene = preload("res://Scenes/Enemies/Crawler/crawler.tscn")

var enemy_data = [
	{"position": Vector2(900, 160), "type": "gh"},
	{"position": Vector2(1270, 80), "type": "fl"},
	{"position": Vector2(1500, 350), "type": "cr"},
	{"position": Vector2(1500, 100), "type": "gh"},
	{"position": Vector2(1800, 200), "type": "fl"},
	{"position": Vector2(2000, 350), "type": "cr"},
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
		elif data["type"] == "cr":
			enemy_instance = CrawlerScene.instantiate()
			
		enemy_instance.position = data["position"]
		add_child(enemy_instance)
		print("Enemy spawned with speed: ", enemy_instance.XSPEED + Main.SCROLL_SPEED)
		
func win():
	queue_free()
	

		
