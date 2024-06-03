extends Control

const GHASTER_SCENE = preload("res://ghaster_box.tscn")
const FLAPPER_SCENE = preload("res://flapper_box.tscn")
const CRAWLER1_SCENE = preload("res://crawler_box_1.tscn")
const CRAWLER2_SCENE = preload("res://crawler_box_2.tscn")


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
	convert_to_area2d(instance)

func handle_flapper(instance):
	print("Handling Flapper")
	convert_to_area2d(instance, true)

func handle_crawler1(instance):
	print("Handling Crawler 1")
	convert_to_area2d(instance)

func handle_crawler2(instance):
	print("Handling Crawler 2")
	convert_to_area2d(instance)
		
func convert_to_area2d(instance, flip_horizontal = false):
	print("converting")
	var texture_button = instance.get_node("TextureButton")
	var entity_area2d = Area2D.new()
	
	var sprite = Sprite2D.new()
	sprite.texture = texture_button.texture_normal
	
	# HOW TF TO MAKE SPRITE.TEXTURE FILTER = NEAREST
	
	if flip_horizontal:
		sprite.scale = Vector2(-texture_button.scale.x, texture_button.scale.y)
	else:
		sprite.scale = texture_button.scale
	
	entity_area2d.add_child(sprite)
	entity_area2d.position = instance.position
	entity_area2d.scale = Vector2(3,3)
	add_child(entity_area2d)
	print("Converted")
	instance.queue_free()

func _ready():
	print("editor screen ready")
	set_process_input(true)
