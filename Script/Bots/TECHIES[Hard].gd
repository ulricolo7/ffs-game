extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var SOFT_ACC = 90 * Main.TEST_SPEED
var HORI_ACC = 25 * Main.TEST_SPEED
var DODGE_ACC = 50 * Main.TEST_SPEED
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
var in_scan = 0
var head
var headc = 0
var leg
var legc = 0
var back
var head_counter = 0
var leg_counter = 0
var out_scan = 0

func _ready():
	head = -MAX_SPEED
	leg = MAX_SPEED
	back = -MAX_SPEED
	pass
	
func _process(_delta):
	print(leg_counter, out_scan/2)
	print(head, leg, back)
	#print(velcity.x)
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
		hori_dir = "forward"
		velocity.x += HORI_ACC
	elif state == "dodging":
		hori_dir = "back"
		velocity.x -= DODGE_ACC
	else:
		velocity.x = 0
		
	if state == "returning" && (global_position.y <= 520 || global_position.y >= 320):
		velocity.y = 0
	
	if state != "dodging" && (global_position.y < 320):
		soft_dir = "down"
	elif state != "dodging" && (global_position.y > 520):
		soft_dir = "up"
	
	velocity.y = clamp(velocity.y, head, leg)
	velocity.x = clamp(velocity.x, back, MAX_SPEED)
	move_and_slide()
	
	if position.x < -800 || position.x > 780:
		die()

func return_to_centre():
	if state == "dodging" || (state == "adjusting" && (global_position.y >= 240 && global_position.y <= 600)) :
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
	$DeathSFX.play()
	
func freeze():
	is_frozen = true
	
func unfreeze():
	is_frozen = false


func _on_far_scan_area_entered(area):
	if area.is_in_group("Enemies"):
		head_counter += 1


func _on_far_scan_area_exited(area):
	if area.is_in_group("Enemies"):
		head_counter -= 1


func _on_front_scan_area_entered(area):
	if area.is_in_group("Enemies") && (area.position.y >= global_position.y || (global_position.y > 600 && leg_counter >= floor(out_scan/2))):
		in_scan += 1
		print(in_scan)
		print("dodging up")
		state = "dodging"
		if velocity.y > 0 && hori_dir == "forward":
			velocity = Vector2(0, 0)
		elif velocity.y > 0:
			velocity.y = 0
		else:
			velocity.x = 0
		move_dir = "up"
		soft_dir = ""
	elif area.is_in_group("Enemies") && (area.position.y < global_position.y || (global_position.y < 240 && head_counter >= floor(out_scan/2))):
		in_scan += 1
		print(in_scan)
		print("dodging down")
		state = "dodging"
		if velocity.y < 0 && hori_dir == "forward":
			velocity = Vector2(0, 0)
		elif velocity.y < 0:
			velocity.y = 0
		else:
			velocity.x = 0
		move_dir = "down"
		soft_dir = ""


func _on_front_scan_area_exited(area):
	in_scan -= 1
	print(in_scan)
	if in_scan == 0:
		print("exit front")
		velocity.y = 0
		state = "returning"
		return_to_centre()


func _on_back_scan_area_entered(area):
	if area.is_in_group("Enemies"):
		back = 0


func _on_back_scan_area_exited(area):
	if area.is_in_group("Enemies"):
		back = -MAX_SPEED


func _on_head_scan_area_entered(area):
	if area.is_in_group("Enemies") && leg != 0:
		head = 0


func _on_head_scan_area_exited(area):
	if area.is_in_group("Enemies"):
		head = -MAX_SPEED


func _on_leg_scan_area_entered(area):
	if area.is_in_group("Enemies") && head != 0:
		leg = 0


func _on_leg_scan_area_exited(area):
	if area.is_in_group("Enemies"):
		leg = MAX_SPEED


func _on_far_scan_2_area_entered(area):
	if area.is_in_group("Enemies"):
		leg_counter += 1


func _on_far_scan_2_area_exited(area):
	if area.is_in_group("Enemies"):
		leg_counter -= 1


func _on_surround_scan_area_entered(area):
	if area.is_in_group("Enemies"):
		out_scan += 1


func _on_surround_scan_area_exited(area):
	if area.is_in_group("Enemies"):
		out_scan -= 1
