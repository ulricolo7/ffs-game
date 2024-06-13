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
var h_scroll_bar
var editor_screen
var editor_screen_map
var background
var camera
var scroll_factor = 0.01

#overall, what I did was I added a Camera2D as a child to Editor and attached GUI to it,
#and moved the Background Sprite to be separate from the Map

func _ready():
	#You made good call for references *thumbsup
	editor_screen = get_parent().get_node("../EditorScreen")
	editor_screen_map = get_parent().get_node("../EditorScreen/Map")
	background = get_parent().get_node("../EditorScreen/Sprite2D")
	camera = get_parent()
	h_scroll_bar = get_node("../HScrollBar")
	
	$Panel/GhasterButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("ghaster"))
	$Panel/FlapperButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("flapper"))
	$Panel/CrawlerGroundButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("crawler_ground"))
	$Panel/CrawlerAirButton.connect("pressed", Callable(self, "_on_enemy_button_pressed").bind("crawler_air"))
	
	#The HSCrollbar is already emitting a signal. GPT doesnt know this and
	#this line to 'connect' is actually unnecessary
	#h_scroll_bar.connect("value_changed", Callable(self, "_on_h_scroll_bar_value_changed"))
	
	#I made the input in the inspector tab for the hscrollbar
	#h_scroll_bar.max_value = 32000
	set_process_input(true)


func _on_enemy_button_pressed(enemy_type):
	var enemy_scene = enemy_scenes.get(enemy_type)
	var inst_location = camera.position.x
	
	if enemy_scene:
		var enemy_instance = enemy_scene.instantiate()
		if enemy_type == "ghaster":
			enemy_instance.position = Vector2(inst_location, 420)
		elif enemy_type == "flapper":
			enemy_instance.position = Vector2(inst_location, 420)
		elif enemy_type == "crawler_ground":
			enemy_instance.position = Vector2(inst_location, 710)
		elif enemy_type == "crawler_air":
			enemy_instance.position = Vector2(inst_location, 150)

		editor_screen.add_child(enemy_instance)
		print("spawned in ", inst_location)
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
		editor_screen_map.remove_child(last_enemy)
		last_enemy.queue_free()
		last_enemy = null

func _on_play_button_pressed():
	$Panel.visible = false
	# logic to make this into a level and play



func _on_h_scroll_bar_value_changed(value):
	#lemme explain the code
	#the argument 'value' is the value of the scroller in the hscrollbar
	#we can set its min and max in the inspector tab or manually like what u did
	#to make it simple, I just gave it min 0 max 30000 as that is our max level length
	#you can find a logic to auto change the max level length according to the last enemy
	#I leave that to u
	var scroll_value = value
	
	#as the value starts from 0, the camera might snap backwards as the camera
	#should start from 640 (middle of screen). Hence it is 640 + scroll_value
	camera.position.x = scroll_value + 640
	
	#the editor screen starts from 0 anyways (refer to the 2D tab/check position 
	#under transform). So this I just leave it to scroll_value
	editor_screen_map.position.x = scroll_value
	
	#the speed of the bg is 0.99 (now I have edited so that Main.gd has that data)
	#the background is also longer than other sprites and it starts at 800, not 640
	#(the centre of the background is at 800), hence:
	background.position.x = scroll_value * Main.BG_SPEED + 800
