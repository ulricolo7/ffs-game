extends CharacterBody2D

const GRAVITY = 0
var ACCELERATION = 150 * Main.TEST_SPEED
var MAX_SPEED = 500 * Main.TEST_SPEED
const NAME = "00"

signal player_died
#signal paused
var is_frozen = false
var state
var move
var enemies_near = 0

@onready var counters = $Counters
@onready var counters_gp = counters.global_position

@onready var counterArray = [0, 0, 0, 0, 0]

func _ready():
	print(global_position)
	clear_counters()
	find_lowest_counter()
	state = "chilling"
	
func _process(delta):
	
	if is_frozen:
		return
		
	counters.global_position.y = counters_gp.y
	counters_gp.x += 700 * delta
	counters.global_position.x = counters_gp.x
	
	if move == "up":
		velocity.y -= ACCELERATION
	elif move == "down":
		velocity.y += ACCELERATION
	else:
		velocity.y = 0
		
		
	if enemies_near == 0:
		state = "chilling"
	
	if state == "chilling":
		var safest_pos_y = (find_lowest_counter() - 2) * 75 + 440
		if global_position.y < safest_pos_y:
			velocity.y += 50
		elif global_position.y > safest_pos_y:
			velocity.y -= 50
		
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
	
func clear_counters():
	counterArray.fill(0)

func adjust_counter(area, counter, enter):
	if enter:
		if area.is_in_group("Ghaster"):
			counter += 1
		elif area.is_in_group("Crawler"):
			counter += 2
		elif area.is_in_group("Flapper"):
			counter += 3
	else:
		if area.is_in_group("Ghaster"):
			counter -= 1
		elif area.is_in_group("Crawler"):
			counter -= 2
		elif area.is_in_group("Flapper"):
			counter -= 3
			
	return counter
	
func find_lowest_counter():
	var lowest = counterArray.min()
	var idx
	
	if counterArray[2] == lowest:
		idx = 2
	elif counterArray[3] == lowest:
		idx = 3
	elif counterArray[1] == lowest:
		idx = 1
	elif counterArray[4] == lowest:
		idx = 4
	else:
		idx = 0
	
	return idx

func _on_near_scan_area_exited(area):
	move = ""
	enemies_near -= 1
	
	if enemies_near == 0:
		state == "chilling"

func _on_near_scan_area_entered(area):
	if area.is_in_group("Enemies") && area.position.y >= global_position.y:
		state = "dodging"
		velocity.y = 0
		move = "up"
		enemies_near += 1
	elif area.is_in_group("Enemies") && area.position.y < global_position.y:
		state = "dodging"
		velocity.y = 0
		move = "down"
		enemies_near += 1


func _on_position_1_area_entered(area):
	counterArray[0] = adjust_counter(area, counterArray[0], true)


func _on_position_1_area_exited(area):
	counterArray[0] = adjust_counter(area, counterArray[0], false)


func _on_position_2_area_entered(area):
	counterArray[1] = adjust_counter(area, counterArray[1], true)


func _on_position_2_area_exited(area):
	counterArray[1] = adjust_counter(area, counterArray[1], false)


func _on_position_3_area_entered(area):
	counterArray[2] = adjust_counter(area, counterArray[2], true)


func _on_position_3_area_exited(area):
	counterArray[2] = adjust_counter(area, counterArray[2], false)


func _on_position_4_area_entered(area):
	counterArray[3] = adjust_counter(area, counterArray[3], true)


func _on_position_4_area_exited(area):
	counterArray[3] = adjust_counter(area, counterArray[3], false)


func _on_position_5_area_entered(area):
	counterArray[4] = adjust_counter(area, counterArray[4], true)


func _on_position_5_area_exited(area):
	counterArray[4] = adjust_counter(area, counterArray[4], false)
