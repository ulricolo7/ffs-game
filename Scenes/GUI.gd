extends Control

var curr_enemy = null
var last_enemy = null
var enemy_data = []
var enemy_scenes = {
	"ghaster": preload("res://Scenes/Enemies/Ghaster/ghaster_static.tscn"),
	"flapper": preload("res://Scenes/Enemies/Flapper/flapper_static.tscn"),
	"crawler_ground": preload("res://Scenes/Enemies/Crawler/crawler_ground_static.tscn"),
	"crawler_air": preload("res://Scenes/Enemies/Crawler/crawler_air_static.tscn") 
}

func _ready():
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ghaster"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("flapper"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("crawler_ground"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("crawler_air"))
	set_process_input(true)

func _on_enemy_button_pressed(enemy_type):
	var enemy_scene = enemy_scenes.get(enemy_type)
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.set("input_pickable", true) # Ensure input is pickable
		if enemy_type == "ghaster":
			enemy_instance.position = Vector2(600, 420)
		elif enemy_type == "flapper":
			enemy_instance.position = Vector2(600, 420)
		elif enemy_type == "crawler_ground":
			enemy_instance.position = Vector2(600, 710)
		else:
			enemy_instance.position = Vector2(600, 150)

		get_node("../EditorScreen/Map").add_child(enemy_instance)
		enemy_instance.connect("input_event", Callable(self, "_on_enemy_selected").bind(enemy_instance))
		enemy_data.append({"position": enemy_instance.position, "type": enemy_type})
		
func _on_enemy_selected(viewport, event, shape_idx, enemy_instance):
	if event is InputEventMouseButton and event.pressed:
		curr_enemy = enemy_instance
		print("Selected enemy: ", enemy_instance)
		last_enemy = curr_enemy
	
func _input(event):
	if event is InputEventMouseButton and event.is_released():
		if curr_enemy:
			curr_enemy = null
		else:
			# Here you might add code to select a new enemy if needed.
			pass
	elif curr_enemy and event is InputEventMouseMotion:
			curr_enemy.position += event.relative

func _on_delete_button_pressed(): 
	print("delete button pressed")
	if last_enemy:
		print("delete button executed")
		get_node("../EditorScreen/Map").remove_child(last_enemy)
		last_enemy.queue_free()
		last_enemy = null

func _on_play_button_pressed():
	$Panel.visible = false
	# logic to make this into a level and play
