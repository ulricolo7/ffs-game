extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED
const NAME = "00"

signal player_died
#signal paused
var is_frozen = false
var state

func _ready():
	#print("Ready!")
	print(global_position)
	pass
	
func _process(delta):
	
	if is_frozen:
		return
		
	
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


func _on_far_scan_area_entered(area):
	pass
	
func _on_near_scan_area_exited(area):
	pass

func _on_far_scan_area_exited(area):
	pass
