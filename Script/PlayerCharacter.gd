extends CharacterBody2D


const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED

signal player_died
#signal paused
var is_frozen = false

func _ready():
	#print("Ready!")
	pass
	
func _process(delta):
	
	if is_frozen:
		return
		
	if Input.is_action_pressed("move_down"):
		velocity.y += ACCELERATION
	elif Input.is_action_pressed("move_up"):
		velocity.y -= ACCELERATION
	else:
		velocity.y = 0
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= ACCELERATION
	elif Input.is_action_pressed("move_right"):
		velocity.x += ACCELERATION
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

