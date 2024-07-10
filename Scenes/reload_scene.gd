extends Node


func reload_scene():
	var current_scene = get_tree().current_scene
	var new_scene = current_scene.duplicate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene.queue_free()
