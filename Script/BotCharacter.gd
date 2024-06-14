extends CharacterBody2D

const GRAVITY = 0
const FLOAT_SPEED = 50
const MAX_SPEED = 500
const NAME = "2ndTry"
#after he dies the first time, let him try again. don't ask.

signal player_died
#signal paused
var is_frozen = false
var move_dir
var soft_dir
var hori_dir
var state

func _ready():
	#print("Ready!")
	print(global_position)
	pass
	
func _process(delta):
	
	if is_frozen:
		return
		
	if move_dir == "down":
		velocity.y += 150
	elif move_dir == "up":
		velocity.y -= 150
	else:
		velocity.y = 0
		print(global_position.y)
		
	if soft_dir == "down":
		velocity.y += 90
	elif soft_dir == "up":
		velocity.y -= 90
	else:
		velocity.y += 0
		
	if global_position.x < get_parent().global_position.x:
		velocity.x += 100
	else:
		velocity.x = 0
		
	if state == "returning" && (global_position.y <= 560 || global_position.y <= 280):
		velocity.y = 0
		
	#scan_and_dodge()
	
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide()
	
	#if Input.is_action_pressed("pause"):
	#	emit_signal("paused")

func return_to_centre():
	if state == "dodging":
		return
	
	if global_position.y >= 560:
		print("returning up")
		move_dir = "up"
		soft_dir = "down"
	elif global_position.y <= 280:
		print("returning down")
		move_dir = "down"
		soft_dir = "up"
	else:
		move_dir = ""
	
func die():
	print("Player died")
	emit_signal("player_died")
	queue_free()
	
func freeze():
	is_frozen = true
	
func unfreeze():
	is_frozen = false


func _on_far_scan_area_entered(area):
	if state == "dodging" || state == "adjusting":
		return
		
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		print("floating up")
		state = "adjusting"
		move_dir = ""
		soft_dir = "up"
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		print("floating down")
		state = "adjusting"
		move_dir = ""
		soft_dir = "down"


func _on_near_scan_area_entered(area):
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		print("dodging up")
		state = "dodging"
		move_dir = ""
		move_dir = "up"
		soft_dir = ""
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		print("dodging down")
		state = "dodging"
		move_dir = ""
		move_dir = "down"
		soft_dir = ""


func _on_near_scan_area_exited(area):
	velocity.y = 0
	state = "returning"
	return_to_centre()


func _on_far_scan_area_exited(area):
	return_to_centre()
