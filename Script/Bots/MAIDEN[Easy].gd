extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED
const NAME = "MAIDEN[Easy]"

signal player_died
#signal paused
var is_frozen = false
var state
var move

func _ready():
	print(global_position)
	$AnimatedSprite.play("default")
	
	
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
	
	#if position.x < -800 || position.x > 780:
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
	
func die():
	emit_signal("player_died")
	$AnimatedSprite.play("death")
	$DeathSFX.play()
	$Timer.start(0.35)
	
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

func _on_timer_timeout():
	queue_free()
