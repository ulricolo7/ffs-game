extends Control

const GHASTER_SCENE = preload("res://Scenes/Enemies/Ghaster/ghaster.tscn")
const FLAPPER_SCENE = preload("res://Scenes/Enemies/Flapper/flapper.tscn")
const CRAWLER1_SCENE = preload("res://Scenes/Enemies/Crawler/crawler_ground.tscn")
const CRAWLER2_SCENE = preload("res://Scenes/Enemies/Crawler/crawler_air.tscn")

const GHASTER_SPRITE = preload("res://Scenes/Enemies/Ghaster/filtered_ghaster.tscn")
const FLAPPER_SPRITE = preload("res://Scenes/Enemies/Flapper/filtered_flapper.tscn")
const CRAWLER1_SPRITE = preload("res://Scenes/Enemies/Crawler/filtered_crawler_ground.tscn")
const CRAWLER2_SPRITE = preload("res://Scenes/Enemies/Crawler/filtered_crawler_air.tscn")

func _can_drop_data(position, data):
	return data.has("instance") and data.has("type")

func _drop_data(position, data):
	if data.has("instance"):
		var instance = data["instance"]
		add_child(instance)
		
		instance.position = position 
		instance.scale = Vector2(3,3)
		
		match data["type"]:
			"ghaster":
				handle_ghaster(instance)
			"flapper":
				handle_flapper(instance)
			"crawler1":
				handle_crawler1(instance)
			"crawler2":
				handle_crawler2(instance)

func handle_ghaster(instance):
	print("Handling Ghaster")
	instantiate_enemy(GHASTER_SPRITE, instance)

func handle_flapper(instance):
	print("Handling Flapper")
	instantiate_enemy(FLAPPER_SPRITE, instance)

func handle_crawler1(instance):
	print("Handling Crawler 1")
	instantiate_enemy(CRAWLER1_SPRITE, instance)

func handle_crawler2(instance):
	print("Handling Crawler 2")
	instantiate_enemy(CRAWLER2_SPRITE, instance)
		
func instantiate_enemy(scene, instance):
	print("Instantiating enemy")
	var sprite_instance = scene.instantiate()
	var entity_area2d = Area2D.new()
	
	entity_area2d.add_child(sprite_instance)
	entity_area2d.position = instance.position
	entity_area2d.scale = Vector2(3,3)
	add_child(entity_area2d)
	print("Enemy instantiated")
	instance.queue_free()

func _ready():
	print("editor screen ready")
	set_process_input(true)
