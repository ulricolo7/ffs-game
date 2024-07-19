extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var SOFT_ACC = 100 * Main.TEST_SPEED
var HORI_ACC = 50 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED
const NAME = "TECHIES"
#DO NOT TOUCH ANYTHING

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
	
func _process(_delta):
	
	if is_frozen:
		return
		
	if move_dir == "down":
		velocity.y += ACCELERATION
	elif move_dir == "up":
		velocity.y -= ACCELERATION
	else:
		velocity.y = 0
		
	if soft_dir == "down":
		velocity.y += SOFT_ACC
	elif soft_dir == "up":
		velocity.y -= SOFT_ACC
	else:
		velocity.y += 0
		
	if global_position.x < get_parent().global_position.x && state != "dodging":
		velocity.x += HORI_ACC
	elif state == "dodging":
		velocity.x -= 10
	else:
		velocity.x = 0
		
	if state == "returning" && (global_position.y <= 560 || global_position.y >= 280):
		velocity.y = 0
	
	if state != "dodging" && (global_position.y < 280):
		soft_dir = "down"
	elif state != "dodging" && (global_position.y > 560):
		soft_dir = "up"
		
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide()
	
	if position.x < -800 || position.x > 780:
		die()

func return_to_centre():
	if state == "dodging" || (state == "adjusting" && (global_position.y >= 160 && global_position.y <= 720)) :
		return
	
	if global_position.y >= 580:
		print("returning up")
		move_dir = "up"
		soft_dir = "down"
	elif global_position.y <= 260:
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
	if state == "dodging":
		return
		
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		print("adjusting up")
		state = "adjusting"
		move_dir = ""
		soft_dir = "up"
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		print("adjusting down")
		state = "adjusting"
		move_dir = ""
		soft_dir = "down"


func _on_near_scan_area_entered(area):
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		print("dodging up")
		state = "dodging"
		velocity.y = 0
		move_dir = "up"
		soft_dir = ""
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		print("dodging down")
		state = "dodging"
		velocity.y = 0
		move_dir = "down"
		soft_dir = ""


func _on_near_scan_area_exited(_area):
	velocity.y = 0
	state = "returning"
	return_to_centre()


func _on_far_scan_area_exited(_area):
	return_to_centre()
