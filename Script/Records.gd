extends Control

var attempts_path = "res://Script/ListOfAttempts.gd"
@export var attempt_scene = preload("res://Scenes/record_attempt.tscn")
var offset = 70

func _ready():
	pass
	
func scan_attempts_folder():
	var file = FileAccess.open(attempts_path, FileAccess.READ)
	if file:
		var line
		while not file.eof_reached():
			line = file.get_line()
			if not line.begins_with("var previous_attempts") && not line.begins_with("}"):
				var temp = break_down(line)
				if temp.size() == 5:
					display_attempt(temp)
	pass			
#-----------------------------------------------------------

func break_down(line):
	var res = line.replace("\t", "")
	res = res.replace(": {\"player\": \"", "&&&")
	res = res.replace("\", \"level\": \"", "&&&")
	res = res.replace("\", \"progress\": ", "&&&")
	res = res.replace(", \"time\": \"", "&&&")
	res = res.replace("\"},", "").split("&&&")
	print(res)
	return res

func display_attempt(arr):
	var scene = attempt_scene.instantiate()
	scene.find_child("LevelName").text = arr[2]
	scene.find_child("PlayerName").text = arr[1]
	scene.find_child("AttemptTime").text = arr[4]
	scene.find_child("Progress").text = arr[3] + "%"
	$Panel/ScrollContainer/VBoxContainer.add_child(scene)

func play_click_sfx():
	$ClickSFX.play()


func _on_visibility_changed():
	scan_attempts_folder()
