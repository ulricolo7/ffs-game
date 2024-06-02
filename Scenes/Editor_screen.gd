extends Control

const GHASTER_SCENE = preload("res://ghaster_box.tscn")
const FLAPPER_SCENE = preload("res://flapper_box.tscn")
const CRAWLER1_SCENE = preload("res://crawler_box_1.tscn")
const CRAWLER2_SCENE = preload("res://crawler_box_2.tscn")


func _can_drop_data(position, data):
	return data.has("instance")

func _drop_data(position, data):
	if data.has("instance"):
		var instance = data["instance"]
		add_child(instance)
		
		instance.position = position 
		instance.scale = Vector2(3,3)
		
		convert_to_area2d(instance)
		
func convert_to_area2d(instance):
	print("converting")
	var texture_button = instance.get_node("TextureButton")
	var ghaster_area2d = Area2D.new()
	
	var sprite = Sprite2D.new()
	sprite.texture = texture_button.texture_normal
	sprite.scale = texture_button.scale
	#if sprite.texture:
	#	var texture = sprite.texture as Texture2D
	#	texture.filter_mode = TEXTURE_FILTER_NEAREST
	# i havent figured out how to make it have the nearest filter
	
	ghaster_area2d.add_child(sprite)
	ghaster_area2d.position = instance.position
	ghaster_area2d.scale = Vector2(3,3)
	add_child(ghaster_area2d)
	print("Converted")
	instance.queue_free()

func _ready():
	print("editor screen ready")
	set_process_input(true)
