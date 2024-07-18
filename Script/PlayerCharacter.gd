extends CharacterBody2D


const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED

signal player_died
#signal paused
var is_frozen = false

# animation management
var default_frames = "default"
var idle_frames = "idle"
var last_input_time = 0
var idle_threshold = 5.25 # seconds
var is_idle = false

func _ready():
	#print("Ready!")
	$AnimatedSprite.play("default")
	last_input_time = Time.get_ticks_msec() / 1000.0
	set_process(true)
	
func _process(_delta):
	
	if is_frozen:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if Main.player_input_disabled or Main.editor_paused:
		pass
	else:
		if Input.is_action_pressed("move_down"):
			velocity.y += ACCELERATION
			reset_idle_timer()
		elif Input.is_action_pressed("move_up"):
			velocity.y -= ACCELERATION
			reset_idle_timer()
		else:
			velocity.y = 0
			
		if Input.is_action_pressed("move_left"):
			velocity.x -= ACCELERATION
			reset_idle_timer()
		elif Input.is_action_pressed("move_right"):
			velocity.x += ACCELERATION
			reset_idle_timer()
		else:
			velocity.x = 0
			
		if current_time - last_input_time > idle_threshold:
			if not is_idle:
				$AnimatedSprite.play("idle")
				is_idle = true
		
		velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		move_and_slide()
		
	#if position.x < -700 || position.x > 700:
	#	die()
	if position.x < -620:
		position.x = -620
	elif position.x > 620:
		position.x = 620
	
	if Main.in_editor:
		if position.y < -284:
			position.y = -284
		elif position.y > 280:
			position.y = 280
	else:
		if position.y < -355:
			position.y = -355
		elif position.y > 350:
			position.y = 350
		

func reset_idle_timer():
	last_input_time = Time.get_ticks_msec() / 1000.0
	if is_idle:
		$AnimatedSprite.play("default")
		is_idle = false
	
func die():
	emit_signal("player_died")
	$AnimatedSprite.play("death")
	$DeathSFX.play()
	
func freeze():
	is_frozen = true
	
func unfreeze():
	is_frozen = false

