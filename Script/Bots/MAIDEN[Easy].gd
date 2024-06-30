extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED
const NAME = "MAIDEN"

signal player_died
#signal paused
var is_frozen = false
var state
var move

func _ready():
	print(global_position)
	pass
	
func _process(delta):
	
	if is_frozen:
		return
		
	
	if move == "up":
		velocity.y -= ACCELERATION
	elif move == "down":
		velocity.y += ACCELERATION
	else:
		velocity.y = 0
		
	if global_position.x < get_parent().global_position.x - 300:
		velocity.x = 100
	else:
		velocity.x = 0
		
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide()
	
	if position.x < -800 || position.x > 780:
		die()
	
func die():
	print("Player died")
	emit_signal("player_died")
	queue_free()
	
func freeze():
	is_frozen = true
	
func unfreeze():
	is_frozen = false

func _on_near_scan_area_exited(area):
	move = ""

func _on_near_scan_area_entered(area):
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		state = "dodging"
		velocity.y = 0
		move = "up"
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		state = "dodging"
		velocity.y = 0
		move = "down"

