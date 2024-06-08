extends CharacterBody2D


const GRAVITY = 0
const FLOAT_SPEED = 50
const MAX_SPEED = 400

signal player_died
var is_frozen = false

func _ready():
	print("Ready!")
	
func _process(delta):
	
	if is_frozen:
		return
		
	if Input.is_action_pressed("move_down"):
		velocity.y += 150
	elif Input.is_action_pressed("move_up"):
		velocity.y -= 150
	else:
		velocity.y = 0
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= 150
	elif Input.is_action_pressed("move_right"):
		velocity.x += 150
	else:
		velocity.x = 0
	
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide()


	
func die():
	print("Player died")
	emit_signal("player_died")
	queue_free()
	
func freeze():
	is_frozen = true

