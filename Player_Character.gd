extends CharacterBody2D


const GRAVITY = 0
const FLOAT_SPEED = 50
const MAX_SPEED = 150

func _ready():
	print("Ready!")
	
func _physics_process(delta):

	if Input.is_action_pressed("move_down"):
		velocity.y += 100
	elif Input.is_action_pressed("move_up"):
		velocity.y -= 100
	else:
		velocity.y = 0
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= 100
	elif Input.is_action_pressed("move_right"):
		velocity.x += 100
	else:
		velocity.x = 0
	
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide()


	
