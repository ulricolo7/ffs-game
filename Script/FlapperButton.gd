extends TextureButton

const DRAGPREVIEW = preload("res://Scenes/drag_preview_flapper.tscn")

func _get_drag_data(position: Vector2):
	var original_instance = self.get_parent()
	
	var data = {}
	data["instance"] = original_instance.duplicate()
	data["type"] = "flapper"
	data["offset"] = position
	
	var dragPreview = DRAGPREVIEW.instantiate()
	var textureRect = dragPreview.get_node("TextureRect")
	textureRect.texture = self.texture_normal
	
	dragPreview.scale = Vector2(2, 2)
	
	set_drag_preview(dragPreview)
	print("dragging")
	
	return data

func _ready():
	print("flapper button ready")
	
	
