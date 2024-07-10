extends Node


func restart_game():
	var output = []
	var executable_path = OS.get_executable_path()
	OS.delay_msec(100)  
	var exit_code = OS.execute(executable_path, [], output, true)
	if exit_code != 0:
		print("Failed to restart the game: ", output)
	get_parent().get_parent().queue_free()
	#get_tree().quit()
